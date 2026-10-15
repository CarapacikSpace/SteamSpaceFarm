import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

String appTypeLabel(GeneratedLocalizations l10n, SteamAppType type) => switch (type) {
  SteamAppType.game => l10n.game,
  SteamAppType.demo => l10n.demo,
  SteamAppType.music => l10n.soundtrack,
  SteamAppType.application => l10n.application,
  SteamAppType.video => l10n.video,
  SteamAppType.tool => l10n.tool,
  SteamAppType.dlc => 'DLC',
  SteamAppType.other => l10n.other,
};

String ownershipLabel(GeneratedLocalizations l10n, LibraryOwnership ownership) => switch (ownership) {
  LibraryOwnership.personal => l10n.ownershipPersonalFilter,
  LibraryOwnership.family => 'Steam Family',
  LibraryOwnership.unknown => l10n.ownershipUnknownFilter,
};
