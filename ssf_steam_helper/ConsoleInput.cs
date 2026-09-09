namespace SteamLibraryHelper;

internal static class ConsoleInput
{
    public static async Task<string?> ReadLineAsync(string prompt, CancellationToken cancellationToken)
    {
        Console.Error.Write(prompt);
        return await Task.Run(Console.In.ReadLine, CancellationToken.None)
            .WaitAsync(cancellationToken).ConfigureAwait(false);
    }

    public static async Task<string?> ReadSecretAsync(string prompt, CancellationToken cancellationToken)
    {
        Console.Error.Write(prompt);
        if (Console.IsInputRedirected)
        {
            return await Task.Run(Console.In.ReadLine, CancellationToken.None)
                .WaitAsync(cancellationToken).ConfigureAwait(false);
        }

        return await Task.Run(ReadSecretBlocking, CancellationToken.None)
            .WaitAsync(cancellationToken).ConfigureAwait(false);
    }

    private static string ReadSecretBlocking()
    {
        var value = new System.Text.StringBuilder();
        while (true)
        {
            var key = Console.ReadKey(intercept: true);
            if (key.Key == ConsoleKey.Enter)
                break;
            if (key.Key == ConsoleKey.Backspace && value.Length > 0)
                value.Length--;
            else if (!char.IsControl(key.KeyChar))
                value.Append(key.KeyChar);
        }

        Console.Error.WriteLine();
        return value.ToString();
    }
}
