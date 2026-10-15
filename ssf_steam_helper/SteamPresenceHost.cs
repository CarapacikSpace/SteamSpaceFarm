using System.Runtime.InteropServices;
using System.Runtime.Versioning;
using System.Diagnostics;
using System.Text.Json;
using Microsoft.Win32;
using SteamKit2;

namespace SteamLibraryHelper;

// Own a desktop-client presence lease independently of any game runner. Closing
// the parent's stdin (including a parent crash) restores the previous status.
internal static class SteamPresenceHost
{
    public static int Run(string[] args)
    {
        if (!OperatingSystem.IsWindows() || (args.Length != 3 && (args.Length != 4 || args[3] != "--optional-client")) || args[1] != "--expected-steam-id"
            || !ulong.TryParse(args[2], out var expectedId) || expectedId == 0) return 2;
        try
        {
            using var client = OpenClient(expectedId, optional: args.Length == 4);
            using var lease = client == null ? null : new InvisiblePresenceLease(client);
            Console.WriteLine($"SSF_PRESENCE_READY:{expectedId}");
            Console.Out.Flush();
            using var input = Console.OpenStandardInput();
            input.ReadByte(); // A byte or EOF releases the lease; no unbounded input buffering.
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine($"[presence] {error.Message}");
            return 6;
        }
    }

    [SupportedOSPlatform("windows")]
    private static DesktopSteamPresence? OpenClient(ulong expectedId, bool optional)
    {
        try { return new DesktopSteamPresence(expectedId); }
        catch (InvalidOperationException error) when (optional && error.Message is
            "steam_client_required" or "steam_login_required" or "account_mismatch")
        {
            // SteamKit owns its own presence when there is no matching desktop session.
            return null;
        }
    }
}

internal interface IDesktopPresence
{
    int State { get; }
    bool IsSameAccount { get; }
    void SetState(int state);
}

internal sealed class InvisiblePresenceLease : IDisposable
{
    private readonly IDesktopPresence _client;
    private readonly int _previous;
    private bool _disposed;

    public InvisiblePresenceLease(IDesktopPresence client)
    {
        _client = client;
        _previous = client.State;
        if (_previous is not (0 or 1 or 3 or 7)) throw new InvalidOperationException("presence_state_unsupported");
        try
        {
            if (_previous != 7) client.SetState(7);
        }
        catch { Dispose(); throw; }
    }

    public void Dispose()
    {
        if (_disposed) return;
        for (var attempt = 0; ; attempt++)
        {
            try
            {
                // Recheck on every attempt: never overwrite a manual change or
                // apply the saved status to a different account after a retry.
                if (_previous != 7 && _client.IsSameAccount && _client.State == 7)
                    _client.SetState(_previous);
                _disposed = true;
                return;
            }
            catch (Exception error) when (attempt < 2 && error is IOException or UnauthorizedAccessException)
            {
                Thread.Sleep(150);
            }
        }
    }
}

[SupportedOSPlatform("windows")]
internal sealed class DesktopSteamPresence : IDesktopPresence, IDisposable
{
    private readonly ulong _expectedId;
    private IntPtr _client, _steamUser;
    private int _pipe, _user;
    private string _steamExecutable = "";
    private string _preferencesPath = "";

    public DesktopSteamPresence(ulong expectedId)
    {
        _expectedId = expectedId;
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(@"Software\Valve\Steam");
            var directory = key?.GetValue("SteamPath") as string;
            if (string.IsNullOrWhiteSpace(directory) || !File.Exists(Path.Combine(directory, "steamclient64.dll")))
                throw new InvalidOperationException("steam_client_required");
            _steamExecutable = Path.Combine(directory, "steam.exe");
            _preferencesPath = Path.Combine(directory, "userdata", new SteamID(expectedId).AccountID.ToString(), "config", "localconfig.vdf");
            // Load only the installed client's DLL, with dependencies resolved alongside it.
            var library = NativeLibrary.Load(Path.Combine(directory, "steamclient64.dll"),
                typeof(DesktopSteamPresence).Assembly, DllImportSearchPath.UseDllDirectoryForDependencies | DllImportSearchPath.SafeDirectories);
            var create = Marshal.GetDelegateForFunctionPointer<CreateInterface>(NativeLibrary.GetExport(library, "CreateInterface"));
            _client = create("SteamClient012", IntPtr.Zero);
            if (_client == IntPtr.Zero) throw new InvalidOperationException("steam_client_interface_unavailable");
            _pipe = Method<GetInt>(_client, 0)(_client);
            if (_pipe == 0) throw new InvalidOperationException("steam_client_required");
            _user = Method<ConnectUser>(_client, 2)(_client, _pipe);
            if (_user == 0) throw new InvalidOperationException("steam_login_required");
            _steamUser = Method<GetInterface>(_client, 5)(_client, _user, _pipe, "SteamUser017");
            if (_steamUser == IntPtr.Zero)
                throw new InvalidOperationException("steam_presence_interface_unavailable");
            if (!IsSameAccount) throw new InvalidOperationException("account_mismatch");
        }
        catch { Dispose(); throw; }
    }

    // Versioned ABI: Open Steamworks ISteamClient012 and ISteamUser017.
    // Native game interfaces report Online even when modern chat is Invisible.
    // Read chat's saved preference instead; never modify Steam's config file.
    public int State
    {
        get
        {
            var preferences = KeyValue.LoadAsText(_preferencesPath);
            return SteamPresencePreferences.Read(preferences, new SteamID(_expectedId).AccountID)
                ?? throw new IOException("steam_presence_state_unavailable");
        }
    }
    public bool IsSameAccount
    {
        get
        {
            Method<GetSteamId>(_steamUser, 2)(_steamUser, out var id);
            return id == _expectedId;
        }
    }

    public void SetState(int state)
    {
        var status = state switch
        {
            0 => "offline", 1 => "online", 3 => "away", 7 => "invisible",
            _ => throw new ArgumentOutOfRangeException(nameof(state))
        };
        // Current Steam chat owns presence. Its status URL updates both chat and
        // native IPC; the legacy ISteamFriends setter is ignored by modern clients.
        using var command = Process.Start(new ProcessStartInfo(_steamExecutable)
        {
            ArgumentList = { "-silent", $"steam://friends/status/{status}" },
            UseShellExecute = false, CreateNoWindow = true, WindowStyle = ProcessWindowStyle.Hidden
        });
        for (var attempt = 0; attempt < 50; attempt++)
        {
            try { if (State == state) return; }
            catch (IOException) { } // Steam may be replacing the preferences file.
            Thread.Sleep(100);
        }
        throw new IOException("steam_presence_not_confirmed");
    }

    public void Dispose()
    {
        if (_user != 0) Method<ReleaseUser>(_client, 4)(_client, _pipe, _user);
        if (_pipe != 0) Method<ReleasePipe>(_client, 1)(_client, _pipe);
        _user = _pipe = 0;
        // steamclient owns background threads; keep its module loaded until process exit.
    }

    private static T Method<T>(IntPtr instance, int slot) where T : Delegate =>
        Marshal.GetDelegateForFunctionPointer<T>(Marshal.ReadIntPtr(Marshal.ReadIntPtr(instance), slot * IntPtr.Size));

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    private delegate IntPtr CreateInterface([MarshalAs(UnmanagedType.LPStr)] string version, IntPtr result);
    [UnmanagedFunctionPointer(CallingConvention.ThisCall)]
    private delegate int GetInt(IntPtr self);
    [UnmanagedFunctionPointer(CallingConvention.ThisCall)]
    private delegate int ConnectUser(IntPtr self, int pipe);
    [UnmanagedFunctionPointer(CallingConvention.ThisCall)]
    private delegate IntPtr GetInterface(IntPtr self, int user, int pipe, [MarshalAs(UnmanagedType.LPStr)] string version);
    [UnmanagedFunctionPointer(CallingConvention.ThisCall)]
    private delegate IntPtr GetSteamId(IntPtr self, out ulong steamId);
    [UnmanagedFunctionPointer(CallingConvention.ThisCall)]
    private delegate void ReleaseUser(IntPtr self, int pipe, int user);
    [UnmanagedFunctionPointer(CallingConvention.ThisCall)]
    [return: MarshalAs(UnmanagedType.I1)]
    private delegate bool ReleasePipe(IntPtr self, int pipe);
}

internal static class SteamPresencePreferences
{
    internal static int? Read(KeyValue? root, uint accountId)
    {
        if (root == null) return null;
        var remaining = new Stack<KeyValue>();
        remaining.Push(root);
        var key = $"FriendStoreLocalPrefs_{accountId}";
        while (remaining.TryPop(out var node))
        {
            if (node.Name == key && node.Value is string value && value.Length <= 8192)
            {
                try
                {
                    using var json = JsonDocument.Parse(value, new JsonDocumentOptions { MaxDepth = 8 });
                    if (json.RootElement.ValueKind == JsonValueKind.Object
                        && json.RootElement.TryGetProperty("ePersonaState", out var persona)
                        && persona.ValueKind == JsonValueKind.Number
                        && persona.TryGetInt32(out var state) && state is >= 0 and <= 7) return state;
                }
                catch (JsonException) { }
                return null;
            }
            foreach (var child in node.Children) remaining.Push(child);
        }
        return null;
    }
}
