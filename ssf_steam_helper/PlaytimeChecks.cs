using SteamKit2.Internal;

namespace SteamLibraryHelper;

internal static class PlaytimeChecks
{
    public static void Run()
    {
        var ownedMinutes = new Dictionary<uint, double>();
        PlaytimeData.AddMinutes(ownedMinutes, 480, 120, true);
        PlaytimeData.AddMinutes(ownedMinutes, 480, 60, true);
        PlaytimeData.AddMinutes(ownedMinutes, 570, 0, true);
        PlaytimeData.AddMinutes(ownedMinutes, 730, 0, false);
        PlaytimeData.AddMinutes(ownedMinutes, 1, -1, true);
        PlaytimeData.AddMinutes(ownedMinutes, 0, 20, true);
        var owned = new PlaytimeData(ownedMinutes, new Dictionary<uint, string?> { [480] = "Example" }, true, null,
            new Dictionary<uint, uint> { [480] = 1700000000, [570] = 0 });
        var historyMinutes = new Dictionary<uint, double>();
        PlaytimeData.AddMinutes(historyMinutes, 3744480, 1531, true);
        PlaytimeData.AddMinutes(historyMinutes, 480, 180, true);
        var history = new PlaytimeData(historyMinutes, new Dictionary<uint, string?>(), true, null,
            new Dictionary<uint, uint> { [480] = 1750000000, [3744480] = 1780000000 });
        var merged = PlaytimeData.Merge(owned, history);
        if (merged.Values.Count != 3 || merged.Values[480] != 3 || merged.Values[570] != 0
            || Math.Round(merged.Values[3744480] * 60) != 1531 || !merged.Complete
            || merged.Metadata[480] != "Example" || merged.LastPlayed![480] != 1750000000
            || merged.LastPlayed.ContainsKey(570) || merged.LastPlayed[3744480] != 1780000000)
        {
            throw new InvalidOperationException("Playtime overlap, missing/zero value or history-only game regression.");
        }

        foreach (var successful in new[] { owned, history })
        {
            var failed = PlaytimeData.Failed("synthetic timeout");
            foreach (var partial in new[] { PlaytimeData.Merge(successful, failed), PlaytimeData.Merge(failed, successful) })
            {
                if (partial.Complete || partial.Values.Count != successful.Values.Count || partial.Error is null)
                    throw new InvalidOperationException("A failed time source erased successful results.");
            }
        }

        var missing = new CPlayer_GetOwnedGames_Response.Game { appid = 730 };
        var zero = new CPlayer_GetLastPlayedTimes_Response.Game { appid = 570, playtime_forever = 0 };
        if (missing.ShouldSerializeplaytime_forever() || !zero.ShouldSerializeplaytime_forever())
            throw new InvalidOperationException("Protobuf missing playtime must differ from an explicit zero.");
    }
}
