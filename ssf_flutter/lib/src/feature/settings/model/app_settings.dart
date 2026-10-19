import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_farming_mode.dart';

@immutable
class const AppSettings({
  required final Locale locale,
  required final SteamAppCardType cardType,
  final CardFarmingMode cardFarmingMode = CardFarmingMode.fast,
  final bool refreshPlaytimeHourly = true,
  final bool refreshOnStartup = true,
  final bool invisibleWhilePlaying = true,
  final bool experimentalSteamKit = true,
}) with Diagnosticable {
  AppSettings copyWith({
    Locale? locale,
    SteamAppCardType? cardType,
    CardFarmingMode? cardFarmingMode,
    bool? refreshPlaytimeHourly,
    bool? refreshOnStartup,
    bool? invisibleWhilePlaying,
    bool? experimentalSteamKit,
  }) => AppSettings(
    cardFarmingMode: cardFarmingMode ?? this.cardFarmingMode,
    refreshPlaytimeHourly: refreshPlaytimeHourly ?? this.refreshPlaytimeHourly,
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
        other.cardFarmingMode == cardFarmingMode &&
        other.refreshPlaytimeHourly == refreshPlaytimeHourly &&
        other.locale == locale &&
        other.cardType == cardType &&
        other.refreshOnStartup == refreshOnStartup &&
        other.invisibleWhilePlaying == invisibleWhilePlaying &&
        other.experimentalSteamKit == experimentalSteamKit;
  }

  @override
  int get hashCode => Object.hash(
    cardFarmingMode,
    refreshPlaytimeHourly,
    locale,
    cardType,
    refreshOnStartup,
    invisibleWhilePlaying,
    experimentalSteamKit,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(EnumProperty<SteamAppCardType>('cardType', cardType));
    super.debugFillProperties(properties);
  }
}
