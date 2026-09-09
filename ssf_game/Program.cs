using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Channels;

namespace SteamGame;

internal static class Program
{
    public static int Main(string[] args)
    {
        using var input = Console.OpenStandardInput();
        return RunnerApp.Execute(args, new SteamApiAdapter(), input, Console.Out, Console.Error, new RunnerClock());
    }
}

internal static class RunnerApp
{
    internal static int Execute(string[] args, IRunnerSteamApi api, Stream input, TextWriter output, TextWriter error, IRunnerClock clock)
    {
        var options = RunnerOptions.Parse(args, error);
        if (options is null) return 2;
        void Emit(string kind, string? code = null, string? reason = null, ulong? steamId = null, long? seconds = null)
        {
            if (!options.Managed) return;
            var value = new ProtocolEvent(1, kind, options.RunId, options.AppId, steamId?.ToString(), code, reason, seconds);
            output.WriteLine(JsonSerializer.Serialize(value, ProtocolJsonContext.Default.ProtocolEvent));
            output.Flush();
        }
        int Fail(int code, string name)
        {
            error.WriteLine(name);
            Emit("failed", code: name);
            return code;
        }
        if (options.Managed && options.ExpectedSteamId is null) return Fail(2, "expected_steam_id_required");
        if (options.JobName is not null)
        {
            try { WindowsRunnerJob.Join(options.JobName); }
            catch (Exception) { return Fail(21, "job_setup_failed"); }
        }

        Environment.SetEnvironmentVariable("SteamAppId", options.AppId.ToString());
        var lifecycle = new RunnerLifecycle(api);
        try
        {
            var initialized = lifecycle.Initialize(options.ExpectedSteamId);
            if (!initialized.Success)
            {
                var code = initialized.ErrorCode switch
                {
                    "account_mismatch" => 12,
                    "dll_missing" or "dll_architecture" or "dll_entrypoint" => 11,
                    "init_failed" => 10,
                    _ => 20,
                };
                return Fail(code, initialized.ErrorCode!);
            }
            Emit("ready", steamId: initialized.SteamId);
            var deadline = Deadline(clock, options.RunSeconds);
            using var reader = options.Managed ? new CommandReader(input) : null;
            while (true)
            {
                lifecycle.RunCallbacks();
                if (clock.Timestamp >= deadline)
                {
                    Emit("stopped", reason: "deadline");
                    return 0;
                }
                if (reader is not null)
                {

                    for (var i = 0; i < 16 && reader.Channel.Reader.TryRead(out var item); i++)
                    {
                        if (item.Error is not null) return Fail(2, item.Error);
                        if (item.Eof)
                        {
                            Emit("stopped", reason: "eof");
                            return 0;
                        }
                        if (!RunnerCommand.TryParse(item.Text!, out var command)) return Fail(2, "invalid_command");
                        if (command.Stop)
                        {
                            Emit("stopping", reason: "command");
                            return 0;
                        }
                        deadline = Deadline(clock, command.RunSeconds);
                        Emit("deadline_updated", seconds: command.RunSeconds);
                    }
                    if (reader.Channel.Reader.Completion.IsCompleted && !reader.Channel.Reader.TryPeek(out _))
                    {

                        return Fail(2, "input_closed_without_eof");
                    }
                }
                clock.Sleep();
            }
        }
        catch (Exception exception)
        {
            error.WriteLine($"runner_error: {exception.GetType().Name}");
            Emit("failed", code: "runtime_error");
            return 20;
        }
        finally
        {
            lifecycle.ShutdownOnce(error);
        }
    }

    private static long Deadline(IRunnerClock clock, long? seconds)
    {
        if (seconds is null) return long.MaxValue;

        var remaining = long.MaxValue - clock.Timestamp;
        return seconds.Value > remaining / clock.Frequency ? long.MaxValue : clock.Timestamp + seconds.Value * clock.Frequency;
    }
}

internal interface IRunnerClock
{
    long Timestamp { get; }
    long Frequency { get; }
    void Sleep();
}

internal sealed class RunnerClock : IRunnerClock
{
    public long Timestamp => Stopwatch.GetTimestamp();
    public long Frequency => Stopwatch.Frequency;
    public void Sleep() => Thread.Sleep(100);
}

internal readonly record struct RunnerCommand(bool Stop, long? RunSeconds)
{
    public static bool TryParse(string input, out RunnerCommand command)
    {
        command = default;
        try
        {
            using var json = JsonDocument.Parse(input, new JsonDocumentOptions { MaxDepth = 8 });
            var root = json.RootElement;
            if (root.ValueKind != JsonValueKind.Object || !root.TryGetProperty("command", out var name) || name.ValueKind != JsonValueKind.String) return false;
            if (name.GetString() == "stop") { command = new(true, null); return true; }
            if (name.GetString() != "update_deadline" || !root.TryGetProperty("runSeconds", out var value)) return false;
            if (value.ValueKind == JsonValueKind.Null) { command = new(false, null); return true; }
            if (value.ValueKind != JsonValueKind.Number || !value.TryGetInt64(out var seconds) || seconds <= 0) return false;
            command = new(false, seconds);
            return true;
        }
        catch (JsonException) { return false; }
    }
}

internal sealed class CommandReader : IDisposable
{
    private readonly CancellationTokenSource cancellation = new();
    private readonly Task producer;
    public Channel<CommandItem> Channel { get; } = System.Threading.Channels.Channel.CreateBounded<CommandItem>(
        new BoundedChannelOptions(16) { FullMode = BoundedChannelFullMode.Wait, SingleReader = true, SingleWriter = true });

    public CommandReader(Stream input) => producer = Task.Run(() => ReadAsync(input, cancellation.Token));

    private async Task ReadAsync(Stream input, CancellationToken token)
    {
        try
        {
            var buffer = new byte[512];
            var line = new List<byte>(4096);
            var encoding = new UTF8Encoding(false, true);
            while (true)
            {
                var count = await input.ReadAsync(buffer, token);
                if (count == 0)
                {
                    if (line.Count > 0) await Channel.Writer.WriteAsync(new(false, encoding.GetString(line.ToArray()), null), token);
                    await Channel.Writer.WriteAsync(new(true, null, null), token);
                    return;
                }
                for (var i = 0; i < count; i++)
                {
                    if (buffer[i] == '\n')
                    {
                        await Channel.Writer.WriteAsync(new(false, encoding.GetString(line.ToArray()).TrimEnd('\r'), null), token);
                        line.Clear();
                    }
                    else
                    {
                        if (line.Count >= 4096)
                        {
                            await Channel.Writer.WriteAsync(new(false, null, "frame_too_large"), token);
                            return;
                        }
                        line.Add(buffer[i]);
                    }
                }
            }
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception)
        {
            try { await Channel.Writer.WriteAsync(new(false, null, "input_read_error"), token); }
            catch (OperationCanceledException) { }
        }
        finally { Channel.Writer.TryComplete(); }
    }

    public void Dispose()
    {
        cancellation.Cancel();

        _ = producer.ContinueWith(_ => cancellation.Dispose(), TaskScheduler.Default);
    }
}

internal readonly record struct CommandItem(bool Eof, string? Text, string? Error);

internal sealed record ProtocolEvent(
    [property: JsonPropertyName("v")] int Version,
    [property: JsonPropertyName("event")] string Event,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("appId")] uint AppId,
    [property: JsonPropertyName("steamId")] string? SteamId,
    [property: JsonPropertyName("code")] string? Code,
    [property: JsonPropertyName("reason")] string? Reason,
    [property: JsonPropertyName("runSeconds")] long? RunSeconds);

[JsonSerializable(typeof(ProtocolEvent))]
internal partial class ProtocolJsonContext : JsonSerializerContext { }

internal sealed record RunnerOptions(uint AppId, bool Managed, ulong? ExpectedSteamId, long? RunSeconds, string RunId, string? JobName)
{
    public static RunnerOptions? Parse(string[] args, TextWriter error)
    {
        RunnerOptions? Invalid(string message) { error.WriteLine(message); return null; }
        if (args.Length == 0 || !uint.TryParse(args[0], out var appId) || appId == 0) return Invalid("invalid_app_id");
        var seen = new HashSet<string>();
        var managed = false;
        ulong? expected = null;
        long? seconds = null;
        string? runId = null;
        string? jobName = null;
        for (var i = 1; i < args.Length; i++)
        {
            var argument = args[i];
            if (!seen.Add(argument)) return Invalid("duplicate_argument");
            if (argument == "--managed") { managed = true; continue; }
            if (argument is not ("--expected-steam-id" or "--run-seconds" or "--run-id" or "--job-name")) return Invalid("unknown_argument");
            if (++i >= args.Length) return Invalid("missing_argument_value");
            var value = args[i];
            if (argument == "--job-name") { jobName = value; continue; }
            if (argument == "--expected-steam-id" && ulong.TryParse(value, out var id) && id > 0) { expected = id; continue; }
            if (argument == "--run-seconds" && long.TryParse(value, out var duration) && duration > 0) { seconds = duration; continue; }
            if (argument == "--run-id" && value.Length is > 0 and <= 128 && value.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_')) { runId = value; continue; }
            return Invalid("invalid_argument_value");
        }
        if (jobName is not null && (!managed || runId is null || jobName != "Local\\ssf_game_" + runId))
            return Invalid("invalid_job_name");
        return new(appId, managed, expected, seconds, runId ?? Guid.NewGuid().ToString("N"), jobName);
    }
}
