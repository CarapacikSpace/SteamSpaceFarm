using System.Globalization;
using System.Text.RegularExpressions;
using SteamKit2;

namespace SteamLibraryHelper;

public sealed record SteamAppArtwork(string? StoreHeaderImage, string? LibraryCapsuleImage)
{
    public static SteamAppArtwork Read(uint appId, KeyValue common)
    {
        var capsule = common["library_assets_full"]["library_capsule"];
        var revision = uint.TryParse(common["store_asset_mtime"].Value, NumberStyles.None,
            CultureInfo.InvariantCulture, out var timestamp) && timestamp > 0 ? $"?t={timestamp}" : "";
        return new(
            Url(appId, Localized(common["header_image"]), revision),
            Url(appId, Localized(capsule["image2x"]) ?? Localized(capsule["image"]), revision));
    }

    private static string? Localized(KeyValue node) =>
        ValidPath(node["english"].Value) ?? ValidPath(node.Value)
        ?? node.Children.Select(child => ValidPath(child.Value)).FirstOrDefault(value => value is not null);

    // PICS supplies paths relative to this app's asset directory, not arbitrary URLs.
    private static string? ValidPath(string? value) => value is not null &&
        Regex.IsMatch(value, @"\A(?:[a-zA-Z0-9_-]+/)*[a-zA-Z0-9_-]+\.(?:jpg|jpeg|png|webp)\z",
            RegexOptions.CultureInvariant | RegexOptions.IgnoreCase) ? value : null;

    private static string? Url(uint appId, string? path, string revision) => path is null ? null
        : $"https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/{appId}/{path}{revision}";
}
