using System.Text;
using System.Text.Json;
using SteamKit2;

namespace SteamLibraryHelper;

internal static class Program
{
    public static async Task<int> Main(string[] args)
    {
        var parsed = CliParser.Parse(args);
        if (!parsed.Success)
        {
            Console.Error.WriteLine($"[helper] invalid CLI: {parsed.Error}");
            PrintUsage(Console.Error);
            return 2;
        }

        var options = parsed.Options!;
        if (options.ShowHelp)
        {
            PrintUsage(Console.Out);
            return 0;
        }

        if (options.Synthetic)
            return await RunSyntheticChecksAsync().ConfigureAwait(false);

        var dataDir = options.DataDirectory ?? DefaultDataDirectory();
        var sessionPath = Path.GetFullPath(Path.Combine(dataDir, "session.dpapi"));
        if (string.Equals(options.OutputPath, sessionPath, StringComparison.OrdinalIgnoreCase))
        {
            Console.Error.WriteLine("[helper] output must not overwrite the session store");
            return 2;
        }
        var sessionStore = new DpapiSessionStore(sessionPath);
        using var deadline = new CancellationTokenSource(TimeSpan.FromSeconds(options.TimeoutSeconds));
        using var cancellation = CancellationTokenSource.CreateLinkedTokenSource(deadline.Token);
        Console.CancelKeyPress += (_, eventArgs) =>
        {
            eventArgs.Cancel = true;
            cancellation.Cancel();
            Console.Error.WriteLine("[helper] cancellation requested");
        };

        try
        {
            if (options.Forget)
            {
                var removed = sessionStore.Forget(cancellation.Token);
                Console.Error.WriteLine(removed
                    ? "[helper] session removed"
                    : "[helper] session was not present");
                return 0;
            }

            using var protocolInput = options.Events
                ? new ProtocolAuthInput(Console.OpenStandardInput(), cancellation, WriteEvent) : null;
            IAuthInput authInput = protocolInput is null ? new ConsoleAuthInput() : protocolInput;
            using var client = new SteamLibraryClient(authInput);
            await client.StartAsync().ConfigureAwait(false);
            await client.WaitConnectedAsync(cancellation.Token).ConfigureAwait(false);

            SessionSecret secret;
            switch (options.AuthMode)
            {
                case AuthMode.Auto:
                    secret = await RestoreSessionAsync(sessionStore, client, cancellation.Token)
                        .ConfigureAwait(false);
                    break;
                case AuthMode.Credentials:
                    secret = await AuthenticateWithCredentialsAsync(client, authInput, cancellation.Token)
                        .ConfigureAwait(false);
                    break;
                default:
                    Console.Error.WriteLine("[auth] waiting for QR confirmation");
                    secret = await client.AuthenticateQrAsync(
                        cancellation.Token,
                        url =>
                        {
                            if (options.Events)
                            {
                                WriteEvent(HelperJson.Qr(url));
                            }
                            else
                            {
                                Console.Error.WriteLine("[auth] render this challenge URL as a QR code to scan in Steam:");
                                Console.Error.WriteLine(url);
                            }
                        }).ConfigureAwait(false);
                    break;
            }

            cancellation.Token.ThrowIfCancellationRequested();
            sessionStore.Save(secret, cancellation.Token);
            if (options.Events)
                WriteEvent(HelperJson.Authenticated(client.SteamId.ToString()));
            Console.Error.WriteLine("[helper] session saved with DPAPI CurrentUser");

            var result = await client.CollectAsync(cancellation.Token,
                options.Events ? phase => WriteEvent(HelperJson.Progress(phase)) : null).ConfigureAwait(false);
            var json = HelperJson.Library(result);
            if (options.OutputPath is null)
            {
                if (options.Events)
                    WriteEvent(HelperJson.Result(result));
                else
                    Console.Out.WriteLine(json);
            }
            else
            {
                var outputDirectory = Path.GetDirectoryName(options.OutputPath);
                if (!string.IsNullOrWhiteSpace(outputDirectory))
                    Directory.CreateDirectory(outputDirectory);
                var temporary = options.OutputPath + "." + Guid.NewGuid().ToString("N") + ".tmp";
                try
                {
                    await File.WriteAllTextAsync(temporary, json, Encoding.UTF8, cancellation.Token).ConfigureAwait(false);
                    cancellation.Token.ThrowIfCancellationRequested();
                    File.Move(temporary, options.OutputPath, overwrite: true);
                }
                finally
                {
                    if (File.Exists(temporary)) File.Delete(temporary);
                }
                Console.Out.WriteLine(JsonSerializer.Serialize(new ResultWritten("result_written", options.OutputPath, result.Partial), ProtocolJsonContext.Default.ResultWritten));
            }

            return result.Partial ? 3 : 0;
        }
        catch (OperationCanceledException)
        {
            if (options.Events)
                WriteEvent(deadline.IsCancellationRequested ? HelperJson.TimedOut() : HelperJson.Cancelled());
            Console.Error.WriteLine(deadline.IsCancellationRequested
                ? "[helper] deadline expired"
                : "[helper] cancelled");
            return deadline.IsCancellationRequested ? 5 : 4;
        }
        catch (TimeoutException)
        {
            if (options.Events) WriteEvent(HelperJson.TimedOut());
            Console.Error.WriteLine("[helper] timeout");
            return 5;
        }
        catch (Exception exception)
        {
            if (options.Events) WriteEvent(HelperJson.Failed(exception.GetType().Name));

            Console.Error.WriteLine($"[helper] failed: {exception.GetType().Name}");
            return 6;
        }
    }

    private static void WriteEvent(ProtocolEvent value)
    {

        Console.Out.WriteLine(HelperJson.Serialize(value));
        Console.Out.Flush();
    }

    private static async Task<SessionSecret> RestoreSessionAsync(
        ISessionStore sessionStore,
        SteamLibraryClient client,
        CancellationToken cancellationToken)
    {
        var stored = sessionStore.TryLoad();
        if (stored is null)
            throw new InvalidOperationException("No valid session.");
        return await client.AuthenticateStoredAsync(stored, cancellationToken).ConfigureAwait(false);
    }

    private static async Task<SessionSecret> AuthenticateWithCredentialsAsync(
        SteamLibraryClient client,
        IAuthInput input,
        CancellationToken cancellationToken)
    {
        var username = await input.ReadAsync("username", "Steam account name: ", false, cancellationToken)
            .ConfigureAwait(false);
        if (string.IsNullOrWhiteSpace(username))
            throw new OperationCanceledException("Credential input ended.", cancellationToken);

        var password = await input.ReadAsync("password", "Steam password: ", true, cancellationToken)
            .ConfigureAwait(false);
        if (password is null)
            throw new OperationCanceledException("Credential input ended.", cancellationToken);

        return await client.AuthenticateCredentialsAsync(
            username.Trim(),
            password,
            cancellationToken).ConfigureAwait(false);
    }

    private static async Task<int> RunSyntheticChecksAsync()
    {
        JsonContractChecks.Run();
        PlaytimeChecks.Run();
        await AuthInputChecks.RunAsync().ConfigureAwait(false);
        var appids = new KeyValue { Name = "appids" };
        appids.Children.Add(new KeyValue { Name = "0", Value = "480" });
        appids.Children.Add(new KeyValue { Name = "1", Value = "570" });
        var package = new KeyValue { Name = "package" };
        package.Children.Add(appids);
        var parsedAppIds = SteamParsing.ParsePackageAppIds(new[] { package });
        if (!parsedAppIds.SetEquals(new uint[] { 480, 570 }))
            return Fail("PICS appids parser accepted positional child names or lost values");

        if (!SteamParsing.IsPersonalLicense(ELicenseType.SinglePurchase, ELicenseFlags.None)
            || !SteamParsing.IsPersonalLicense(ELicenseType.SinglePurchase, ELicenseFlags.RegionRestrictionExpired)
            || SteamParsing.IsPersonalLicense(ELicenseType.SinglePurchase, ELicenseFlags.RegionRestrictionExpired | ELicenseFlags.Borrowed)
            || SteamParsing.IsPersonalLicense(ELicenseType.SinglePurchase, ELicenseFlags.RegionRestrictionExpired | ELicenseFlags.Expired)
            || SteamParsing.IsPersonalLicense(ELicenseType.SinglePurchase, ELicenseFlags.Borrowed)
            || SteamParsing.IsPersonalLicense(ELicenseType.SinglePurchase, ELicenseFlags.Expired))
        {
            return Fail("license classifier accepted borrowed or inactive licenses");
        }

        var partialEvidence = new LibraryEvidence(
            SteamId: 76561198000000001,
            PersonalLicenses: new SourceData<uint>(new uint[] { 480, 570 }, false, "missingToken=1"),
            PrivateApps: new SourceData<uint>(new uint[] { 480, 998, 999 }, true),
            FamilyApps: new SourceData<uint>(new uint[] { 480, 730, 440 }, true),
            FamilyPersonalApps: new SourceData<uint>(new uint[] { 440 }, true),
            Metadata: new Dictionary<uint, string?> { [480] = "Personal" },
            MetadataComplete: false,
            MetadataError: "unknownApps=1",
            Hours: new Dictionary<uint, double> { [480] = 2.5 },
            HoursComplete: false,
            HoursError: "missingRequestedApps=1",
            FamilyReport: new SourceReport("complete", 2),
            Diagnostics: Array.Empty<string>(),
            LastPlayed: new Dictionary<uint, uint> { [480] = 1780000000 });
        var result = LibraryMerger.Merge(partialEvidence);
        var personalFamily = result.Apps.Single(app => app.AppId == 480);
        var familyOnly = result.Apps.Single(app => app.AppId == 730);
        var privateOnly = result.Apps.Single(app => app.AppId == 998);
        if (personalFamily.Ownership != "personal"
            || familyOnly.Ownership != "family"
            || privateOnly.Ownership is not null
            || result.Apps.Single(app => app.AppId == 999).Ownership is not null
            || result.Apps.Single(app => app.AppId == 440).Ownership != "personal"
            || result.Apps.Count != 6
            || !result.Partial
            || result.SteamId != "76561198000000001"
            || personalFamily.LastPlayedAtUnixSeconds != 1780000000
            || familyOnly.LastPlayedAtUnixSeconds is not null)
        {
            return Fail("personal/family priority, private skeleton, partial retention, or decimal SteamID failed");
        }

        if (SteamParsing.HasOtherOwner([], 1) || SteamParsing.HasOtherOwner([0, 1], 1)
            || !SteamParsing.HasOtherOwner([1, 2], 1))
        {
            return Fail("Family owner evidence classifier failed");
        }

        var jsonResult = HelperJson.Library(result);
        using var jsonDoc = JsonDocument.Parse(jsonResult);
        if (jsonDoc.RootElement.GetProperty("steamId").ValueKind != JsonValueKind.String
            || !jsonDoc.RootElement.GetProperty("apps").EnumerateArray().Any(app => app.GetProperty("ownership").ValueKind == JsonValueKind.Null))
        {
            return Fail("wire contract must preserve string SteamID and actual null ownership");
        }

        var assessment = SteamParsing.AssessCompleteness(
            requested: new uint[] { 480, 570 },
            returned: new uint[] { 480 },
            missingTokenCount: 1,
            unknownCount: 1,
            transportComplete: false,
            rejectedCount: 1);
        if (assessment.Complete || !assessment.Detail.Contains("missingRequested"))
            return Fail("PICS missing-token/unknown/requested-ID assessment failed");

        var operation = new AuthOperation();
        var generation = operation.BeginQr();
        if (!operation.UpdateChallenge(generation)
            || operation.Complete(generation) == false
            || operation.UpdateChallenge(generation))
        {
            return Fail("QR generation guard failed");
        }

        generation = operation.BeginQr();
        operation.Cancel();
        if (operation.UpdateChallenge(generation) || operation.Complete(generation))
            return Fail("cancelled QR operation accepted late completion");

        var tempDir = Path.Combine(Path.GetTempPath(), "ssf-steam-helper-check-" + Guid.NewGuid().ToString("N"));
        var storePath = Path.Combine(tempDir, "session.dpapi");
        try
        {
            var store = new DpapiSessionStore(storePath);
            if (store.TryLoad() is not null)
                return Fail("missing DPAPI store unexpectedly loaded");

            Directory.CreateDirectory(tempDir);
            File.WriteAllText(storePath, "{\"Version\":1}");
            if (store.TryLoad() is not null)
                return Fail("corrupted envelope was accepted");

            var syntheticSecret = new SessionSecret("synthetic-account", "synthetic-refresh", "synthetic-guard");
            store.Save(syntheticSecret, CancellationToken.None);
            if (store.TryLoad() != syntheticSecret || File.ReadAllText(storePath).Contains("synthetic-refresh"))
                return Fail("DPAPI roundtrip or encryption failed");
            if (!store.Forget(CancellationToken.None) || store.TryLoad() is not null)
                return Fail("forget did not remove session");

            var cancelledStore = new DpapiSessionStore(Path.Combine(tempDir, "cancelled.dpapi"));
            using var cancelled = new CancellationTokenSource();
            cancelled.Cancel();
            try
            {
                cancelledStore.Save(new SessionSecret("synthetic", "synthetic", null), cancelled.Token);
                return Fail("cancelled save was committed");
            }
            catch (OperationCanceledException)
            {
                if (cancelledStore.Exists)
                    return Fail("cancelled save left a session file");
            }

            try
            {
                await SteamJobAwaiter.AwaitAsync(new TaskCompletionSource<int>().Task,
                    CancellationToken.None, TimeSpan.FromMilliseconds(40)).ConfigureAwait(false);
                return Fail("stalled operation was not bounded");
            }
            catch (TimeoutException)
            {

            }
        }
        finally
        {
            if (Directory.Exists(tempDir))
                Directory.Delete(tempDir, recursive: true);
        }

        var invalidCli = CliParser.Parse(new[] { "--unknown" });
        var conflictingCli = CliParser.Parse(new[] { "--qr", "--auto" });
        var missingValueCli = CliParser.Parse(new[] { "--output" });
        if (invalidCli.Success || conflictingCli.Success || missingValueCli.Success)
            return Fail("invalid/conflicting CLI was accepted");

        Console.Out.WriteLine(JsonSerializer.Serialize(new SyntheticResult("synthetic_pass", new[]
            {
                "json_source_generation",
                "parser",
                "license_filtering",
                "private_skeleton",
                "family_owner_priority",
                "partial_retention",
                "cancellation",
                "stalled_job",
                "dpapi_corruption",
                "strict_cli",
                "ui_auth_input_correlation_cancel_eof_limits",
            }), ProtocolJsonContext.Default.SyntheticResult));
        return 0;
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine($"[synthetic] failed: {message}");
        return 10;
    }

    private static string DefaultDataDirectory()
    {

        var root = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        return Path.Combine(root, "CarapacikSpace", "SteamSpaceFarm", "steam");
    }

    private static void PrintUsage(TextWriter writer)
    {
        writer.WriteLine("ssf_steam_helper");
        writer.WriteLine("  --synthetic                         run offline checks");
        writer.WriteLine("  --qr                                authenticate with a QR challenge URL");
        writer.WriteLine("  --events                            emit NDJSON events and QR URL for a UI renderer");
        writer.WriteLine("  --credentials                       prompt for credentials and Guard");
        writer.WriteLine("  --auto                              restore the saved DPAPI session");
        writer.WriteLine("  --forget                            delete the saved session");
        writer.WriteLine("  --data-dir <path>                   session data directory");
        writer.WriteLine("  --output <path>                     write final JSON to this file");
        writer.WriteLine("  --timeout-seconds <n>               whole-operation deadline (default 180)");
    }
}

internal enum AuthMode
{
    Qr,
    Credentials,
    Auto,
}

internal sealed record CliOptions(
    bool ShowHelp,
    bool Synthetic,
    bool Forget,
    AuthMode AuthMode,
    string? DataDirectory,
    string? OutputPath,
    int TimeoutSeconds,
    bool Events = false);

internal sealed record CliParseResult(bool Success, CliOptions? Options, string? Error)
{
    public static CliParseResult Ok(CliOptions options) => new(true, options, null);
    public static CliParseResult Fail(string error) => new(false, null, error);
}

internal static class CliParser
{
    public static CliParseResult Parse(string[] args)
    {
        if (args.Length == 1 && args[0].Equals("--help", StringComparison.OrdinalIgnoreCase))
            return CliParseResult.Ok(new CliOptions(true, false, false, AuthMode.Qr, null, null, 180));

        var synthetic = false;
        var forget = false;
        var showHelp = false;
        var authMode = AuthMode.Qr;
        var authSpecified = false;
        string? dataDirectory = null;
        string? outputPath = null;
        var timeoutSeconds = 180;
        var events = false;
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        for (var index = 0; index < args.Length; index++)
        {
            var arg = args[index];
            if (!seen.Add(arg))
                return CliParseResult.Fail("duplicate option");
            switch (arg.ToLowerInvariant())
            {
                case "--events":
                    events = true;
                    break;
                case "--help":
                    showHelp = true;
                    break;
                case "--synthetic":
                    synthetic = true;
                    break;
                case "--forget":
                    forget = true;
                    break;
                case "--qr":
                case "--credentials":
                case "--auto":
                    if (authSpecified)
                        return CliParseResult.Fail("authentication modes conflict");
                    authSpecified = true;
                    authMode = arg.Equals("--qr", StringComparison.OrdinalIgnoreCase)
                        ? AuthMode.Qr
                        : arg.Equals("--auto", StringComparison.OrdinalIgnoreCase)
                            ? AuthMode.Auto
                            : AuthMode.Credentials;
                    break;
                case "--data-dir":
                    if (!TryReadValue(args, ref index, out dataDirectory))
                        return CliParseResult.Fail("--data-dir requires a value");
                    break;
                case "--output":
                    if (!TryReadValue(args, ref index, out outputPath))
                        return CliParseResult.Fail("--output requires a value");
                    break;
                case "--timeout-seconds":
                    if (!TryReadValue(args, ref index, out var timeoutText)
                        || !int.TryParse(timeoutText, out timeoutSeconds)
                        || timeoutSeconds <= 0 || timeoutSeconds > 86400)
                    {
                        return CliParseResult.Fail("--timeout-seconds must be between 1 and 86400");
                    }

                    break;
                default:
                    return CliParseResult.Fail($"unknown option: {arg}");
            }
        }

        if (showHelp && args.Length != 1)
            return CliParseResult.Fail("--help cannot be combined with other options");
        if (synthetic && (authSpecified || forget || dataDirectory is not null || outputPath is not null))
            return CliParseResult.Fail("--synthetic cannot be combined with auth, --forget, --data-dir, or --output");
        if (forget && authSpecified)
            return CliParseResult.Fail("--forget cannot be combined with an auth mode");
        if (forget && outputPath is not null)
            return CliParseResult.Fail("--forget cannot be combined with --output");
        if (events && (synthetic || forget || outputPath is not null))
            return CliParseResult.Fail("--events cannot be combined with --synthetic, --forget, or --output");

        try
        {
            if (dataDirectory is not null)
                dataDirectory = Path.GetFullPath(dataDirectory);
            if (outputPath is not null)
                outputPath = Path.GetFullPath(outputPath);
        }
        catch (ArgumentException)
        {
            return CliParseResult.Fail("invalid path");
        }

        return CliParseResult.Ok(new CliOptions(
            ShowHelp: showHelp,
            Synthetic: synthetic,
            Forget: forget,
            AuthMode: authMode,
            DataDirectory: dataDirectory,
            OutputPath: outputPath,
            TimeoutSeconds: timeoutSeconds,
            Events: events));
    }

    private static bool TryReadValue(string[] args, ref int index, out string? value)
    {
        value = null;
        if (index + 1 >= args.Length || args[index + 1].StartsWith("--", StringComparison.Ordinal))
            return false;
        value = args[++index];
        return !string.IsNullOrWhiteSpace(value);
    }
}
