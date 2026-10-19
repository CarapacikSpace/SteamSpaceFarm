import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_farming_mode.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_data_source.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/localization/localization.dart';

void main() {
  test('locale resolution accepts regional variants and falls back to English', () {
    expect(Localization.resolve(const Locale('ru', 'RU')), const Locale('ru'));
    expect(Localization.resolve(const Locale('en', 'GB')), const Locale('en'));
    expect(Localization.resolve(const Locale('fr')), const Locale('en'));
    expect(Localization.resolve(const Locale('es', 'MX')), const Locale('es'));
    expect(Localization.resolve(const Locale('zh', 'CN')), const Locale('zh'));
    expect(Localization.resolve(const Locale('zh', 'SG')), const Locale('zh'));
  });
  test('session defaults apply to older preferences and preserve opt-out', () async {
    final prefs = MemoryPreferences()..values['settings.locale.language_code'] = 'ru';
    final source = AppSettingsDataSource(sharedPreferences: prefs);
    final AppSettings settings = (await source.getAppSettings())!;
    expect(settings.refreshOnStartup, isTrue);
    expect(settings.invisibleWhilePlaying, isTrue);
    expect(settings.experimentalSteamKit, isTrue);
    expect(settings.cardFarmingMode, CardFarmingMode.fast);
    expect(settings.refreshPlaytimeHourly, isTrue);
    await source.setAppSettings(
      settings.copyWith(
        refreshOnStartup: false,
        invisibleWhilePlaying: false,
        experimentalSteamKit: false,
        refreshPlaytimeHourly: false,
      ),
    );
    expect((await source.getAppSettings())!.refreshOnStartup, isFalse);
    expect((await source.getAppSettings())!.invisibleWhilePlaying, isFalse);
    expect((await source.getAppSettings())!.experimentalSteamKit, isFalse);
    expect((await source.getAppSettings())!.refreshPlaytimeHourly, isFalse);
  });
  test('Chinese translations load, format counts and persist the selected locale', () async {
    final GeneratedLocalizations l10n = await GeneratedLocalizations.delegate.load(const Locale('zh'));
    expect(l10n.settings, '设置');
    expect(l10n.cardsCount(18), '卡牌 18');
    expect(l10n.libraryCacheAppCount(0), '没有已缓存的应用');
    expect(l10n.libraryCacheAppCount(1), '已缓存 1 个应用');
    expect(l10n.libraryCacheAppCount(12), '已缓存 12 个应用');
    expect(l10n.gameSessionInterrupted('Dota 2', 570), contains('Dota 2（AppID 570）'));
    final source = AppSettingsDataSource(sharedPreferences: MemoryPreferences());
    const settings = AppSettings(locale: Locale('zh'), cardType: SteamAppCardType.libraryCapsule);
    await source.setAppSettings(settings);
    expect(await source.getAppSettings(), settings);
  });
  test('settings persist and reload through renamed preferences columns', () async {
    final prefs = MemoryPreferences();
    final source = AppSettingsDataSource(sharedPreferences: prefs);
    expect(await source.getAppSettings(), isNull);
    const settings = AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.appIcon);
    expect(settings.experimentalSteamKit, isTrue);
    expect(settings.refreshPlaytimeHourly, isTrue);
    await source.setAppSettings(settings);
    expect(await AppSettingsDataSource(sharedPreferences: prefs).getAppSettings(), settings);
    expect(prefs.values['settings.locale.language_code'], 'ru');
    expect(prefs.values['settings.card_type'], 'appIcon');
  });
  test('all card modes and hourly settings survive saving and invalid modes use Fast', () async {
    final prefs = MemoryPreferences();
    final source = AppSettingsDataSource(sharedPreferences: prefs);
    for (final CardFarmingMode mode in CardFarmingMode.values) {
      final settings = AppSettings(
        locale: const Locale('es'),
        cardType: SteamAppCardType.appIcon,
        cardFarmingMode: mode,
        refreshPlaytimeHourly: false,
      );
      await source.setAppSettings(settings);
      expect(await source.getAppSettings(), settings);
    }
    prefs.values['settings.card_farming_mode'] = 'unknown';
    expect((await source.getAppSettings())!.cardFarmingMode, CardFarmingMode.fast);
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
