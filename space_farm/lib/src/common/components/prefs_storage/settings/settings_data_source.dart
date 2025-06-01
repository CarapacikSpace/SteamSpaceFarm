import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_farm/src/apps/model/card_type.dart';
import 'package:space_farm/src/common/constant/localization/localization.dart';
import 'package:space_farm/src/common/persisted_entry.dart';
import 'package:space_farm/src/settings/model/app_settings.dart';

abstract interface class IAppSettingsDataSource {
  Future<void> setAppSettings(AppSettings appSettings);

  Future<AppSettings?> getAppSettings();
}

final class AppSettingsDataSource implements IAppSettingsDataSource {
  AppSettingsDataSource({required this.sharedPreferences});

  final SharedPreferencesAsync sharedPreferences;

  late final _appSettings = AppSettingsPersistedEntry(sharedPreferences: sharedPreferences, key: 'settings');

  @override
  Future<AppSettings?> getAppSettings() => _appSettings.read();

  @override
  Future<void> setAppSettings(AppSettings appSettings) => _appSettings.set(appSettings);
}

class AppSettingsPersistedEntry extends SharedPreferencesEntry<AppSettings> {
  AppSettingsPersistedEntry({required super.sharedPreferences, required super.key});

  late final _localeLanguageCode = StringPreferencesEntry(
    sharedPreferences: sharedPreferences,
    key: '$key.locale.language_code',
  );

  late final _localeCountryCode = StringPreferencesEntry(
    sharedPreferences: sharedPreferences,
    key: '$key.locale.country_code',
  );

  late final _cardType = StringPreferencesEntry(sharedPreferences: sharedPreferences, key: '$key.card_type');

  late final _textScale = DoublePreferencesEntry(sharedPreferences: sharedPreferences, key: '$key.text_scale');

  @override
  Future<AppSettings?> read() async {
    final languageCode = await _localeLanguageCode.read();
    final countryCode = await _localeCountryCode.read();

    final cardTypeName = await _cardType.read();

    final textScale = await _textScale.read();

    if (languageCode == null && countryCode == null && cardTypeName == null && textScale == null && textScale == null) {
      return null;
    }

    Locale? appLocale;

    if (languageCode != null) {
      appLocale = Locale(languageCode, countryCode);
    }
    final cardType = SteamAppCardType.values.firstWhereOrNull((t) => t.name == cardTypeName);

    return AppSettings(
      locale: appLocale ?? Localization.computeDefaultLocale(),
      cardType: cardType ?? SteamAppCardType.library,
      textScale: textScale,
    );
  }

  @override
  Future<void> remove() async {
    await (_localeLanguageCode.remove(), _localeCountryCode.remove(), _cardType.remove(), _textScale.remove()).wait;
  }

  @override
  Future<void> set(AppSettings value) async {
    await (
      _localeLanguageCode.set(value.locale.languageCode),
      _localeCountryCode.set(value.locale.countryCode ?? ''),
    ).wait;

    await _cardType.set(value.cardType.name);

    if (value.textScale != null) {
      await _textScale.set(value.textScale!);
    }
  }
}
