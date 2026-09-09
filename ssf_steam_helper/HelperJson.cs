using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.Json.Serialization.Metadata;

namespace SteamLibraryHelper;

internal sealed record ProtocolEvent(int V, string Event, JsonElement Data);
internal sealed record QrChallenge(string ChallengeUrl);
internal sealed record AuthInputRequest(string RequestId, string Kind, bool Secret, string Prompt);
internal sealed record DeviceConfirmation(string Kind);
internal sealed record AuthenticatedAccount(string SteamId);
internal sealed record LibraryProgress(string Phase);
internal sealed record OperationError(string Code);
internal sealed record EmptyPayload;
internal sealed record ResultWritten(string Event, string Output, bool Partial);
internal sealed record SyntheticResult(string Event, string[] Checks);
internal sealed record AuthCommand(int V, string? Command, string? RequestId = null, string? Value = null);
internal sealed record SessionEnvelope(int Version, string? Ciphertext);

[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase, MaxDepth = 8)]
[JsonSerializable(typeof(ProtocolEvent))]
[JsonSerializable(typeof(QrChallenge))]
[JsonSerializable(typeof(AuthInputRequest))]
[JsonSerializable(typeof(DeviceConfirmation))]
[JsonSerializable(typeof(AuthenticatedAccount))]
[JsonSerializable(typeof(LibraryProgress))]
[JsonSerializable(typeof(OperationError))]
[JsonSerializable(typeof(EmptyPayload))]
[JsonSerializable(typeof(SteamLibraryResult))]
[JsonSerializable(typeof(ResultWritten))]
[JsonSerializable(typeof(SyntheticResult))]
[JsonSerializable(typeof(AuthCommand))]
internal partial class ProtocolJsonContext : JsonSerializerContext;

[JsonSerializable(typeof(SessionSecret))]
[JsonSerializable(typeof(SessionEnvelope))]
internal partial class SessionJsonContext : JsonSerializerContext;

internal static class HelperJson
{
    private static readonly ProtocolJsonContext Pretty = new(new JsonSerializerOptions(ProtocolJsonContext.Default.Options)
    {
        WriteIndented = true,
    });

    public static string Library(SteamLibraryResult value) => JsonSerializer.Serialize(value, Pretty.SteamLibraryResult);
    public static string Serialize(ProtocolEvent value) => JsonSerializer.Serialize(value, ProtocolJsonContext.Default.ProtocolEvent);

    private static ProtocolEvent Event<T>(string name, T data, JsonTypeInfo<T> type) =>
        new(1, name, JsonSerializer.SerializeToElement(data, type));

    public static ProtocolEvent Qr(string url) => Event("auth.qr", new QrChallenge(url), ProtocolJsonContext.Default.QrChallenge);
    public static ProtocolEvent Input(string id, string kind, bool secret, string prompt) =>
        Event("auth.input", new AuthInputRequest(id, kind, secret, prompt), ProtocolJsonContext.Default.AuthInputRequest);
    public static ProtocolEvent Confirmation() =>
        Event("auth.confirmation", new DeviceConfirmation("steam_mobile"), ProtocolJsonContext.Default.DeviceConfirmation);
    public static ProtocolEvent Authenticated(string id) =>
        Event("auth.authenticated", new AuthenticatedAccount(id), ProtocolJsonContext.Default.AuthenticatedAccount);
    public static ProtocolEvent Progress(string phase) => Event("library.progress", new LibraryProgress(phase), ProtocolJsonContext.Default.LibraryProgress);
    public static ProtocolEvent Result(SteamLibraryResult result) => Event("library.result", result, ProtocolJsonContext.Default.SteamLibraryResult);
    public static ProtocolEvent Failed(string code) => Event("operation.failed", new OperationError(code), ProtocolJsonContext.Default.OperationError);
    public static ProtocolEvent InputFailed() => Event("operation.input_failed", new OperationError("invalid_input"), ProtocolJsonContext.Default.OperationError);
    public static ProtocolEvent TimedOut() => Event("operation.timeout", new EmptyPayload(), ProtocolJsonContext.Default.EmptyPayload);
    public static ProtocolEvent Cancelled() => Event("operation.cancelled", new EmptyPayload(), ProtocolJsonContext.Default.EmptyPayload);
}
