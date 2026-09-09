using SteamKit2;
using static SteamKit2.SteamApps;

namespace SteamLibraryHelper;

public static class SteamParsing
{
    private const ELicenseFlags RejectedFlags =
        ELicenseFlags.Borrowed
        | ELicenseFlags.Expired
        | ELicenseFlags.CancelledByUser
        | ELicenseFlags.CancelledByAdmin
        | ELicenseFlags.CancelledByFriendlyFraudLock
        | ELicenseFlags.CancelledByPartner
        | ELicenseFlags.Pending
        | ELicenseFlags.PendingRefund
        | ELicenseFlags.RenewalFailed
        | ELicenseFlags.NotActivated
        | ELicenseFlags.NonPermanent;

    public static bool IsPersonalLicense(LicenseListCallback.License license)
        => IsPersonalLicense(license.LicenseType, license.LicenseFlags);

    public static bool IsPersonalLicense(ELicenseType licenseType, ELicenseFlags licenseFlags)
        => licenseType != ELicenseType.NoLicense
            && (licenseFlags & RejectedFlags) == ELicenseFlags.None;

    public static HashSet<uint> ParsePackageAppIds(IEnumerable<KeyValue> packages)
    {
        var appIds = new HashSet<uint>();
        foreach (var package in packages)
        {
            var appIdsNode = package?["appids"];
            if (appIdsNode is null || appIdsNode == KeyValue.Invalid)
                continue;

            foreach (var child in appIdsNode.Children)
            {
                if (uint.TryParse(child.Value, out var appId) && appId > 0)
                    appIds.Add(appId);
            }
        }

        return appIds;
    }

    public static bool HasOtherOwner(IEnumerable<ulong> owners, ulong steamId)
        => owners.Any(owner => owner != 0 && owner != steamId);

    public static CompletenessAssessment AssessCompleteness(
        IEnumerable<uint> requested,
        IEnumerable<uint> returned,
        int missingTokenCount,
        int unknownCount,
        bool transportComplete,
        int rejectedCount = 0)
    {
        var requestedSet = requested.ToHashSet();
        var returnedSet = returned.ToHashSet();
        var missingRequested = requestedSet.Except(returnedSet).Count();
        var detail = new List<string>();
        if (!transportComplete)
            detail.Add("transportIncomplete");
        if (missingTokenCount > 0)
            detail.Add($"missingToken={missingTokenCount}");
        if (unknownCount > 0)
            detail.Add($"unknown={unknownCount}");
        if (missingRequested > 0)
            detail.Add($"missingRequested={missingRequested}");
        if (rejectedCount > 0)
            detail.Add($"rejected={rejectedCount}");
        return new CompletenessAssessment(
            detail.Count == 0,
            string.Join(", ", detail));
    }
}

public sealed record CompletenessAssessment(bool Complete, string Detail);

public static class SteamJobAwaiter
{
    public static Task<T> WaitAsync<T>(this AsyncJob<T> job, CancellationToken cancellationToken)
        where T : CallbackMsg
        => AwaitAsync(job.ToTask(), cancellationToken);

    public static Task<AsyncJobMultiple<T>.ResultSet> WaitAsync<T>(
        this AsyncJobMultiple<T> job,
        CancellationToken cancellationToken)
        where T : CallbackMsg
        => AwaitAsync(job.ToTask(), cancellationToken);

    public static Task<T> AwaitAsync<T>(Task<T> task, CancellationToken cancellationToken,
        TimeSpan? timeout = null)
        => task.WaitAsync(timeout ?? TimeSpan.FromSeconds(20), cancellationToken);
}
