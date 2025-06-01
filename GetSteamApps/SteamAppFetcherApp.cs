using GetSteamApps.Core;
using Microsoft.Extensions.Logging;

namespace GetSteamApps;

public class SteamAppFetcherApp(string[] args, ILogger<SteamContext> logger)
{
    public void Run()
    {
        var context = new SteamContext(args, logger);
        context.Initialize();

        SteamHandlers.Register(context);

        logger.LogInformation("Connecting to Steam...");
        context.Client.Connect();

        while (context.IsRunning) context.CallbackManager.RunWaitCallbacks(TimeSpan.FromSeconds(1));
    }
}