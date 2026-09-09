using System.Text;
using System.Text.Json;
using SteamGame;

namespace SteamGameChecks;

internal static class Checks
{
    private const ulong SteamId = 76561198000000001;
    private static readonly string[] Managed = ["480", "--managed", "--expected-steam-id", SteamId.ToString(), "--run-id", "test-run"];

    public static int Main(string[] args)
    {

        if (args.Length == 2 && args[0] == "--job-fixture")
        {
            WindowsRunnerJob.Join(args[1]);
            Console.WriteLine("joined");
            Console.Out.Flush();
            Thread.Sleep(Timeout.Infinite);
            return 0;
        }
        if (args.Length == 1 && args[0] == "--hang-fixture")
        {
            Console.WriteLine("standalone");
            Console.Out.Flush();
            Thread.Sleep(Timeout.Infinite);
            return 0;
        }

        if (args.Length == 1 && args[0] == "--fixture")
        {
            using var input = Console.OpenStandardInput();
            return RunnerApp.Execute(Managed, new FakeApi(), input, Console.Out, Console.Error, new RunnerClock());
        }

        foreach (var flag in new[] { "--run-seconds", "--run-id", "--expected-steam-id", "--unknown" })
        {
            var api = new FakeApi();
            var result = Run(["480", flag], api, Stream.Null);
            Check(result.Code == 2 && api.InitCalls == 0, "invalid CLI before native Init: " + flag);
        }
        Check(Run(["0"], new FakeApi(), Stream.Null).Code == 2, "AppID zero");
        Check(Run(["480", "--managed"], new FakeApi(), Stream.Null).Code == 2, "missing identity");
        Check(Run(["480", "--expected-steam-id", "0"], new FakeApi(), Stream.Null).Code == 2, "invalid identity");
        var noJob = new FakeApi();
        Check(Run([.. Managed, "--job-name", "Local\\ssf_game_test-run"], noJob, Stream.Null).Code == 21
            && noJob.InitCalls == 0, "missing job fails before SteamAPI Init");
        Check(Run([.. Managed, "--job-name", "unrelated"], new FakeApi(), Stream.Null).Code == 2, "job name bound to run ID");
        Check(Run(["480", "--job-name", "Local\\ssf_game_test-run"], new FakeApi(), Stream.Null).Code == 2, "standalone rejects managed job");

        foreach (var failure in new (bool Init, Exception? Error, int Code)[]
        {
            (false, null, 10), (true, new DllNotFoundException(), 11),
            (true, new BadImageFormatException(), 11), (true, new EntryPointNotFoundException(), 11),
            (true, new InvalidOperationException(), 20),
        })
        {
            var api = new FakeApi { InitResult = failure.Init, InitError = failure.Error };
            var result = Run(Managed, api, Stream.Null);
            Check(result.Code == failure.Code && api.Shutdowns == 0 && result.Events.All(e => Kind(e) != "ready"), "Init failure");
        }
        var mismatch = new FakeApi { Id = SteamId + 1 };
        Check(Run(Managed, mismatch, Stream.Null).Code == 12 && mismatch.Shutdowns == 1, "identity mismatch shutdown");

        var success = new FakeApi();
        var stopped = Run(Managed, success, Text("{\"command\":\"stop\"}\n"));
        Check(stopped.Code == 0 && success.Shutdowns == 1 && success.Callbacks > 0, "stop lifecycle");
        var ready = stopped.Events[0];
        Check(Kind(ready) == "ready" && ready.GetProperty("steamId").GetString() == SteamId.ToString(), "ready identity string");
        Check(stopped.Events.All(e => e.GetProperty("v").GetInt32() == 1 && e.GetProperty("runId").GetString() == "test-run"), "event version/runId");

        var queued = string.Concat(Enumerable.Repeat("{\"command\":\"update_deadline\",\"runSeconds\":null}\n", 160));
        var eofApi = new FakeApi();
        var eof = Run(Managed, eofApi, Text(queued));
        Check(eof.Code == 0 && eof.Events.Count(e => Kind(e) == "deadline_updated") == 160 && eof.Events.Last().GetProperty("reason").GetString() == "eof" && eofApi.Shutdowns == 1, "backpressure preserves EOF and commands");
        var stopAfterQueue = Run(Managed, new FakeApi(), Text(queued + "{\"command\":\"stop\"}\n"));
        Check(stopAfterQueue.Code == 0 && Kind(stopAfterQueue.Events.Last()) == "stopping", "backpressure preserves stop");

        foreach (var malformed in new[] { "[]", "null", "1", "\"text\"", "{", "{\"command\":\"update_deadline\",\"runSeconds\":\"3\"}", "{\"command\":\"update_deadline\",\"runSeconds\":-1}" })
        {
            var api = new FakeApi();
            Check(Run(Managed, api, Text(malformed + "\n")).Code == 2 && api.Shutdowns == 1, "malformed command: " + malformed);
        }
        var large = Run(Managed, new FakeApi(), new PrefixThenBlock(Encoding.UTF8.GetBytes(new string('a', 4097))));
        Check(large.Code == 2 && large.Events.Last().GetProperty("code").GetString() == "frame_too_large", "oversize fails before newline/EOF");
        Check(Run(Managed, new FakeApi(), new MemoryStream([0xff, 10])).Code == 2, "invalid UTF8");
        Check(Run(Managed, new FakeApi(), new BrokenStream()).Code == 2, "stdin read error");

        var deadline = Run([.. Managed, "--run-seconds", "1"], new FakeApi(), new PrefixThenBlock([]));
        Check(deadline.Code == 0 && deadline.Events.Last().GetProperty("reason").GetString() == "deadline", "deadline");
        var updated = Run([.. Managed, "--run-seconds", "1000"], new FakeApi(), new PrefixThenBlock(Encoding.UTF8.GetBytes("{\"command\":\"update_deadline\",\"runSeconds\":1}\n")));
        Check(updated.Code == 0 && updated.Events.Any(e => Kind(e) == "deadline_updated") && updated.Events.Last().GetProperty("reason").GetString() == "deadline", "update remaining deadline");
        var huge = Run([.. Managed, "--run-seconds", long.MaxValue.ToString()], new FakeApi(), Text("{\"command\":\"stop\"}"));
        Check(huge.Code == 0 && Kind(huge.Events.Last()) == "stopping", "long duration cannot overflow deadline");

        var standaloneApi = new FakeApi();
        var standalone = Run(["480", "--run-seconds", "1"], standaloneApi, new BrokenStream());
        Check(standalone.Code == 0 && standalone.Events.Length == 0 && standaloneApi.Shutdowns == 1, "standalone never reads stdin");
        var callbackFailure = new FakeApi { ThrowCallbacks = true };
        Check(Run(Managed, callbackFailure, Stream.Null).Code == 20 && callbackFailure.Shutdowns == 1, "runtime error shutdown");
        var lifecycleApi = new FakeApi();
        var lifecycle = new RunnerLifecycle(lifecycleApi);
        lifecycle.Initialize(SteamId);
        lifecycle.ShutdownOnce(); lifecycle.ShutdownOnce();
        Check(lifecycleApi.Shutdowns == 1, "Shutdown exactly once");
        Console.WriteLine("PASS: offline runner CLI, Init/identity, protocol, bounded input, queued stop/EOF, deadline and shutdown");
        return 0;
    }

    private static string Kind(JsonElement item) => item.GetProperty("event").GetString()!;
    private static Stream Text(string text) => new MemoryStream(Encoding.UTF8.GetBytes(text));
    private static void Check(bool value, string name) { if (!value) throw new Exception("FAIL: " + name); }
    private static (int Code, JsonElement[] Events) Run(string[] args, FakeApi api, Stream input)
    {
        using (input)
        using (var output = new StringWriter())
        using (var error = new StringWriter())
        {
            var code = RunnerApp.Execute(args, api, input, output, error, new FastClock());
            var events = output.ToString().Split('\n', StringSplitOptions.RemoveEmptyEntries).Select(line =>
            {
                using var document = JsonDocument.Parse(line);
                return document.RootElement.Clone();
            }).ToArray();
            return (code, events);
        }
    }

    private sealed class FastClock : IRunnerClock
    {
        public long Timestamp { get; private set; }
        public long Frequency => 1000;
        public void Sleep() { Timestamp += 100; Thread.Sleep(1); if (Timestamp > 500_000) throw new TimeoutException("test watchdog"); }
    }
    private sealed class FakeApi : IRunnerSteamApi
    {
        public bool InitResult = true;
        public Exception? InitError;
        public ulong Id = Checks.SteamId;
        public bool ThrowCallbacks;
        public int InitCalls, Shutdowns, Callbacks;
        public ulong SteamId => Id;
        public bool Init() { InitCalls++; if (InitError is not null) throw InitError; return InitResult; }
        public void RunCallbacks() { Callbacks++; if (ThrowCallbacks) throw new IOException("synthetic callback failure"); }
        public void Shutdown() => Shutdowns++;
    }
    private class PrefixThenBlock(byte[] prefix) : Stream
    {
        private int offset;
        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => throw new NotSupportedException();
        public override long Position { get => offset; set => throw new NotSupportedException(); }
        public override async ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken token = default)
        {
            var count = Math.Min(buffer.Length, prefix.Length - offset);
            if (count > 0) { prefix.AsMemory(offset, count).CopyTo(buffer); offset += count; return count; }
            await Task.Delay(Timeout.Infinite, token);
            return 0;
        }
        public override int Read(byte[] buffer, int offset, int count) => throw new NotSupportedException();
        public override void Flush() { }
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) => throw new NotSupportedException();
    }
    private sealed class BrokenStream() : PrefixThenBlock([])
    {
        public override ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken token = default) => throw new IOException("synthetic stdin failure");
    }
}
