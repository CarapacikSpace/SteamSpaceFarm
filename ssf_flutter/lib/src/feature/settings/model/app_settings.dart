import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';

@immutable
class const AppSettings({required final Locale locale, required final SteamAppCardType cardType}) with Diagnosticable {
  AppSettings copyWith({Locale? locale, SteamAppCardType? cardType}) =>
      AppSettings(locale: locale ?? this.locale, cardType: cardType ?? this.cardType);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AppSettings && other.locale == locale && other.cardType == cardType;
  }

  @override
  int get hashCode => Object.hash(locale, cardType);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(EnumProperty<SteamAppCardType>('cardType', cardType));
    super.debugFillProperties(properties);
  }
}
