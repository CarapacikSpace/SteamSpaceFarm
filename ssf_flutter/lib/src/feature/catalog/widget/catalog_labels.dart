import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

String appTypeLabel(SteamAppType type) => switch (type) {
  SteamAppType.game => GeneratedLocalizations.current.game,
  SteamAppType.demo => GeneratedLocalizations.current.demo,
  SteamAppType.music => GeneratedLocalizations.current.soundtrack,
  SteamAppType.application => GeneratedLocalizations.current.application,
  SteamAppType.video => GeneratedLocalizations.current.video,
  SteamAppType.tool => GeneratedLocalizations.current.tool,
  SteamAppType.dlc => 'DLC',
  SteamAppType.other => GeneratedLocalizations.current.other,
};

String ownershipLabel(LibraryOwnership ownership) => switch (ownership) {
  LibraryOwnership.personal => GeneratedLocalizations.current.ownershipPersonalFilter,
  LibraryOwnership.family => 'Steam Family',
  LibraryOwnership.unknown => GeneratedLocalizations.current.ownershipUnknownFilter,
};
