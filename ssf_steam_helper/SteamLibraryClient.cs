using SteamKit2;
using SteamKit2.Authentication;
using SteamKit2.Internal;
using SteamKit2.WebUI.Internal;
using static SteamKit2.SteamApps;

namespace SteamLibraryHelper;

public sealed class SteamLibraryClient : IDisposable
{
    private readonly SteamClient _client = new();
    private readonly CallbackManager _callbacks;
    private readonly SteamUser _user;
    private readonly SteamApps _apps;
    private readonly SteamUnifiedMessages _unifiedMessages;
    private readonly FamilyGroups _familyGroups;
    private readonly Player _player;
    private readonly AccountPrivateApps _privateApps;
    private readonly TaskCompletionSource<bool> _connected = NewTcs<bool>();
    private readonly TaskCompletionSource<SteamUser.LoggedOnCallback> _loggedOn = NewTcs<SteamUser.LoggedOnCallback>();
    private readonly object _licenseLock = new();
    private readonly TaskCompletionSource<LicenseListCallback> _licenseReceived = NewTcs<LicenseListCallback>();
    private LicenseListCallback? _lastLicense;
    private CancellationTokenSource _lifetime = new();
    private Task? _callbackLoop;
    private ulong _steamId;
    private readonly IAuthInput _authInput;

    public SteamLibraryClient() : this(new ConsoleAuthInput()) { }

    internal SteamLibraryClient(IAuthInput authInput)
    {
        _authInput = authInput;
        _callbacks = new CallbackManager(_client);
        _user = _client.GetHandler<SteamUser>()
            ?? throw new InvalidOperationException("SteamUser handler is unavailable.");
        _apps = _client.GetHandler<SteamApps>()
            ?? throw new InvalidOperationException("SteamApps handler is unavailable.");
        _unifiedMessages = _client.GetHandler<SteamUnifiedMessages>()
            ?? throw new InvalidOperationException("SteamUnifiedMessages handler is unavailable.");
        _familyGroups = _unifiedMessages.CreateService<FamilyGroups>();
        _player = _unifiedMessages.CreateService<Player>();
        _privateApps = _unifiedMessages.CreateService<AccountPrivateApps>();

        _callbacks.Subscribe<SteamClient.ConnectedCallback>(_ => _connected.TrySetResult(true));
        _callbacks.Subscribe<SteamUser.LoggedOnCallback>(callback =>
        {
            if (callback.Result == EResult.OK)
                _steamId = callback.ClientSteamID?.ConvertToUInt64() ?? 0;
            _loggedOn.TrySetResult(callback);
        });
        _callbacks.Subscribe<LicenseListCallback>(callback =>
        {
            lock (_licenseLock)
                _lastLicense = callback;
            _licenseReceived.TrySetResult(callback);
        });
    }

    public ulong SteamId => _steamId;

    public Task StartAsync()
    {
        if (_callbackLoop is not null)
            return Task.CompletedTask;

        _client.Connect();
        _callbackLoop = Task.Run(async () =>
        {
            while (!_lifetime.IsCancellationRequested)
            {
                _callbacks.RunWaitCallbacks(TimeSpan.FromMilliseconds(100));
                await Task.Delay(10, _lifetime.Token).ConfigureAwait(false);
            }
        }, _lifetime.Token);
        return Task.CompletedTask;
    }

    public async Task WaitConnectedAsync(CancellationToken cancellationToken)
        => await _connected.Task.WaitAsync(cancellationToken).ConfigureAwait(false);

    public async Task<SessionSecret> AuthenticateQrAsync(
        CancellationToken cancellationToken,
        Action<string> onChallenge)
    {
        var operation = new AuthOperation();
        var generation = operation.BeginQr();
        var qr = await _client.Authentication.BeginAuthSessionViaQRAsync(new AuthSessionDetails
        {
            DeviceFriendlyName = "SteamSpaceFarm Steam Library Helper",
            IsPersistentSession = true,
            Authenticator = new ConsoleAuthenticator(_authInput, cancellationToken),
        }).WaitAsync(cancellationToken).ConfigureAwait(false);

        void ChallengeChanged()
        {
            if (operation.UpdateChallenge(generation))
                onChallenge(qr.ChallengeURL);
        }

        qr.ChallengeURLChanged = ChallengeChanged;
        ChallengeChanged();

        try
        {
            var poll = await qr.PollingWaitForResultAsync(cancellationToken).ConfigureAwait(false);
            if (!operation.Complete(generation))
                throw new OperationCanceledException("QR operation is no longer active.");

            return await LogOnAsync(
                poll.AccountName,
                poll.RefreshToken,
                poll.NewGuardData,
                cancellationToken).ConfigureAwait(false);
        }
        catch (OperationCanceledException)
        {
            operation.Cancel();
            throw;
        }
        catch
        {
            operation.Cancel();
            throw;
        }
    }

    public async Task<SessionSecret> AuthenticateCredentialsAsync(
        string username,
        string password,
        CancellationToken cancellationToken)
    {
        var auth = await _client.Authentication.BeginAuthSessionViaCredentialsAsync(new AuthSessionDetails
        {
            Username = username,
            Password = password,
            DeviceFriendlyName = "SteamSpaceFarm Steam Library Helper",
            IsPersistentSession = true,
            Authenticator = new ConsoleAuthenticator(_authInput, cancellationToken),
        }).WaitAsync(cancellationToken).ConfigureAwait(false);

        var poll = await auth.PollingWaitForResultAsync(cancellationToken).ConfigureAwait(false);
        return await LogOnAsync(
            poll.AccountName,
            poll.RefreshToken,
            poll.NewGuardData,
            cancellationToken).ConfigureAwait(false);
    }

    public async Task<SessionSecret> AuthenticateStoredAsync(
        SessionSecret secret,
        CancellationToken cancellationToken)
        => await LogOnAsync(
            secret.AccountName,
            secret.RefreshToken,
            secret.GuardData,
            cancellationToken).ConfigureAwait(false);

    private async Task<SessionSecret> LogOnAsync(
        string accountName,
        string refreshToken,
        string? guardData,
        CancellationToken cancellationToken)
    {
        _user.LogOn(new SteamUser.LogOnDetails
        {
            Username = accountName,
            AccessToken = refreshToken,
            ShouldRememberPassword = true,
        });

        var callback = await _loggedOn.Task.WaitAsync(cancellationToken).ConfigureAwait(false);
        if (callback.Result != EResult.OK)
            throw new InvalidOperationException($"Steam LogOn failed: {callback.Result}.");

        return new SessionSecret(accountName, refreshToken, guardData);
    }

    public async Task<SteamLibraryResult> CollectAsync(CancellationToken cancellationToken, Action<string>? progress = null)
    {
        progress?.Invoke("personal");
        var personal = await GetPersonalAppsAsync(cancellationToken).ConfigureAwait(false);
        progress?.Invoke("private");
        var privateApps = await GetPrivateAppsAsync(cancellationToken).ConfigureAwait(false);
        progress?.Invoke("family");
        var family = await GetFamilyAppsAsync(cancellationToken).ConfigureAwait(false);
        progress?.Invoke("hours");
        var hours = await GetHoursAsync(cancellationToken).ConfigureAwait(false);

        var catalogIds = personal.Items.Concat(privateApps.Items).Concat(family.Apps.Items)
            .Concat(family.Metadata.Keys).Concat(hours.Metadata.Keys).ToHashSet();
        hours = hours with
        {
            Values = hours.Values.Where(pair => catalogIds.Contains(pair.Key))
            .ToDictionary(pair => pair.Key, pair => pair.Value)
        };

        var allIds = personal.Items
            .Concat(privateApps.Items)
            .Concat(family.Apps.Items)
            .Concat(family.Metadata.Keys)
            .Concat(hours.Values.Keys)
            .Distinct()
            .ToArray();
        progress?.Invoke("metadata");
        var metadata = await GetMetadataAsync(allIds, cancellationToken).ConfigureAwait(false);
        var metadataValues = new Dictionary<uint, string?>(metadata.Values);
        foreach (var pair in family.Metadata)
        {
            if (!metadataValues.TryGetValue(pair.Key, out var current)
                || string.IsNullOrWhiteSpace(current))
            {
                metadataValues[pair.Key] = pair.Value;
            }
        }
        foreach (var pair in hours.Metadata)
        {
            if (!metadataValues.TryGetValue(pair.Key, out var current)
                || string.IsNullOrWhiteSpace(current))
            {
                metadataValues[pair.Key] = pair.Value;
            }
        }

        var evidence = new LibraryEvidence(
            _steamId,
            personal,
            privateApps,
            family.Apps,
            family.PersonalApps,
            metadataValues,
            metadata.Complete,
            metadata.Error,
            hours.Values,
            hours.Complete,
            hours.Error,
            family.Report,
            new[]
            {
                "Personal ownership comes from LicenseList/PICS package appids.",
                "Private app list is an additional authorized source; its server-side coverage is not assumed complete.",
                "GetOwnedGames (including unvetted apps) and ClientGetLastPlayedTimes provide lifetime hours, not ownership evidence.",
            });

        progress?.Invoke("merging");
        return LibraryMerger.Merge(evidence with { Types = metadata.Types, LastPlayed = hours.LastPlayed });
    }

    private async Task<SourceData<uint>> GetPersonalAppsAsync(CancellationToken cancellationToken)
    {
        LicenseListCallback? license;
        lock (_licenseLock)
            license = _lastLicense;
        if (license is null)
        {
            try
            {
                license = await SteamJobAwaiter.AwaitAsync(_licenseReceived.Task, cancellationToken)
                    .ConfigureAwait(false);
            }
            catch (OperationCanceledException)
            {
                throw;
            }
            catch (Exception ex)
            {
                return new SourceData<uint>(Array.Empty<uint>(), false, SafeError(ex));
            }
        }

        try
        {
            if (license.Result != EResult.OK)
                return new SourceData<uint>(Array.Empty<uint>(), false, $"LicenseList result: {license.Result}.");

            var rejected = license.LicenseList
                .Where(item => !SteamParsing.IsPersonalLicense(item))
                .ToArray();

            var rejectionDetail = string.Join("; ", rejected
                .GroupBy(item => (item.LicenseType, item.LicenseFlags))
                .OrderByDescending(group => group.Count())
                .Select(group => $"{group.Key.LicenseType}/{group.Key.LicenseFlags}={group.Count()}"));
            var validLicenses = license.LicenseList
                .Where(SteamParsing.IsPersonalLicense)
                .ToArray();
            var packageRequests = validLicenses
                .GroupBy(item => item.PackageID)
                .Select(group => new PICSRequest(group.Key, group.First().AccessToken))
                .ToArray();
            if (packageRequests.Length == 0)
            {
                var detail = rejected.Length == 0
                    ? null
                    : $"Rejected {rejected.Length} licenses: {rejectionDetail}";
                return new SourceData<uint>(Array.Empty<uint>(), true, detail);
            }

            var response = await _apps.PICSGetProductInfo(
                Array.Empty<PICSRequest>(),
                packageRequests).WaitAsync(cancellationToken).ConfigureAwait(false);

            var callbacks = response.Results is null
                ? Enumerable.Empty<PICSProductInfoCallback>()
                : response.Results.AsEnumerable();
            var packageValues = callbacks.SelectMany(result => result.Packages).ToArray();
            var appIds = SteamParsing.ParsePackageAppIds(packageValues.Select(pair => pair.Value.KeyValues));
            var missingToken = packageValues.Count(pair => pair.Value.MissingToken);
            var unknownPackages = callbacks.Sum(result => result.UnknownPackages.Count);
            var returnedPackages = packageValues.Select(pair => pair.Key).ToHashSet();
            var assessment = SteamParsing.AssessCompleteness(
                packageRequests.Select(request => request.ID),
                returnedPackages,
                missingToken,
                unknownPackages,
                response.Complete && !response.Failed);

            return new SourceData<uint>(
                appIds,
                assessment.Complete,
                string.Join("; ", new[] { assessment.Detail,
                    rejected.Length == 0 ? null : $"Excluded inactive/borrowed licenses: {rejectionDetail}" }
                    .Where(detail => !string.IsNullOrWhiteSpace(detail))));
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return new SourceData<uint>(Array.Empty<uint>(), false, SafeError(ex));
        }
    }

    private async Task<SourceData<uint>> GetPrivateAppsAsync(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _privateApps.GetPrivateAppList(
                new CAccountPrivateApps_GetPrivateAppList_Request())
                .WaitAsync(cancellationToken).ConfigureAwait(false);
            if (result.Result != EResult.OK || result.Body?.private_apps?.appids is null)
                return new SourceData<uint>(Array.Empty<uint>(), false, $"Private app list result: {result.Result}.");

            var ids = result.Body.private_apps.appids
                .Where(id => id > 0)
                .Select(id => (uint)id)
                .Distinct()
                .ToArray();
            return new SourceData<uint>(ids, true);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return new SourceData<uint>(Array.Empty<uint>(), false, SafeError(ex));
        }
    }

    private async Task<(
        SourceData<uint> Apps,
        SourceData<uint> PersonalApps,
        SourceReport Report,
        IReadOnlyDictionary<uint, string?> Metadata)> GetFamilyAppsAsync(
        CancellationToken cancellationToken)
    {
        try
        {
            var group = await _familyGroups.GetFamilyGroupForUser(
                new CFamilyGroups_GetFamilyGroupForUser_Request
                {
                    steamid = _steamId,
                    include_family_group_response = true,
                }).WaitAsync(cancellationToken).ConfigureAwait(false);
            if (group.Result != EResult.OK || group.Body is null)
            {
                return (new SourceData<uint>(Array.Empty<uint>(), false, $"Family group result: {group.Result}."),
                    new SourceData<uint>(Array.Empty<uint>(), false, "Family group unavailable."),
                    new SourceReport("failed", 0, $"Family group result: {group.Result}."),
                    new Dictionary<uint, string?>());
            }

            var body = group.Body;
            if (body.is_not_member_of_any_group || body.family_groupid == 0)
            {
                return (new SourceData<uint>(Array.Empty<uint>(), true), new SourceData<uint>(Array.Empty<uint>(), true), new SourceReport("complete", 0),
                    new Dictionary<uint, string?>());
            }

            var shared = await _familyGroups.GetSharedLibraryApps(
                new CFamilyGroups_GetSharedLibraryApps_Request
                {
                    family_groupid = body.family_groupid,
                    steamid = _steamId,
                    include_own = true,
                    include_excluded = false,
                    include_non_games = true,
                    max_apps = 10_000,
                    language = "english",
                }).WaitAsync(cancellationToken).ConfigureAwait(false);
            if (shared.Result != EResult.OK || shared.Body?.apps is null)
            {
                return (new SourceData<uint>(Array.Empty<uint>(), false, $"Family apps result: {shared.Result}."),
                    new SourceData<uint>(Array.Empty<uint>(), false, "Family apps unavailable."),
                    new SourceReport("partial", 0, $"Family apps result: {shared.Result}."),
                    new Dictionary<uint, string?>());
            }

            var included = shared.Body.apps
                .Where(app => app.appid != 0 && app.exclude_reason == ESharedLibraryExcludeReason.k_ESharedLibrary_Included)
                .ToArray();
            var ids = included.Where(app => SteamParsing.HasOtherOwner(app.owner_steamids, _steamId))
                .Select(app => app.appid).Distinct().ToArray();
            var personalIds = included
                .Where(app => app.owner_steamids.Contains(_steamId))
                .Select(app => app.appid)
                .Distinct()
                .ToArray();
            var names = included
                .GroupBy(app => app.appid)
                .ToDictionary(group => group.Key, group =>
                    string.IsNullOrWhiteSpace(group.First().name) ? null : group.First().name);
            var possiblyTruncated = shared.Body.apps.Count >= 10_000;
            var report = new SourceReport(
                possiblyTruncated ? "partial" : "complete",
                included.Select(app => app.appid).Distinct().Count(),
                possiblyTruncated ? "response reached max_apps=10000; coverage may be truncated." : null);
            return (new SourceData<uint>(ids, !possiblyTruncated, report.Detail),
                new SourceData<uint>(personalIds, !possiblyTruncated, report.Detail), report, names);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            var error = SafeError(ex);
            return (new SourceData<uint>(Array.Empty<uint>(), false, error),
                new SourceData<uint>(Array.Empty<uint>(), false, error),
                new SourceReport("failed", 0, error),
                new Dictionary<uint, string?>());
        }
    }

    private async Task<PlaytimeData> GetHoursAsync(CancellationToken cancellationToken)
    {
        var ownedTask = GetOwnedHoursAsync(cancellationToken);
        var historyTask = GetHistoryHoursAsync(cancellationToken);
        await Task.WhenAll(ownedTask, historyTask).ConfigureAwait(false);
        cancellationToken.ThrowIfCancellationRequested();
        return PlaytimeData.Merge(await ownedTask.ConfigureAwait(false), await historyTask.ConfigureAwait(false));
    }

    private async Task<PlaytimeData> GetOwnedHoursAsync(CancellationToken cancellationToken)
    {
        try
        {
            var response = await SteamJobAwaiter.AwaitAsync(_player.GetOwnedGames(new CPlayer_GetOwnedGames_Request
            {
                steamid = _steamId,
                include_appinfo = true,
                include_played_free_games = true,
                include_free_sub = true,
                include_extended_appinfo = true,
                skip_unvetted_apps = false,
            }).ToTask(), cancellationToken).ConfigureAwait(false);
            if (response.Result != EResult.OK || response.Body?.games is null)
                return PlaytimeData.Failed($"Owned games result: {response.Result}.");

            var values = new Dictionary<uint, double>();
            var lastPlayed = new Dictionary<uint, uint>();
            foreach (var game in response.Body.games)
            {
                PlaytimeData.AddMinutes(values, game.appid, game.playtime_forever, game.ShouldSerializeplaytime_forever());
                if (game.appid > 0 && game.rtime_last_played > 0)
                    lastPlayed[(uint)game.appid] = Math.Max(lastPlayed.GetValueOrDefault((uint)game.appid), game.rtime_last_played);
            }
            var names = response.Body.games
                .Where(game => game.appid > 0)
                .GroupBy(game => (uint)game.appid)
                .ToDictionary(group => group.Key, group =>
                    string.IsNullOrWhiteSpace(group.First().name) ? null : group.First().name);
            return new(values, names, true, null, lastPlayed);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return PlaytimeData.Failed($"Owned games: {SafeError(ex)}");
        }
    }

    private async Task<PlaytimeData> GetHistoryHoursAsync(CancellationToken cancellationToken)
    {
        try
        {
            var response = await SteamJobAwaiter.AwaitAsync(
                _player.ClientGetLastPlayedTimes(new CPlayer_GetLastPlayedTimes_Request { min_last_played = 0 }).ToTask(),
                cancellationToken).ConfigureAwait(false);
            if (response.Result != EResult.OK || response.Body?.games is null)
                return PlaytimeData.Failed($"Played history result: {response.Result}.");

            var values = new Dictionary<uint, double>();
            var lastPlayed = new Dictionary<uint, uint>();
            foreach (var game in response.Body.games)
            {
                PlaytimeData.AddMinutes(values, game.appid, game.playtime_forever, game.ShouldSerializeplaytime_forever());
                if (game.appid > 0 && game.last_playtime > 0)
                    lastPlayed[(uint)game.appid] = Math.Max(lastPlayed.GetValueOrDefault((uint)game.appid), game.last_playtime);
            }
            return new(values, new Dictionary<uint, string?>(), true, null, lastPlayed);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex) { return PlaytimeData.Failed($"Played history: {SafeError(ex)}"); }
    }

    private async Task<(IReadOnlyDictionary<uint, string?> Values, bool Complete, string? Error, IReadOnlyDictionary<uint, string?> Types)> GetMetadataAsync(
        IReadOnlyCollection<uint> appIds,
        CancellationToken cancellationToken)
    {
        var names = new Dictionary<uint, string?>();
        var types = new Dictionary<uint, string?>();
        if (appIds.Count == 0)
            return (names, true, null, types);

        try
        {
            var tokens = await _apps.PICSGetAccessTokens(appIds, Array.Empty<uint>())
                .WaitAsync(cancellationToken).ConfigureAwait(false);
            var missingTokenIds = tokens.AppTokensDenied
                .Distinct()
                .ToHashSet();
            var missingRequestedIds = new HashSet<uint>();
            var unknownApps = 0;
            var missingMetadata = 0;
            var incompleteResponse = false;
            foreach (var batch in appIds.Chunk(200))
            {
                var requests = batch.Select(id =>
                {
                    tokens.AppTokens.TryGetValue(id, out var token);
                    return new PICSRequest(id, token);
                }).ToArray();
                var response = await _apps.PICSGetProductInfo(
                    requests,
                    Array.Empty<PICSRequest>(),
                    metaDataOnly: false).WaitAsync(cancellationToken).ConfigureAwait(false);
                incompleteResponse |= !response.Complete || response.Failed;
                var callbacks = response.Results is null
                    ? Enumerable.Empty<PICSProductInfoCallback>()
                    : response.Results;
                var callbackList = callbacks.ToArray();
                unknownApps += callbackList.Sum(callback => callback.UnknownApps.Count);
                var returnedIds = callbackList
                    .SelectMany(callback => callback.Apps)
                    .Select(pair => pair.Key)
                    .ToHashSet();
                missingRequestedIds.UnionWith(batch.Where(id => !returnedIds.Contains(id)));
                foreach (var pair in callbackList.SelectMany(callback => callback.Apps))
                {
                    if (pair.Value.MissingToken)
                    {
                        missingMetadata++;
                        missingRequestedIds.Add(pair.Key);
                    }
                    var name = pair.Value.KeyValues?["common"]?["name"]?.AsString();
                    types[(uint)pair.Value.ID] = pair.Value.KeyValues?["common"]?["type"]?.AsString();
                    if (string.IsNullOrWhiteSpace(name))
                        missingRequestedIds.Add(pair.Key);
                    names[(uint)pair.Value.ID] = string.IsNullOrWhiteSpace(name) ? null : name;
                }
            }

            var returnedAll = appIds.Except(missingRequestedIds).ToArray();
            var assessment = SteamParsing.AssessCompleteness(
                appIds,
                returnedAll,
                missingTokenIds.Count + missingMetadata,
                unknownApps,
                !incompleteResponse);
            return (names, assessment.Complete,
                string.IsNullOrWhiteSpace(assessment.Detail) ? null : assessment.Detail, types);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return (names, false, SafeError(ex), types);
        }
    }

    private static string SafeError(Exception exception)
        => $"{exception.GetType().Name}: operation failed.";

    private static TaskCompletionSource<T> NewTcs<T>()
        => new(TaskCreationOptions.RunContinuationsAsynchronously);

    public void Dispose()
    {
        _lifetime.Cancel();
        try { _client.Disconnect(); } catch { }
        try { _callbackLoop?.Wait(TimeSpan.FromSeconds(1)); } catch { }
        _lifetime.Dispose();
    }

    private sealed class ConsoleAuthenticator : IAuthenticator
    {
        private readonly CancellationToken _cancellationToken;
        private readonly IAuthInput _input;

        public ConsoleAuthenticator(IAuthInput input, CancellationToken cancellationToken)
        {
            _input = input;
            _cancellationToken = cancellationToken;
        }

        public Task<string> GetEmailCodeAsync(string email, bool previousCodeWasIncorrect)
            => ReadCodeAsync("email_code", previousCodeWasIncorrect ? "Email code was rejected; enter a new code: " : "Enter the Steam Guard email code: ");

        public Task<string> GetTwoFactorCodeAsync(bool previousCodeWasIncorrect)
            => ReadCodeAsync("totp_code", previousCodeWasIncorrect ? "Mobile code was rejected; enter a new code: " : "Enter the Steam Guard mobile code: ");

        public Task<string> GetDeviceCodeAsync(bool previousCodeWasIncorrect)
            => ReadCodeAsync("device_code", previousCodeWasIncorrect ? "Device code was rejected; enter a new code: " : "Enter the Steam Guard device code: ");

        public Task<bool> AcceptDeviceConfirmationAsync()
        {
            _cancellationToken.ThrowIfCancellationRequested();
            _input.NotifyDeviceConfirmation();
            return Task.FromResult(true);
        }

        private async Task<string> ReadCodeAsync(string kind, string prompt)
        {
            var result = await _input.ReadAsync(kind, prompt, true, _cancellationToken).ConfigureAwait(false);
            return result?.Trim() ?? string.Empty;
        }
    }
}
