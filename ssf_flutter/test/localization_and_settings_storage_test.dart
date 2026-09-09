import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_data_source.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/localization/localization.dart';

void main() {
  test('locale resolution accepts regional variants and falls back to English', () {
    expect(Localization.resolve(const Locale('ru', 'RU')), const Locale('ru'));
    expect(Localization.resolve(const Locale('en', 'GB')), const Locale('en'));
    expect(Localization.resolve(const Locale('fr')), const Locale('en'));
  });
  test('settings persist and reload through renamed preferences columns', () async {
    final prefs = MemoryPreferences();
    final source = AppSettingsDataSource(sharedPreferences: prefs);
    expect(await source.getAppSettings(), isNull);
    const settings = AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.appIcon);
    await source.setAppSettings(settings);
    expect(await AppSettingsDataSource(sharedPreferences: prefs).getAppSettings(), settings);
    expect(prefs.values['settings.locale.language_code'], 'ru');
    expect(prefs.values['settings.card_type'], 'appIcon');
  });
}

class MemoryPreferences() implements SharedPreferencesAsync {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
