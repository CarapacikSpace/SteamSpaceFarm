using System.Text.Json;
using GetSteamApps.Auth;
using Microsoft.Extensions.Logging;
using SteamKit2;

namespace GetSteamApps.Core;

public class SteamContext(string[] args, ILogger<SteamContext> logger)
{
    private string? _password;
    private string? _username;

    public SteamClient Client { get; } = new();
    public CallbackManager CallbackManager { get; private set; } = null!;

    public SteamUser? SteamUser { get; private set; }

    // public SteamFriends? SteamFriends { get; private set; }
    public SteamApps? SteamApps { get; private set; }
    public AuthData? AuthData { get; set; }
    public bool IsRunning { get; set; } = true;
    private string[] Args { get; } = args;

    public static string AuthFile => GetAuthFilePath();

    public void Initialize()
    {
        CallbackManager = new CallbackManager(Client);
        SteamUser = Client.GetHandler<SteamUser>();
        // SteamFriends = Client.GetHandler<SteamFriends>();
        SteamApps = Client.GetHandler<SteamApps>();

        _username = Args.ElementAtOrDefault(0);
        _password = Args.ElementAtOrDefault(1);

        if (File.Exists(AuthFile)) AuthData = JsonSerializer.Deserialize<AuthData>(File.ReadAllText(AuthFile));
    }

    private static string GetAuthFilePath()
    {
        string baseDir;

        if (OperatingSystem.IsWindows())
        {
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            baseDir = Path.Combine(appData, "CarapacikSpace", "SpaceFarm");
        }
        else if (OperatingSystem.IsMacOS())
        {
            var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            baseDir = Path.Combine(home, "Library", "Preferences", "CarapacikSpace", "SpaceFarm");
        }
        else if (OperatingSystem.IsLinux())
        {
            var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            baseDir = Path.Combine(home, ".config", "CarapacikSpace", "SpaceFarm");
        }
        else
        {
            baseDir = Path.Combine(Directory.GetCurrentDirectory(), "CarapacikSpace", "SpaceFarm");
        }

        Directory.CreateDirectory(baseDir);
        return Path.Combine(baseDir, "steam_auth.json");
    }


    public (string? Username, string? Password) GetCredentials()
    {
        return (_username, _password);
    }

    public void Log(string message, LogLevel level = LogLevel.Information)
    {
        logger.Log(level, message);
    }
}