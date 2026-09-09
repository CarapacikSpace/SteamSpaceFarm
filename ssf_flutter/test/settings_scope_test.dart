import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_repository.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';

const initial = AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.libraryCapsule);

void main() {
  testWidgets('Inherited settings serialize updates and expose failure and retry', (tester) async {
    final repository = SettingsRepositoryFake();
    late SettingsScopeState scope;
    await tester.pumpWidget(
      SettingsScope(
        repository: repository,
        initialSettings: initial,
        child: Builder(
          builder: (context) {
            scope = SettingsScope.of(context);
            return Text(scope.settings.locale.languageCode, textDirection: TextDirection.ltr);
          },
        ),
      ),
    );
    repository.gate = Completer<void>();
    final Future<bool> first = scope.update((value) => value.copyWith(locale: const Locale('en')));
    final Future<bool> second = scope.update((value) => value.copyWith(cardType: SteamAppCardType.appIcon));
    await tester.pump();
    expect(scope.isSaving, isTrue);
    expect(scope.settings, initial);
    repository.gate!.complete();
    await tester.pump();
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(scope.settings.locale, const Locale('en'));
    expect(scope.settings.cardType, SteamAppCardType.appIcon);
    expect(find.text('en'), findsOneWidget);
    repository.fail = true;
    final Future<bool> failed = scope.update((value) => value.copyWith(locale: const Locale('ru')));
    await tester.pump();
    expect(await failed, isFalse);
    expect(scope.settings.locale, const Locale('en'));
    expect(scope.error, isNotNull);
    repository.fail = false;
    final Future<bool> retry = scope.retry();
    await tester.pump();
    expect(await retry, isTrue);
    expect(scope.error, isNull);
    expect(find.text('ru'), findsOneWidget);
    expect(repository.saved.last, scope.settings);
  });

  testWidgets('an in-flight save finishes without setState after scope disposal', (tester) async {
    final repository = SettingsRepositoryFake()..gate = Completer<void>();
    final key = GlobalKey<SettingsScopeState>();
    await tester.pumpWidget(
      SettingsScope(key: key, repository: repository, initialSettings: initial, child: const SizedBox()),
    );
    final Future<bool> save = key.currentState!.update((value) => value.copyWith(locale: const Locale('en')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    repository.gate!.complete();
    expect(await save, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class SettingsRepositoryFake() implements IAppSettingsRepository {
  final saved = <AppSettings>[];
  Completer<void>? gate;
  bool fail = false;

  @override
  Future<AppSettings?> getAppSettings() async => saved.lastOrNull;

  @override
  Future<void> setAppSettings(AppSettings appSettings) async {
    await gate?.future;
    if (fail) {
      throw StateError('synthetic write failure');
    }
    saved.add(appSettings);
  }
}
