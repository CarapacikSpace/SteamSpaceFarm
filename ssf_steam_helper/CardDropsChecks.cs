namespace SteamLibraryHelper;

internal static class CardDropsChecks
{
    internal static void Run()
    {
        const ulong account = 76561198000000001;
        const string identity = "<script>var g_steamID = '76561198000000001';</script>";
        static string Row(int id, string progress, string suffix = "") =>
            $"<div data-panel='x' class='badge_row is_link'><a href='/id/test/gamecards/{id}{suffix}'></a>" +
            $"<div class='badge_title'>A &amp; B<div>Level 1</div></div><span class='progress_info_bold'>{progress}</span></div>";
        var parsed = CardDropsParser.Badges(identity + Row(570, "18 card drops remaining") +
            Row(480, "No card drops remaining") + Row(10, "1 card drop remaining", "?border=1") +
            "<a class='pagelink' href='?l=english&amp;p=5'>5</a>", account);
        if (!parsed.Complete || parsed.Pages != 5 || parsed.Games.Length != 2 ||
            parsed.Games.Single(g => g.AppId == 570).Remaining != 18 ||
            parsed.Games.Single(g => g.AppId == 480).Remaining != 0 || parsed.Games[0].Name != "A & B")
            throw new InvalidOperationException("Card parsing failed");
        var unknown = CardDropsParser.Badges(identity + Row(570, "Unexpected layout"), account);
        if (unknown.Complete || unknown.Games.Single().Remaining != null)
            throw new InvalidOperationException("Unknown card count became zero");
        var conflict = CardDropsParser.Badges(identity + Row(570, "1 card drop remaining") + Row(570, "No card drops remaining"), account);
        if (conflict.Complete || conflict.Games.Single().Remaining != null)
            throw new InvalidOperationException("Conflicting duplicate accepted");
        if (CardDropsParser.Badges(identity + "<div>Unexpected empty page</div>", account).Complete)
            throw new InvalidOperationException("Empty layout accepted");
        try { CardDropsParser.Badges(identity, account + 1); throw new InvalidOperationException("Wrong account accepted"); }
        catch (InvalidDataException) { }
        try { CardDropsParser.Badges("<form>Sign in</form>", account); throw new InvalidOperationException("Login accepted"); }
        catch (InvalidDataException) { }
    }
}
