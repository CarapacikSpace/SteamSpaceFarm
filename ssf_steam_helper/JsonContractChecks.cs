using System.Text.Json;

namespace SteamLibraryHelper;

internal static class JsonContractChecks
{
    public static void Run()
    {
        var cases = new (ProtocolEvent Value, string Expected)[]
        {
            (HelperJson.Qr("https://s.team/q/test"), """{"v":1,"event":"auth.qr","data":{"challengeUrl":"https://s.team/q/test"}}"""),
            (HelperJson.Input("request", "email_code", true, "Code"), """{"v":1,"event":"auth.input","data":{"requestId":"request","kind":"email_code","secret":true,"prompt":"Code"}}"""),
            (HelperJson.Confirmation(), """{"v":1,"event":"auth.confirmation","data":{"kind":"steam_mobile"}}"""),
            (HelperJson.Authenticated("76561198000000001"), """{"v":1,"event":"auth.authenticated","data":{"steamId":"76561198000000001"}}"""),
            (HelperJson.Progress("family"), """{"v":1,"event":"library.progress","data":{"phase":"family"}}"""),
            (HelperJson.Failed("IOException"), """{"v":1,"event":"operation.failed","data":{"code":"IOException"}}"""),
            (HelperJson.InputFailed(), """{"v":1,"event":"operation.input_failed","data":{"code":"invalid_input"}}"""),
            (HelperJson.TimedOut(), """{"v":1,"event":"operation.timeout","data":{}}"""),
            (HelperJson.Cancelled(), """{"v":1,"event":"operation.cancelled","data":{}}"""),
        };
        foreach (var (value, expected) in cases)
        {
            if (HelperJson.Serialize(value) != expected)
                throw new InvalidOperationException($"Wire contract changed: {value.Event}");
        }

        const string stored = """{"AccountName":"synthetic","RefreshToken":"synthetic-token","GuardData":null}""";
        var secret = JsonSerializer.Deserialize(stored, SessionJsonContext.Default.SessionSecret);
        if (secret != new SessionSecret("synthetic", "synthetic-token", null)
            || JsonSerializer.Serialize(secret, SessionJsonContext.Default.SessionSecret) != stored)
        {
            throw new InvalidOperationException("Stored session contract changed");
        }

        const string envelope = """{"Version":1,"Ciphertext":"YWJj"}""";
        var wrapper = JsonSerializer.Deserialize(envelope, SessionJsonContext.Default.SessionEnvelope);
        if (wrapper != new SessionEnvelope(1, "YWJj")
            || JsonSerializer.Serialize(wrapper, SessionJsonContext.Default.SessionEnvelope) != envelope)
        {
            throw new InvalidOperationException("DPAPI envelope contract changed");
        }

        var source = new SourceReport("complete", 1);
        var library = new SteamLibraryResult(1, "76561198000000001", true,
            new SourceCoverage(source, source, source, source, source),
            [new LibraryEntry(480, null, "Test", null, "complete", "unknown", "game", 1700000000)], []);
        using var document = JsonDocument.Parse(HelperJson.Serialize(HelperJson.Result(library)));
        var app = document.RootElement.GetProperty("data").GetProperty("apps")[0];
        if (app.GetProperty("ownership").ValueKind != JsonValueKind.Null
            || app.GetProperty("hours").ValueKind != JsonValueKind.Null
            || app.GetProperty("lastPlayedAtUnixSeconds").GetInt64() != 1700000000)
        {
            throw new InvalidOperationException("Library null or timestamp contract changed");
        }

        var restored = JsonSerializer.Deserialize(HelperJson.Library(library), ProtocolJsonContext.Default.SteamLibraryResult);
        if (restored?.SteamId != library.SteamId || restored.Apps.Single() != library.Apps.Single())
            throw new InvalidOperationException("Library JSON roundtrip failed");
        var command = JsonSerializer.Deserialize("""{"v":1,"command":"auth.input","requestId":"x","value":"00123"}""", ProtocolJsonContext.Default.AuthCommand);
        if (command != new AuthCommand(1, "auth.input", "x", "00123"))
            throw new InvalidOperationException("Guard command contract changed");
    }
}
