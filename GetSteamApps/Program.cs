using GetSteamApps.Core;
using Microsoft.Extensions.Logging;

namespace GetSteamApps;

internal static class Program
{
    private static void Main(string[] args)
    {
        using var loggerFactory = LoggerFactory.Create(builder =>
        {
            builder
                .AddSimpleConsole(options =>
                {
                    options.TimestampFormat = "yyyy-MM-dd HH:mm:ss ";
                    options.IncludeScopes = false;
                    options.SingleLine = true;
                })
                .SetMinimumLevel(LogLevel.Information);
        });

        var logger = loggerFactory.CreateLogger<SteamContext>();

        if (args.Contains("--logout"))
        {
            if (File.Exists(SteamContext.AuthFile))
                File.Delete(SteamContext.AuthFile);

            Console.WriteLine("Logged out and deleted authentication data.");
            return;
        }

        var app = new SteamAppFetcherApp(args, logger);
        app.Run();
    }
}