using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Channels;

namespace SteamLibraryHelper;

// A single Steam connection owns the complete GamesPlayed list. Per-game logins
// would replace each other and cannot safely implement concurrent sessions.
internal static class SteamKitPlayHost
{
    public static async Task<int> RunAsync(string[] args)
    {
        if ((args.Length != 5 && (args.Length != 6 || args[5] != "--invisible")) || args[1] != "--data-dir" || args[3] != "--expected-steam-id"
            || !ulong.TryParse(args[4], out var expectedId) || expectedId == 0)
            return 2;
        using var lifetime = new CancellationTokenSource();
        lifetime.CancelAfter(TimeSpan.FromSeconds(60));
        var token = lifetime.Token;
        var commands = Channel.CreateBounded<string>(32);
        var input = ReadInputAsync(commands.Writer, lifetime);
        using var client = new SteamLibraryClient();
        var games = new SteamKitGames();
        try
        {
            var secret = new DpapiSessionStore(Path.Combine(args[2], "session.dpapi")).TryLoad()
                ?? throw new InvalidOperationException("session_required");
            await client.StartAsync().ConfigureAwait(false);
            await client.WaitConnectedAsync(token).ConfigureAwait(false);
            await client.AuthenticateStoredAsync(secret, token).ConfigureAwait(false);
            if (client.SteamId != expectedId) throw new InvalidOperationException("account_mismatch");
            client.BeginPlayingSession(invisible: args.Length == 6);
            lifetime.CancelAfter(Timeout.InfiniteTimeSpan);
            Emit("session_ready", "", 0, expectedId);
            var readable = commands.Reader.WaitToReadAsync(token).AsTask();
            while (!token.IsCancellationRequested)
            {
                await Task.WhenAny(readable, Task.Delay(200, token), client.ConnectionLost).ConfigureAwait(false);
                token.ThrowIfCancellationRequested();
                if (client.ConnectionLost.IsCompleted) throw new IOException("steam_disconnected");
                if (readable.IsCompleted)
                {
                    if (!await readable.ConfigureAwait(false)) break;
                    while (commands.Reader.TryRead(out var line))
                    {
                        using var json = JsonDocument.Parse(line);
                        var command = SteamKitCommand.Parse(json.RootElement);
                        if (command.Command == "stop_all") return 0;
                        var changed = games.Apply(command);
                        // Send the complete remaining set before acknowledging a change.
                        client.SetPlayingGames(games.AppIds);
                        Emit(changed, command.RunId, command.AppId, expectedId);
                    }
                    readable = commands.Reader.WaitToReadAsync(token).AsTask();
                }
                foreach (var expired in games.Expire())
                {
                    client.SetPlayingGames(games.AppIds);
                    Emit("stopped", expired.RunId, expired.AppId, expectedId);
                }
            }
            return 0;
        }
        catch (OperationCanceledException) { return 4; }
        catch (Exception error)
        {
            Console.Error.WriteLine($"[steamkit] {error.GetType().Name}");
            Emit("session_failed", "", 0, expectedId);
            return 6;
        }
        finally
        {
            try { client.SetPlayingGames(Array.Empty<uint>()); } catch { }
            lifetime.Cancel();
            try { await input.WaitAsync(TimeSpan.FromSeconds(1)).ConfigureAwait(false); } catch { }
        }
    }

    private static void Emit(string kind, string runId, uint appId, ulong steamId)
    {
        Console.Out.WriteLine(JsonSerializer.Serialize(new SteamKitEvent(1, kind, runId, appId, steamId.ToString()),
            SteamKitJsonContext.Default.SteamKitEvent));
        Console.Out.Flush();
    }

    private static async Task ReadInputAsync(ChannelWriter<string> writer, CancellationTokenSource lifetime)
    {
        try
        {
            using var stream = Console.OpenStandardInput();
            var bytes = new byte[1024];
            var line = new List<byte>();
            var encoding = new UTF8Encoding(false, true);
            while (true)
            {
                int count = await stream.ReadAsync(bytes, lifetime.Token).ConfigureAwait(false);
                if (count == 0) break; // Closing the parent pipe always ends the Steam session.
                for (int i = 0; i < count; i++)
                {
                    if (bytes[i] == '\n')
                    {
                        await writer.WriteAsync(encoding.GetString(line.ToArray()), lifetime.Token).ConfigureAwait(false);
                        line.Clear();
                    }
                    else
                    {
                        if (line.Count >= 4096) throw new InvalidDataException("frame_too_large");
                        line.Add(bytes[i]);
                    }
                }
            }
        }
        catch (Exception error) { writer.TryComplete(error); }
        finally { writer.TryComplete(); lifetime.Cancel(); }
    }

    internal static void RunChecks()
    {
        var message = SteamLibraryClient.CreateGamesPlayedMessage(new uint[] { 632360, 230410 });
        if (message.MsgType != SteamKit2.EMsg.ClientGamesPlayedWithDataBlob
            || message.Body.client_os_type != (uint)SteamKit2.EOSType.Win11
            || !message.Body.games_played.Select(game => new SteamKit2.GameID(game.game_id).AppID)
                .SequenceEqual(new uint[] { 632360, 230410 }))
            throw new InvalidOperationException("SteamKit playing message failed");
        if (SteamLibraryClient.CreateGamesPlayedMessage(Array.Empty<uint>()).Body.games_played.Count != 0)
            throw new InvalidOperationException("SteamKit stop message failed");
        var games = new SteamKitGames();
        var first = new SteamKitCommand("start", "first", 632360, null);
        var second = new SteamKitCommand("start", "second", 230410, null);
        if (games.Apply(first) != "ready" || games.Apply(second) != "ready" || games.AppIds.Count() != 2)
            throw new InvalidOperationException("SteamKit concurrent games failed");
        games.Apply(first with { Command = "stop" });
        if (!games.AppIds.SequenceEqual(new uint[] { 230410 })) throw new InvalidOperationException("SteamKit independent stop failed");
        games.Apply(second with { Command = "update_deadline", RunSeconds = 1 });
        games.Apply(second with { Command = "update_deadline", RunSeconds = null });
        if (games.Expire().Count != 0) throw new InvalidOperationException("SteamKit deadline removal failed");
        using var invalid = JsonDocument.Parse("{\"v\":1,\"command\":\"start\",\"runId\":\"bad\",\"appId\":0}");
        try { SteamKitCommand.Parse(invalid.RootElement); throw new InvalidOperationException("Invalid AppID accepted"); }
        catch (FormatException) { }
    }
}

internal sealed record SteamKitCommand(string Command, string RunId, uint AppId, long? RunSeconds)
{
    public static SteamKitCommand Parse(JsonElement value)
    {
        if (value.GetProperty("v").GetInt32() != 1) throw new FormatException("version");
        var command = value.GetProperty("command").GetString();
        if (command == "stop_all") return new(command, "", 0, null);
        if (command is not ("start" or "stop" or "update_deadline")) throw new FormatException("command");
        var runId = value.GetProperty("runId").GetString();
        var appId = value.GetProperty("appId").GetUInt32();
        long? seconds = value.TryGetProperty("runSeconds", out var duration) && duration.ValueKind != JsonValueKind.Null
            ? duration.GetInt64() : null;
        if (appId == 0 || string.IsNullOrEmpty(runId) || runId.Length > 128 || seconds is <= 0 or > 315360000)
            throw new FormatException("arguments");
        return new(command, runId, appId, seconds);
    }
}

internal sealed class SteamKitGames
{
    private readonly Dictionary<string, (uint AppId, TimeSpan? Deadline)> _games = new();
    private readonly Stopwatch _clock = Stopwatch.StartNew();
    public IEnumerable<uint> AppIds => _games.Values.Select(game => game.AppId);
    public string Apply(SteamKitCommand command)
    {
        var deadline = command.RunSeconds is long seconds ? _clock.Elapsed + TimeSpan.FromSeconds(seconds) : (TimeSpan?)null;
        if (command.Command == "start")
        {
            if (_games.Count >= 30 || _games.ContainsKey(command.RunId) || AppIds.Contains(command.AppId))
                throw new FormatException("duplicate_or_limit");
            _games.Add(command.RunId, (command.AppId, deadline));
            return "ready";
        }
        if (!_games.TryGetValue(command.RunId, out var current) || current.AppId != command.AppId)
        {
            // A deadline can expire just before a stop/deadline update arrives.
            return "stopped";
        }
        if (command.Command == "stop") { _games.Remove(command.RunId); return "stopped"; }
        _games[command.RunId] = (current.AppId, deadline);
        return "deadline_updated";
    }
    public List<(string RunId, uint AppId)> Expire()
    {
        var expired = _games.Where(pair => pair.Value.Deadline is TimeSpan end && end <= _clock.Elapsed)
            .Select(pair => (RunId: pair.Key, pair.Value.AppId)).ToList();
        foreach (var game in expired) _games.Remove(game.RunId);
        return expired;
    }
}

internal sealed record SteamKitEvent(
    [property: JsonPropertyName("v")] int Version,
    [property: JsonPropertyName("event")] string Event,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("appId")] uint AppId,
    [property: JsonPropertyName("steamId")] string SteamId);

[JsonSerializable(typeof(SteamKitEvent))]
internal partial class SteamKitJsonContext : JsonSerializerContext { }
