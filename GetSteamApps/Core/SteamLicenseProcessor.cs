using System.Text.Json;
using Microsoft.Extensions.Logging;
using SteamKit2;

namespace GetSteamApps.Core;

using static SteamApps;

public static class SteamLicenseProcessor
{
    public static async Task ProcessAsync(SteamContext context, LicenseListCallback callback)
    {
        try
        {
            var steamApps = context.SteamApps!;
            var licenses = callback.LicenseList;

            var packageIds = licenses
                .GroupBy(l => l.PackageID)
                .Select(g => new PICSRequest(g.Key, g.First().AccessToken))
                .ToList();

            context.Log($"Requesting info for {packageIds.Count} packages...");
            var response = await steamApps.PICSGetProductInfo([], packageIds);

            if (!response.Complete)
            {
                context.Log("Failed to retrieve full package info.", LogLevel.Warning);
                return;
            }

            var packageData = response.Results!
                .SelectMany(r => r.Packages)
                .ToDictionary(kv => kv.Key, kv => kv.Value.KeyValues);

            var appIds = ExtractAppIds(packageData);
            context.Log($"Found {appIds.Count} unique app IDs from package data.");

            var appRequests = appIds.Select(id => new PICSRequest(id)).ToList();
            var appResponse = await steamApps.PICSGetProductInfo(appRequests, []);

            if (appResponse.Complete)
            {
                var appData = appResponse.Results!
                    .SelectMany(r => r.Apps)
                    .GroupBy(kv => kv.Key)
                    .Select(g => g.First())
                    .ToDictionary(kv => kv.Key, kv => kv.Value.KeyValues);

                var fullAppData = appData.ToDictionary(
                    kv => kv.Key.ToString(),
                    kv => SteamUtils.ConvertToKeyValueNode(kv.Value)
                );

                var cacheDir = "cache";
                Directory.CreateDirectory(cacheDir);

                var cacheAppPath = Path.Combine(cacheDir, "apps.json");

                await File.WriteAllTextAsync(cacheAppPath,
                    JsonSerializer.Serialize(fullAppData, new JsonSerializerOptions { WriteIndented = true }));

                context.Log($"Saved full app info for {fullAppData.Count} apps to '{cacheAppPath}'.");

                var userInfo = new
                {
                    login = context.AuthData?.AccountName,
                    steamId = context.SteamUser?.SteamID?.ConvertToUInt64(),
                    steam3Id = context.SteamUser?.SteamID?.ToString()
                };
                var cacheUserPath = Path.Combine(cacheDir, "user.json");
                await File.WriteAllTextAsync(cacheUserPath,
                    JsonSerializer.Serialize(userInfo, new JsonSerializerOptions { WriteIndented = true }));
                context.Log($"Saved user info to '{cacheUserPath}'.");
            }
            else
            {
                context.Log("Failed to retrieve full app info.", LogLevel.Warning);
            }
        }
        catch (Exception ex)
        {
            context.Log($"Error in license processing: {ex.Message}", LogLevel.Error);
        }
        finally
        {
            context.IsRunning = false;
        }
    }

    private static HashSet<uint> ExtractAppIds(Dictionary<uint, KeyValue> packages)
    {
        var appIds = new HashSet<uint>();

        foreach (var package in packages.Values)
            if (package["appids"] is { } appids && appids.Children.Any())
                foreach (var app in appids.Children)
                    if (uint.TryParse(app.Value, out var appId))
                        appIds.Add(appId);

        return appIds;
    }
}