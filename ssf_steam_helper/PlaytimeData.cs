namespace SteamLibraryHelper;

internal sealed record PlaytimeData(
    IReadOnlyDictionary<uint, double> Values,
    IReadOnlyDictionary<uint, string?> Metadata,
    bool Complete,
    string? Error,
    IReadOnlyDictionary<uint, uint>? LastPlayed = null)
{
    public static PlaytimeData Failed(string error) => new(
        new Dictionary<uint, double>(), new Dictionary<uint, string?>(), false, error);

    public static void AddMinutes(Dictionary<uint, double> values, int appId, int minutes, bool hasMinutes)
    {
        if (appId <= 0 || minutes < 0 || !hasMinutes) return;
        var id = (uint)appId;

        values[id] = Math.Max(values.GetValueOrDefault(id), minutes / 60d);
    }

    public static PlaytimeData Merge(PlaytimeData owned, PlaytimeData history)
    {
        var values = new Dictionary<uint, double>(owned.Values);
        foreach (var (id, hours) in history.Values)
            values[id] = Math.Max(values.GetValueOrDefault(id), hours);
        var lastPlayed = new Dictionary<uint, uint>();
        foreach (var source in new[] { owned.LastPlayed, history.LastPlayed })
        {
            if (source is not null)
            {
                foreach (var (id, timestamp) in source)
                {
                    if (id > 0 && timestamp > 0)
                        lastPlayed[id] = Math.Max(lastPlayed.GetValueOrDefault(id), timestamp);
                }
            }
        }

        return new(values, owned.Metadata, owned.Complete && history.Complete,
            string.Join("; ", new[] { owned.Error, history.Error }.Where(error => error is not null)) is { Length: > 0 } error
                ? error : null, lastPlayed);
    }
}
