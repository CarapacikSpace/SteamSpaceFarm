namespace SteamGame;

internal interface IRunnerSteamApi
{
    bool Init();
    ulong SteamId { get; }
    void RunCallbacks();
    void Shutdown();
}

internal sealed class RunnerLifecycle(IRunnerSteamApi api)
{
    private bool initialized;
    public LifecycleResult Initialize(ulong? expected)
    {
        try
        {
            if (!api.Init()) return LifecycleResult.Failed("init_failed", "SteamAPI.Init returned false");
            initialized = true;
            var steamId = api.SteamId;
            if (steamId == 0 || (expected is not null && steamId != expected)) return LifecycleResult.Failed("account_mismatch", "local SteamID differs from expected", steamId);
            return LifecycleResult.Ready(steamId);
        }
        catch (DllNotFoundException ex) { return LifecycleResult.Failed("dll_missing", ex.Message); }
        catch (BadImageFormatException ex) { return LifecycleResult.Failed("dll_architecture", ex.Message); }
        catch (EntryPointNotFoundException ex) { return LifecycleResult.Failed("dll_entrypoint", ex.Message); }
        catch (Exception ex) { return LifecycleResult.Failed("init_error", ex.Message); }
    }
    public void RunCallbacks() => api.RunCallbacks();
    public void ShutdownOnce(TextWriter? error = null)
    {
        if (!initialized) return;
        initialized = false;
        try { api.Shutdown(); }
        catch (Exception ex) { error?.WriteLine($"shutdown_error: {ex.GetType().Name}"); }
    }
}

internal sealed record LifecycleResult(bool Success, string? ErrorCode, string? Message, ulong? SteamId)
{
    public static LifecycleResult Ready(ulong id) => new(true, null, null, id);
    public static LifecycleResult Failed(string code, string message, ulong? id = null) => new(false, code, message, id);
}

internal sealed class SteamApiAdapter : IRunnerSteamApi
{
    public bool Init() => NativeSteamApi.Init();
    public ulong SteamId => NativeSteamApi.SteamId;
    public void RunCallbacks() => NativeSteamApi.RunCallbacks();
    public void Shutdown() => NativeSteamApi.Shutdown();
}
