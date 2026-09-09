import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_labels.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

class const CatalogAppCard({
  required final LocalApp app,
  required final SteamAppCardType cardType,
  required final bool useHours,
  required final bool isRunning,
  required final VoidCallback onTap,
  required final VoidCallback onMenuRequested,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? playtime = app.playtimeMinutes == null
        ? null
        : _formatPlaytime(app.playtimeMinutes, useHours && app.playtimeMinutes! >= 120);
    final String? markedTime = app.stopAtMinutes == null ? null : _formatPlaytime(app.stopAtMinutes, useHours);
    final Widget marker = SteamOwnershipMarker(
      label: _ownershipLabel(app.libraryOwnership),
      ownership: _ownershipVisual(app.libraryOwnership),
      favorite: app.isFavorite,
      markedTime: cardType == SteamAppCardType.appIcon ? null : markedTime,
    );

    return switch (cardType) {
      SteamAppCardType.libraryCapsule => SteamPortraitCard(
        artwork: _SteamArtwork(imageUrls: app.libraryCapsuleImageUrls, name: app.name),
        details: _CardDetails(app: app),
        playtimeLabel: playtime,
        marker: marker,
        onActivate: onTap,
        onMenuPressed: onMenuRequested,
        isRunning: isRunning,
      ),
      SteamAppCardType.mainCapsule => SteamStoreHeaderCard(
        artwork: _SteamArtwork(imageUrls: app.mainCapsuleImageUrls, name: app.name),
        imageAspectRatio: 616 / 353,
        title: app.name,
        typeLabel: appTypeLabel(app.type),
        playtimeLabel: playtime,
        marker: marker,
        onActivate: onTap,
        onMenuPressed: onMenuRequested,
        isRunning: isRunning,
      ),
      SteamAppCardType.storeHeader => SteamStoreHeaderCard(
        artwork: _SteamArtwork(imageUrls: app.storeHeaderImageUrls, name: app.name),
        title: app.name,
        typeLabel: appTypeLabel(app.type),
        playtimeLabel: playtime,
        marker: marker,
        onActivate: onTap,
        onMenuPressed: onMenuRequested,
        isRunning: isRunning,
      ),
      SteamAppCardType.appIcon => SteamIconContentCard(
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SteamImageWithFallback(
            imageUrls: app.appIconImageUrls,
            fallback: ColoredBox(
              color: const Color(0xFF24364A),
              child: Center(
                child: Text(
                  _firstLetter(app.name),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        marker: marker,
        content: _IconDetails(app: app, isRunning: isRunning),
        playtimeLabel: playtime,
        markedTimeLabel: markedTime,
        onPressed: onTap,
        onMenuPressed: onMenuRequested,
      ),
    };
  }
}

class const _SteamArtwork({required final List<String> imageUrls, required final String name}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SteamImageWithFallback(
    imageUrls: imageUrls,
    fallback: SteamImageTextFallback(text: name),
  );
}

class const _CardDetails({required final LocalApp app}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        app.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(appTypeLabel(app.type), style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

class const _IconDetails({required final LocalApp app, required final bool isRunning}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        app.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 17 / 14),
      ),
      Text(
        isRunning
            ? GeneratedLocalizations.of(context).appTypeRunningLabel(appTypeLabel(app.type))
            : appTypeLabel(app.type),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isRunning ? SteamUiColors.running : SteamUiColors.textMuted,
          fontSize: 11,
          height: 14 / 11,
        ),
      ),
    ],
  );
}

SteamOwnershipVisual _ownershipVisual(LibraryOwnership ownership) => switch (ownership) {
  LibraryOwnership.personal => SteamOwnershipVisual.personal,
  LibraryOwnership.family => SteamOwnershipVisual.family,
  LibraryOwnership.unknown => SteamOwnershipVisual.unknown,
};

String _ownershipLabel(LibraryOwnership ownership) => switch (ownership) {
  LibraryOwnership.personal => GeneratedLocalizations.current.ownershipPersonal,
  LibraryOwnership.family => 'Family',
  LibraryOwnership.unknown => GeneratedLocalizations.current.ownershipUnknown,
};

String _formatPlaytime(int? minutes, bool useHours) {
  if (minutes == null) {
    return '—';
  }
  return useHours
      ? GeneratedLocalizations.current.playtimeHours((minutes / 60).toStringAsFixed(1))
      : GeneratedLocalizations.current.playtimeMinutes(minutes);
}

String _firstLetter(String value) {
  final String trimmed = value.trim();
  return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
}
