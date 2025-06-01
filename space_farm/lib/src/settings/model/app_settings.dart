import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:space_farm/src/apps/model/card_type.dart';

@immutable
class AppSettings with Diagnosticable {
  const AppSettings({required this.locale, required this.cardType, this.textScale});

  final Locale locale;
  final double? textScale;
  final SteamAppCardType cardType;

  AppSettings copyWith({Locale? locale, double? textScale, SteamAppCardType? cardType}) => AppSettings(
    locale: locale ?? this.locale,
    textScale: textScale ?? this.textScale,
    cardType: cardType ?? this.cardType,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AppSettings && other.locale == locale && other.textScale == textScale && other.cardType == cardType;
  }

  @override
  int get hashCode => Object.hash(locale, textScale, cardType);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(DoubleProperty('textScale', textScale))
      ..add(EnumProperty<SteamAppCardType>('cardType', cardType));
    super.debugFillProperties(properties);
  }
}
