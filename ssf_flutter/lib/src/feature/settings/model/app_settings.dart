import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';

@immutable
class const AppSettings({
  required final Locale locale,
  required final SteamAppCardType cardType,
  final bool refreshOnStartup = true,
  final bool invisibleWhilePlaying = true,
  final bool experimentalSteamKit = false,
}) with Diagnosticable {
  AppSettings copyWith({
    Locale? locale,
    SteamAppCardType? cardType,
    bool? refreshOnStartup,
    bool? invisibleWhilePlaying,
    bool? experimentalSteamKit,
  }) => AppSettings(
    locale: locale ?? this.locale,
    cardType: cardType ?? this.cardType,
    refreshOnStartup: refreshOnStartup ?? this.refreshOnStartup,
    invisibleWhilePlaying: invisibleWhilePlaying ?? this.invisibleWhilePlaying,
    experimentalSteamKit: experimentalSteamKit ?? this.experimentalSteamKit,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AppSettings &&
        other.locale == locale &&
        other.cardType == cardType &&
        other.refreshOnStartup == refreshOnStartup &&
        other.invisibleWhilePlaying == invisibleWhilePlaying &&
        other.experimentalSteamKit == experimentalSteamKit;
  }

  @override
  int get hashCode => Object.hash(locale, cardType, refreshOnStartup, invisibleWhilePlaying, experimentalSteamKit);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(EnumProperty<SteamAppCardType>('cardType', cardType));
    super.debugFillProperties(properties);
  }
}
