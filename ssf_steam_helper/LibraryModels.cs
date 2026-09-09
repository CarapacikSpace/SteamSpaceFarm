using System.Globalization;

namespace SteamLibraryHelper;

public sealed record LibraryEntry(
    uint AppId,
    string? Ownership,
    string? Name,
    double? Hours,
    string MetadataStatus,
    string HoursStatus,
    string? Type = null,
    long? LastPlayedAtUnixSeconds = null);

public sealed record SourceReport(
    string Status,
    int ItemCount,
    string? Detail = null);

public sealed record SourceCoverage(
    SourceReport PersonalLicenses,
    SourceReport PrivateApps,
    SourceReport Family,
    SourceReport Metadata,
    SourceReport Hours);

public sealed record SteamLibraryResult(
    int SchemaVersion,
    string SteamId,
    bool Partial,
    SourceCoverage Sources,
    IReadOnlyList<LibraryEntry> Apps,
    IReadOnlyList<string> Diagnostics);

public sealed record SourceData<T>(
    IReadOnlyCollection<T> Items,
    bool Complete,
    string? Error = null);

public sealed record LibraryEvidence(
    ulong SteamId,
    SourceData<uint> PersonalLicenses,
    SourceData<uint> PrivateApps,
    SourceData<uint> FamilyApps,
    SourceData<uint> FamilyPersonalApps,
    IReadOnlyDictionary<uint, string?> Metadata,
    bool MetadataComplete,
    string? MetadataError,
    IReadOnlyDictionary<uint, double> Hours,
    bool HoursComplete,
    string? HoursError,
    SourceReport FamilyReport,
    IReadOnlyList<string> Diagnostics,
    IReadOnlyDictionary<uint, string?>? Types = null,
    IReadOnlyDictionary<uint, uint>? LastPlayed = null);

public static class LibraryMerger
{
    public static SteamLibraryResult Merge(LibraryEvidence evidence)
    {
        var ids = new HashSet<uint>(evidence.PersonalLicenses.Items);
        ids.UnionWith(evidence.PrivateApps.Items);
        ids.UnionWith(evidence.FamilyApps.Items);
        ids.UnionWith(evidence.FamilyPersonalApps.Items);
        ids.UnionWith(evidence.Metadata.Keys);
        ids.UnionWith(evidence.Hours.Keys);
        ids.Remove(0);

        var apps = ids
            .OrderBy(id => id)
            .Select(id =>
            {
                var isPersonal = evidence.PersonalLicenses.Items.Contains(id)
                    || evidence.FamilyPersonalApps.Items.Contains(id);
                var isFamily = evidence.FamilyApps.Items.Contains(id);
                var ownership = isPersonal ? "personal" : isFamily ? "family" : null;

                evidence.Metadata.TryGetValue(id, out var name);
                evidence.Hours.TryGetValue(id, out var hours);

                return new LibraryEntry(
                    id,
                    ownership,
                    string.IsNullOrWhiteSpace(name) ? null : name,
                    evidence.Hours.ContainsKey(id) ? hours : null,
                    !string.IsNullOrWhiteSpace(name) ? "complete" : "missing",
                    evidence.Hours.ContainsKey(id) ? "complete" : "unknown",
                    evidence.Types?.GetValueOrDefault(id),
                    evidence.LastPlayed?.GetValueOrDefault(id) is > 0 and var timestamp ? timestamp : null);
            })
            .ToArray();

        var partial = !evidence.PersonalLicenses.Complete
            || !evidence.PrivateApps.Complete
            || !evidence.FamilyApps.Complete
            || !evidence.FamilyPersonalApps.Complete
            || !evidence.FamilyReport.Status.Equals("complete", StringComparison.OrdinalIgnoreCase)
            || !evidence.MetadataComplete
            || !evidence.HoursComplete
            || apps.Any(app => app.MetadataStatus != "complete" || app.HoursStatus != "complete");

        var sourceCoverage = new SourceCoverage(
            new SourceReport(
                evidence.PersonalLicenses.Complete ? "complete" : "partial",
                evidence.PersonalLicenses.Items.Count,
                evidence.PersonalLicenses.Error),
            new SourceReport(
                evidence.PrivateApps.Complete ? "complete" : "partial",
                evidence.PrivateApps.Items.Count,
                evidence.PrivateApps.Error),
            evidence.FamilyReport,
            new SourceReport(
                evidence.MetadataComplete && apps.All(app => app.MetadataStatus == "complete") ? "complete" : "partial",
                apps.Count(app => app.MetadataStatus == "complete"),
                evidence.MetadataError),
            new SourceReport(
                evidence.HoursComplete && apps.All(app => app.HoursStatus == "complete") ? "complete" : "partial",
                evidence.Hours.Count,
                evidence.HoursError));

        return new SteamLibraryResult(
            SchemaVersion: 1,
            SteamId: evidence.SteamId.ToString(CultureInfo.InvariantCulture),
            Partial: partial,
            Sources: sourceCoverage,
            Apps: apps,
            Diagnostics: evidence.Diagnostics);
    }
}

public sealed class AuthOperation
{
    public long Generation { get; private set; }
    public string State { get; private set; } = "idle";

    public long BeginQr()
    {
        Generation++;
        State = "waiting_for_qr";
        return Generation;
    }

    public bool UpdateChallenge(long generation)
    {
        if (generation != Generation || State is "cancelled" or "completed")
            return false;

        State = "waiting_for_confirmation";
        return true;
    }

    public bool Complete(long generation)
    {
        if (generation != Generation || State is "cancelled" or "completed")
            return false;

        State = "completed";
        return true;
    }

    public void Cancel() => State = "cancelled";
}

public sealed record SessionSecret(string AccountName, string RefreshToken, string? GuardData);
