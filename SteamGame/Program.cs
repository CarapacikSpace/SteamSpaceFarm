using Microsoft.Extensions.Logging;
using Steamworks;

namespace SteamGame;

internal class Program
{
    private static void Main(string[] args)
    {
        using var loggerFactory = LoggerFactory.Create(builder =>
        {
            builder.AddSimpleConsole(options =>
            {
                options.IncludeScopes = false;
                options.SingleLine = true;
                options.TimestampFormat = "HH:mm:ss ";
            });
            builder.SetMinimumLevel(LogLevel.Information);
        });

        ILogger logger = loggerFactory.CreateLogger<Program>();

        if (args.Length == 0 || !uint.TryParse(args[0], out var appId))
        {
            logger.LogWarning("No valid appId provided.");
            return;
        }

        Environment.SetEnvironmentVariable("SteamAppId", appId.ToString());

        try
        {
            if (!SteamAPI.Init())
            {
                logger.LogError("Failed to initialize SteamAPI.");
                return;
            }

            logger.LogInformation("SteamAPI initialized successfully for AppID {AppId}.", appId);

            while (true)
            {
                SteamAPI.RunCallbacks();
                Thread.Sleep(100);
            }
        }
        catch (DllNotFoundException ex)
        {
            logger.LogError(ex, "Steamworks DLL not found. Make sure steam_api64.dll is in the executable directory.");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unexpected error occurred.");
        }
        finally
        {
            SteamAPI.Shutdown();
            logger.LogInformation("SteamAPI shut down.");
        }
    }
}