using System.Reflection;
using System.Runtime.InteropServices;

namespace SteamGame;

internal static class NativeSteamApi
{
    private const string Library = "ssf_steam_api";
    static NativeSteamApi() => NativeLibrary.SetDllImportResolver(typeof(NativeSteamApi).Assembly, Resolve);

    private static IntPtr Resolve(string name, Assembly assembly, DllImportSearchPath? searchPath)
    {
        if (name != Library) return IntPtr.Zero;
        var file = OperatingSystem.IsWindows() ? "steam_api64.dll"
            : OperatingSystem.IsMacOS() ? "libsteam_api.dylib" : "libsteam_api.so";

        return NativeLibrary.Load(Path.Combine(AppContext.BaseDirectory, file));
    }

    public static bool Init() => InitFlat(IntPtr.Zero) == 0;
    public static ulong SteamId
    {
        get
        {
            var user = GetUser();
            return user == IntPtr.Zero ? 0 : GetSteamId(user);
        }
    }

    [DllImport(Library, EntryPoint = "SteamAPI_InitFlat", CallingConvention = CallingConvention.Cdecl)]
    private static extern int InitFlat(IntPtr errorMessage);
    [DllImport(Library, EntryPoint = "SteamAPI_SteamUser_v023", CallingConvention = CallingConvention.Cdecl)]
    private static extern IntPtr GetUser();
    [DllImport(Library, EntryPoint = "SteamAPI_ISteamUser_GetSteamID", CallingConvention = CallingConvention.Cdecl)]
    private static extern ulong GetSteamId(IntPtr user);
    [DllImport(Library, EntryPoint = "SteamAPI_RunCallbacks", CallingConvention = CallingConvention.Cdecl)]
    public static extern void RunCallbacks();
    [DllImport(Library, EntryPoint = "SteamAPI_Shutdown", CallingConvention = CallingConvention.Cdecl)]
    public static extern void Shutdown();
}
