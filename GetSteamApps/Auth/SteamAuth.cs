using System.Text.Json;
using GetSteamApps.Core;
using SteamKit2;
using SteamKit2.Authentication;

namespace GetSteamApps.Auth;

public static class SteamAuth
{
    public static async Task AuthenticateAsync(SteamContext context)
    {
        var client = context.Client;
        var steamUser = context.SteamUser;

        if (!string.IsNullOrEmpty(context.AuthData?.RefreshToken))
        {
            context.Log("Using stored RefreshToken");
            steamUser?.LogOn(new SteamUser.LogOnDetails
            {
                Username = context.AuthData.AccountName,
                AccessToken = context.AuthData.RefreshToken
            });
            return;
        }

        var (username, password) = context.GetCredentials();
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            context.Log("Login and password required for first authentication.");
            context.IsRunning = false;
            return;
        }

        var session = await client.Authentication.BeginAuthSessionViaCredentialsAsync(new AuthSessionDetails
        {
            Username = username,
            Password = password,
            IsPersistentSession = true,
            GuardData = context.AuthData?.GuardData
        });

        var pollResult = await session.PollingWaitForResultAsync();

        context.AuthData = new AuthData
        {
            RefreshToken = pollResult.RefreshToken,
            GuardData = pollResult.NewGuardData,
            AccountName = pollResult.AccountName
        };

        await File.WriteAllTextAsync(SteamContext.AuthFile,
            JsonSerializer.Serialize(context.AuthData, new JsonSerializerOptions { WriteIndented = true }));

        steamUser?.LogOn(new SteamUser.LogOnDetails
        {
            Username = pollResult.AccountName,
            AccessToken = pollResult.RefreshToken,
            ShouldRememberPassword = true
        });
    }
}