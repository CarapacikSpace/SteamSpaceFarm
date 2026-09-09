import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/storage/shared_preferences_column.dart';

abstract interface class IAppSettingsDataSource() {
  Future<void> setAppSettings(AppSettings appSettings);

  Future<AppSettings?> getAppSettings();
}

final class AppSettingsDataSource({required final SharedPreferencesAsync sharedPreferences})
    implements IAppSettingsDataSource {
  late final _appSettings = AppSettingsColumn(sharedPreferences: sharedPreferences, key: 'settings');

  @override
  Future<AppSettings?> getAppSettings() => _appSettings.read();

  @override
  Future<void> setAppSettings(AppSettings appSettings) => _appSettings.set(appSettings);
}

final class AppSettingsColumn({required super.sharedPreferences, required super.key})
    extends SharedPreferencesColumn<AppSettings> {
  late final _localeLanguageCode = SharedPreferencesColumnString(
    sharedPreferences: sharedPreferences,
    key: '$key.locale.language_code',
  );

  late final _localeCountryCode = SharedPreferencesColumnString(
    sharedPreferences: sharedPreferences,
    key: '$key.locale.country_code',
  );

  late final _cardType = SharedPreferencesColumnString(sharedPreferences: sharedPreferences, key: '$key.card_type');

  @override
  Future<AppSettings?> read() async {
    final String? languageCode = await _localeLanguageCode.read();
    final String? countryCode = await _localeCountryCode.read();

    final String? cardTypeName = await _cardType.read();

    if (languageCode == null && countryCode == null && cardTypeName == null) {
      return null;
    }

    Locale? appLocale;

    if (languageCode != null) {
      appLocale = Localization.resolve(Locale(languageCode, countryCode));
    }
    final SteamAppCardType? cardType = _parseCardType(cardTypeName);

    return AppSettings(
      locale: appLocale ?? Localization.deviceLocale,
      cardType: cardType ?? SteamAppCardType.libraryCapsule,
    );
  }

  @override
  Future<void> set(AppSettings value) async {
    await (
      _localeLanguageCode.set(value.locale.languageCode),
      _localeCountryCode.set(value.locale.countryCode ?? ''),
    ).wait;

    await _cardType.set(value.cardType.name);
  }
}

SteamAppCardType? _parseCardType(String? storedName) => switch (storedName) {
  'library' => SteamAppCardType.libraryCapsule,
  'header' => SteamAppCardType.storeHeader,
  'icon' => SteamAppCardType.appIcon,
  _ => SteamAppCardType.values.firstWhereOrNull((type) => type.name == storedName),
};
