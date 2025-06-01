import 'package:flutter/material.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';

enum SteamAppType {
  game,
  demo,
  music,
  application,
  video,
  tool,
  dlc,
  other;

  factory SteamAppType.fromString(String? type, {required bool isOwnerOnly}) => switch (type?.toLowerCase()) {
    'game' when !isOwnerOnly => game,
    'demo' => demo,
    'music' => music,
    'application' => application,
    'video' => video,
    'tool' || 'game' when isOwnerOnly => tool,
    'dlc' => dlc,
    _ => other,
  };

  String localizedText(BuildContext context) => switch (this) {
    game => context.l10n.categoryGames,
    demo => context.l10n.categoryDemos,
    music => context.l10n.categorySoundtracks,
    application => context.l10n.categorySoftware,
    video => context.l10n.categoryVideos,
    tool => context.l10n.categoryTools,
    dlc => context.l10n.categoryDlc,
    _ => context.l10n.categoryOther,
  };
}
