using GetSteamApps.Auth;
using Microsoft.Extensions.Logging;
using SteamKit2;
using static SteamKit2.SteamApps;

namespace GetSteamApps.Core;

public static class SteamHandlers
{
    public static void Register(SteamContext context)
    {
        var cm = context.CallbackManager;
        cm.Subscribe<SteamClient.ConnectedCallback>(_ => SteamAuth.AuthenticateAsync(context).Wait());
        cm.Subscribe<SteamClient.DisconnectedCallback>(_ =>
        {
            context.Log("Disconnected");

            if (context.AuthData == null)
                context.IsRunning = false;
        });
        cm.Subscribe<SteamUser.LoggedOnCallback>(cb => OnLoggedOn(cb, context));
        cm.Subscribe<SteamUser.LoggedOffCallback>(cb => context.Log($"Logged off: {cb.Result}"));
        cm.Subscribe<LicenseListCallback>(async void (cb) => await SteamLicenseProcessor.ProcessAsync(context, cb));
    }

    private static void OnLoggedOn(SteamUser.LoggedOnCallback cb, SteamContext context)
    {
        if (cb.Result is EResult.AccessDenied or EResult.ExpiredLoginAuthCode or EResult.InvalidLoginAuthCode)
        {
            context.Log("Stored token is invalid or expired. Re-authenticating with credentials...", LogLevel.Warning);

            context.AuthData = null;
            if (File.Exists(SteamContext.AuthFile))
                File.Delete(SteamContext.AuthFile);

            _ = Task.Run(async () =>
            {
                await SteamAuth.AuthenticateAsync(context);

                context.Client.Disconnect();
                await Task.Delay(1000);
                context.Client.Connect();
            });

            return;
        }

        if (cb.Result != EResult.OK)
        {
            context.Log($"Login failed: {cb.Result}", LogLevel.Warning);
            context.IsRunning = false;
            return;
        }

        context.Log("Logged on. Requesting license list...");
        _ = context.SteamApps?.PICSGetProductInfo([new PICSRequest(730)], []);
    }
}