using System.Text.Json;
using SteamKit2;

namespace SteamLibraryHelper;

internal static class SteamAppArtworkChecks
{
    internal static void Run()
    {
        var common = KeyValue.LoadFromString("""
            "common" {
                "header_image" { "english" "hash1/header.jpg" }
                "store_asset_mtime" "1790110460"
                "library_assets_full" {
                    "library_capsule" {
                        "image" { "english" "hash2/library_capsule.jpg" }
                        "image2x" { "english" "hash2/library_capsule_2x.jpg" }
                    }
                }
            }
            """)!;
        var artwork = SteamAppArtwork.Read(230410, common);
        const string root = "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/230410/";
        Require(artwork.StoreHeaderImage == root + "hash1/header.jpg?t=1790110460", "versioned store header");
        Require(artwork.LibraryCapsuleImage == root + "hash2/library_capsule_2x.jpg?t=1790110460", "high resolution portrait");
        common["store_asset_mtime"].Value = "1790110461";
        Require(SteamAppArtwork.Read(230410, common).StoreHeaderImage != artwork.StoreHeaderImage, "revision invalidates URL cache");
        common["header_image"]["english"].Value = "../header.jpg";
        common["library_assets_full"]["library_capsule"]["image2x"]["english"].Value = "https://example.com/image.jpg";
        var safe = SteamAppArtwork.Read(230410, common);
        Require(safe.StoreHeaderImage is null && safe.LibraryCapsuleImage == root + "hash2/library_capsule.jpg?t=1790110461", "unsafe path rejected and lower resolution retained");
        Require(SteamAppArtwork.Read(570, new KeyValue("common")) == new SteamAppArtwork(null, null), "missing artwork stays optional");

        var entry = new LibraryEntry(230410, "personal", "Warframe", 10, "complete", "complete",
            StoreHeaderImage: artwork.StoreHeaderImage, LibraryCapsuleImage: artwork.LibraryCapsuleImage);
        var report = new SourceReport("complete", 1);
        var result = new SteamLibraryResult(1, "76561198000000001", false,
            new SourceCoverage(report, report, report, report, report), new[] { entry }, Array.Empty<string>());
        using var json = JsonDocument.Parse(HelperJson.Library(result));
        Require(json.RootElement.GetProperty("apps")[0].GetProperty("libraryCapsuleImage").GetString() == artwork.LibraryCapsuleImage,
            "artwork survives generated JSON protocol");
    }

    private static void Require(bool condition, string message)
    {
        if (!condition) throw new InvalidOperationException($"Artwork: {message}");
    }
}
