import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_app_card.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_screen.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_repository.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_screen.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_playtime_badge.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

Widget app(Widget home) => MaterialApp(
  theme: buildSteamTheme(),
  locale: const Locale('ru'),
  localizationsDelegates: Localization.localizationDelegates,
  supportedLocales: Localization.supportedLocales,
  home: SettingsScope(
    repository: FakeSettings(),
    initialSettings: const AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.libraryCapsule),
    child: home,
  ),
);

void main() {
  setUp(() => GeneratedLocalizations.load(const Locale('ru')));
  for (final double width in [500, 1000, 1400]) {
    testWidgets('filters overlay the catalog without moving it at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const settings = AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.appIcon);
      await tester.pumpWidget(
        app(
          CatalogScreen(
            appsRepository: FakeCatalog(),
            steamGameService: SteamGameService(processManager: SteamProcessManager()),
            settings: settings,
          ),
        ),
      );
      await tester.pump();
      final Finder catalog = find.byKey(CatalogScreen.catalogKey, skipOffstage: false);
      final Rect before = tester.getRect(catalog);
      expect(tester.getSize(find.byKey(CatalogScreen.searchKey)).height, 34);
      expect(tester.getSize(find.byKey(CatalogScreen.filtersKey)).height, 34);
      await tester.tap(find.byKey(CatalogScreen.filtersKey));
      await tester.pumpAndSettle();
      expect(tester.getRect(catalog), before);
      expect(find.byType(ModalBarrier), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('all card types hide unknown time and switch from minutes at 120', (tester) async {
    for (final SteamAppCardType type in SteamAppCardType.values) {
      for (final minutes in <int?>[null, 0, 119, 120]) {
        await tester.pumpWidget(
          app(
            Scaffold(
              body: Center(
                child: SizedBox(
                  width: type == SteamAppCardType.appIcon ? 400 : 170,
                  height: switch (type) {
                    SteamAppCardType.libraryCapsule => 275,
                    SteamAppCardType.mainCapsule => 173,
                    SteamAppCardType.storeHeader => 155,
                    SteamAppCardType.appIcon => 60,
                  },
                  child: CatalogAppCard(
                    app: LocalApp(appId: 480, name: 'Synthetic', type: SteamAppType.game, playtimeMinutes: minutes),
                    cardType: type,
                    useHours: true,
                    isRunning: false,
                    onTap: () {},
                    onMenuRequested: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        if (type == SteamAppCardType.libraryCapsule) {
          final Size artwork = tester.getSize(find.byKey(const ValueKey('portrait-artwork')));
          expect(artwork.height / artwork.width, closeTo(1.5, .001));
        }
        if (minutes == null) {
          expect(find.byType(SteamPlaytimeBadge), findsNothing, reason: type.name);
        } else {
          final SteamPlaytimeBadge badge = tester.widget<SteamPlaytimeBadge>(find.byType(SteamPlaytimeBadge));
          expect(badge.label, minutes < 120 ? '$minutes мин' : '2.0 ч', reason: type.name);
        }
        expect(tester.takeException(), isNull);
      }
    }
  });

  for (final SteamAppCardType type in [SteamAppCardType.libraryCapsule, SteamAppCardType.appIcon]) {
    testWidgets('search stays fixed while ${type.name} catalog scrolls', (tester) async {
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = AppSettings(locale: const Locale('ru'), cardType: type);
      await tester.pumpWidget(
        app(
          CatalogScreen(
            appsRepository: FakeCatalog(),
            steamGameService: SteamGameService(processManager: SteamProcessManager()),
            settings: settings,
          ),
        ),
      );
      await tester.pump();
      final Offset before = tester.getTopLeft(find.byKey(CatalogScreen.searchKey));
      final Finder scrollable = find
          .descendant(of: find.byKey(CatalogScreen.catalogKey), matching: find.byType(Scrollable))
          .first;
      await tester.drag(find.byKey(CatalogScreen.catalogKey), const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.state<ScrollableState>(scrollable).position.pixels, greaterThan(0));
      expect(tester.getTopLeft(find.byKey(CatalogScreen.searchKey)), before);
      expect(find.byTooltip('Очистить кеш игр'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cache has its own third settings tab and keeps the account', (tester) async {
    tester.view.physicalSize = const Size(1200, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeCatalog();
    await tester.pumpWidget(
      app(
        SettingsScreen(
          processManager: SteamProcessManager(),
          appsRepository: repository,
          onLibraryUpdated: () async {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Очистить кеш библиотеки'), findsNothing);
    await tester.tap(find.text('Кеш библиотеки'));
    await tester.pump();
    await tester.pump();
    expect(find.text('В кеше 100 приложений'), findsOneWidget);
    await tester.tap(find.text('Очистить кеш библиотеки'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.cleared, isTrue);
    expect(repository.forgot, isFalse);
    expect(find.text('В кеше нет приложений'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class FakeCatalog() implements IAppsRepository {
  bool cleared = false;
  bool forgot = false;

  @override
  Future<List<LocalApp>> getAppsFromCache() async => List.generate(
    100,
    (i) => LocalApp(appId: i + 1, name: 'Synthetic $i', type: SteamAppType.game, playtimeMinutes: 150),
  );

  @override
  Future<void> clearLibraryCache({bool forgetAccount = false}) async {
    cleared = true;
    forgot = forgetAccount;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettings() implements IAppSettingsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
