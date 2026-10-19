using System.Net;
using System.Security.Cryptography;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using HtmlAgilityPack;

namespace SteamLibraryHelper;

internal sealed record CardDrop(uint AppId, string Name, int? Remaining);
internal sealed record CardSnapshot(string SteamId, bool Complete, long CheckedAt, CardDrop[] Games);

internal static class CardDropsParser
{
    private static bool HasClass(HtmlNode node, string name) =>
        node.GetAttributeValue("class", "").Split(' ', StringSplitOptions.RemoveEmptyEntries).Contains(name);

    internal static int? Remaining(HtmlNode node)
    {
        foreach (var progress in node.DescendantsAndSelf().Where(n => HasClass(n, "progress_info_bold")))
        {
            var text = HtmlEntity.DeEntitize(progress.InnerText).Trim();
            if (Regex.IsMatch(text, @"^No card drops remaining\.?$", RegexOptions.IgnoreCase)) return 0;
            var match = Regex.Match(text, @"^(\d+) card drops? remaining\.?$", RegexOptions.IgnoreCase);
            if (match.Success && int.TryParse(match.Groups[1].Value, out var count)) return count;
        }
        return null;
    }

    internal static HtmlDocument Document(string html, ulong steamId)
    {
        var document = new HtmlDocument();
        document.LoadHtml(html);
        // A login page or a different account must never become an empty inventory.
        var authenticated = document.DocumentNode.Descendants("script").Any(n =>
            Regex.IsMatch(n.InnerText, @"\bg_steamID\s*=\s*['" + "\"" + @"]" + steamId + @"['" + "\"" + @"]"));
        if (!authenticated) throw new InvalidDataException("community_auth_required");
        return document;
    }

    internal static (CardDrop[] Games, int Pages, bool Complete) Badges(string html, ulong steamId)
    {
        var document = Document(html, steamId);
        var result = new Dictionary<uint, CardDrop>();
        bool complete = true;
        var rows = document.DocumentNode.Descendants().Where(n => HasClass(n, "badge_row")).ToArray();
        foreach (var row in rows)
        {
            var href = row.Descendants("a").Select(n => HtmlEntity.DeEntitize(n.GetAttributeValue("href", "")))
                .FirstOrDefault(h => Regex.IsMatch(h, @"/gamecards/\d+"));
            if (href is null || Regex.IsMatch(href, @"[?&]border=1(?:&|$)")) continue;
            var match = Regex.Match(href, @"/gamecards/(\d+)");
            if (!uint.TryParse(match.Groups[1].Value, out var appId) || appId == 0) { complete = false; continue; }
            var title = row.Descendants().FirstOrDefault(n => HasClass(n, "badge_title"));
            var name = HtmlEntity.DeEntitize(title?.ChildNodes.FirstOrDefault(n => n.NodeType == HtmlNodeType.Text)?.InnerText ?? "").Trim();
            var remaining = Remaining(row);
            if (remaining is null) complete = false;
            if (result.TryGetValue(appId, out var old) && old.Remaining != remaining)
            { remaining = null; complete = false; }
            result[appId] = new(appId, name.Length == 0 ? $"App {appId}" : name, remaining);
        }
        int pages = 1;
        foreach (var link in document.DocumentNode.Descendants("a").Where(n => HasClass(n, "pagelink")))
        {
            var match = Regex.Match(HtmlEntity.DeEntitize(link.GetAttributeValue("href", "")), @"[?&]p=(\d+)");
            if (match.Success && int.TryParse(match.Groups[1].Value, out int page)) pages = Math.Max(pages, page);
        }
        // An unexpected empty layout is unknown, not proof that every game is complete.
        return (result.Values.ToArray(), pages, complete && rows.Length > 0);
    }
}

internal sealed class CardDropsClient : IDisposable
{
    private readonly SteamLibraryClient _steam;
    private readonly SessionSecret _secret;
    private readonly CookieContainer _cookies = new();
    private readonly HttpClient _http;
    private bool _authenticated;
    private DateTimeOffset _nextRequest;
    internal CardDropsClient(SteamLibraryClient steam, SessionSecret secret)
    {
        _steam = steam; _secret = secret;
        _http = new(new HttpClientHandler { CookieContainer = _cookies, AllowAutoRedirect = false,
            AutomaticDecompression = DecompressionMethods.All }) { Timeout = TimeSpan.FromSeconds(25) };
        _http.DefaultRequestHeaders.UserAgent.ParseAdd("SteamSpaceFarm/2.2");
    }

    private async Task Authenticate(CancellationToken token)
    {
        var accessToken = await _steam.GetWebAccessTokenAsync(_secret, token).ConfigureAwait(false);
        var origin = new Uri("https://steamcommunity.com/");
        _cookies.Add(origin, new Cookie("steamLoginSecure", $"{_steam.SteamId}||{accessToken}", "/") { Secure = true, HttpOnly = true });
        _cookies.Add(origin, new Cookie("sessionid", Convert.ToHexString(RandomNumberGenerator.GetBytes(12)), "/") { Secure = true });
        _authenticated = true;
    }

    private async Task<string> Page(string path, CancellationToken token)
    {
        for (int authAttempt = 0; authAttempt < 2; authAttempt++)
        {
            if (!_authenticated) await Authenticate(token).ConfigureAwait(false);
            var uri = new Uri("https://steamcommunity.com" + path);
            for (int redirect = 0; redirect < 5; redirect++)
            {
                var delay = _nextRequest - DateTimeOffset.UtcNow;
                if (delay > TimeSpan.Zero) await Task.Delay(delay, token).ConfigureAwait(false);
                _nextRequest = DateTimeOffset.UtcNow.AddSeconds(1);
                using var response = await _http.GetAsync(uri, HttpCompletionOption.ResponseHeadersRead, token).ConfigureAwait(false);
                if ((int)response.StatusCode is >= 300 and < 400)
                {
                    var location = response.Headers.Location ?? throw new IOException("community_redirect");
                    uri = location.IsAbsoluteUri ? location : new Uri(uri, location);
                    if (uri.Scheme != "https" || uri.Host != "steamcommunity.com" || !uri.IsDefaultPort)
                        throw new IOException("community_redirect");
                    continue;
                }
                if (response.StatusCode == HttpStatusCode.TooManyRequests)
                { _nextRequest = DateTimeOffset.UtcNow.AddMinutes(2); throw new IOException("community_rate_limit"); }
                response.EnsureSuccessStatusCode();
                if (response.Content.Headers.ContentLength > 8 * 1024 * 1024) throw new IOException("community_size");
                await using var stream = await response.Content.ReadAsStreamAsync(token).ConfigureAwait(false);
                using var buffer = new MemoryStream();
                var bytes = new byte[8192];
                int read;
                while ((read = await stream.ReadAsync(bytes, token).ConfigureAwait(false)) > 0)
                {
                    if (buffer.Length + read > 8 * 1024 * 1024) throw new IOException("community_size");
                    buffer.Write(bytes, 0, read);
                }
                var html = System.Text.Encoding.UTF8.GetString(buffer.ToArray());
                try { CardDropsParser.Document(html, _steam.SteamId); }
                catch (InvalidDataException) when (authAttempt == 0) { _authenticated = false; break; }
                var requestedGame = Regex.Match(path, @"/gamecards/(\d+)");
                if (requestedGame.Success && !Regex.IsMatch(uri.AbsolutePath,
                    @"/gamecards/" + requestedGame.Groups[1].Value + @"/?$"))
                    throw new InvalidDataException("community_game_redirect");
                return html;
            }
        }
        throw new InvalidDataException("community_auth_required");
    }

    internal async Task<CardSnapshot> ReadAsync(uint[] appIds, CancellationToken token)
    {
        var games = new Dictionary<uint, CardDrop>();
        bool complete = true;
        if (appIds.Length > 0)
        {
            foreach (var id in appIds.Distinct())
            {
                var html = await Page($"/profiles/{_steam.SteamId}/gamecards/{id}?l=english", token).ConfigureAwait(false);
                var count = CardDropsParser.Remaining(CardDropsParser.Document(html, _steam.SteamId).DocumentNode);
                games[id] = new(id, $"App {id}", count);
                complete &= count is not null;
            }
        }
        else
        {
            int pages = 1;
            for (int page = 1; page <= pages; page++)
            {
                var html = await Page($"/profiles/{_steam.SteamId}/badges/?l=english&p={page}", token).ConfigureAwait(false);
                var result = CardDropsParser.Badges(html, _steam.SteamId);
                if (result.Pages > 200) throw new InvalidDataException("community_pagination");
                pages = Math.Max(pages, result.Pages);
                complete &= result.Complete;
                foreach (var game in result.Games)
                {
                    if (games.TryGetValue(game.AppId, out var old) && old.Remaining != game.Remaining)
                    { complete = false; games[game.AppId] = game with { Remaining = null }; }
                    else games[game.AppId] = game;
                }
            }
        }
        return new(_steam.SteamId.ToString(), complete, DateTimeOffset.UtcNow.ToUnixTimeSeconds(), games.Values.ToArray());
    }
    public void Dispose() => _http.Dispose();
}

internal sealed record SessionDataEvent(int V, string Event, string SteamId, string RequestId,
    CardSnapshot? Cards = null, Dictionary<uint, int>? Minutes = null, string? Error = null);

[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
[JsonSerializable(typeof(SessionDataEvent))]
internal partial class SessionDataJsonContext : JsonSerializerContext { }
