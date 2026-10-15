import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_screen.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/appearance_settings_tab.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_navigation.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_screen.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_controller.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/widget/steam_integration_view.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_text_field.dart';

import 'catalog_presentation_test.dart' as catalog;
import 'support/steam_helper_fakes.dart';

void main() {
  for (final width in [400.0, 1100.0]) {
    testWidgets('appearance stays editable during startup refresh at $width px', (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final manager = SteamProcessManager();
      final helper = FakeSteamHelperClient();
      final sync = SteamLibrarySyncController(
        processManager: manager,
        client: helper,
        sessions: MemorySteamSessionStore()..saved = true,
      );
      await tester.pumpWidget(
        catalog.app(
          CatalogScreen(
            appsRepository: catalog.FakeCatalog(),
            steamGameService: SteamGameService(processManager: manager),
            settings: const AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.libraryCapsule),
            sessionExists: () async => true,
            startupSync: sync,
          ),
        ),
      );
      await tester.pump();
      final GeneratedLocalizations l10n = lookupGeneratedLocalizations(const Locale('ru'));
      await tester.tap(find.byTooltip(l10n.settings));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AppearanceSettingsTab), findsOneWidget);
      expect(find.text(l10n.leaveLibraryUpdateMessage), findsNothing);
      expect(sync.busy, isTrue);
      expect(helper.starts, 1);
      final Finder navigation = find.byType(width < 840 ? SettingsBottomNavigation : SettingsSideNavigation);
      final List<GestureDetector> navButtons = tester
          .widgetList<GestureDetector>(find.descendant(of: navigation, matching: find.byType(GestureDetector)))
          .toList();
      expect(navButtons.map((button) => button.onTap != null), [true, false, false, false]);
      await tester.tap(find.descendant(of: navigation, matching: find.byIcon(Icons.sync)));
      await tester.pump();
      expect(find.byType(AppearanceSettingsTab), findsOneWidget);
      final AppearanceSettingsTab appearance = tester.widget<AppearanceSettingsTab>(find.byType(AppearanceSettingsTab));
      final SteamAppCardType nextType = SteamAppCardType.values.firstWhere(
        (type) => type != appearance.settings.cardType,
      );
      appearance.onChanged(appearance.settings.copyWith(cardType: nextType));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.widget<AppearanceSettingsTab>(find.byType(AppearanceSettingsTab)).settings.cardType, nextType);
      expect(sync.busy, isTrue);
      await sync.cancel();
      await tester.pump();
      final Iterable<GestureDetector> unlocked = tester.widgetList<GestureDetector>(
        find.descendant(of: navigation, matching: find.byType(GestureDetector)),
      );
      expect(unlocked.every((button) => button.onTap != null), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('manual refresh survives switching to appearance and still guards route exit', (tester) async {
    final manager = SteamProcessManager();
    final helper = FakeSteamHelperClient();
    final sync = SteamLibrarySyncController(
      processManager: manager,
      client: helper,
      sessions: MemorySteamSessionStore()..saved = true,
    );
    await tester.pumpWidget(
      catalog.app(
        SettingsScreen(
          processManager: manager,
          appsRepository: catalog.FakeCatalog(),
          onLibraryUpdated: () async {},
          openSteam: true,
          refreshSteamLibrary: true,
          steamController: sync,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(sync.busy, isTrue);
    final SteamIntegrationViewState steamState = tester.state<SteamIntegrationViewState>(
      find.byType(SteamIntegrationView),
    );
    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AppearanceSettingsTab), findsOneWidget);
    expect(find.byType(SteamIntegrationView), findsNothing);
    expect(tester.state(find.byType(SteamIntegrationView, skipOffstage: false)), same(steamState));
    expect(sync.busy, isTrue);
    expect(helper.starts, 1);
    final GeneratedLocalizations l10n = lookupGeneratedLocalizations(const Locale('ru'));
    final Future<bool> leave = steamState.confirmLeave();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10n.leaveLibraryUpdateMessage), findsOneWidget);
    await tester.tap(find.text(l10n.cancel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(await leave, isFalse);
    expect(sync.busy, isTrue);
    await sync.cancel();
    await tester.pump();
    await tester.pump();
    expect(tester.widget<SettingsBottomNavigation>(find.byType(SettingsBottomNavigation)).appearanceOnly, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('startup refresh keeps cached cards visible and animates the header', (tester) async {
    final manager = SteamProcessManager();
    final helper = FakeSteamHelperClient();
    final sync = SteamLibrarySyncController(
      processManager: manager,
      client: helper,
      sessions: MemorySteamSessionStore()..saved = true,
    );
    await tester.pumpWidget(
      catalog.app(
        CatalogScreen(
          appsRepository: catalog.FakeCatalog(),
          steamGameService: SteamGameService(processManager: manager),
          settings: const AppSettings(locale: Locale('ru'), cardType: SteamAppCardType.libraryCapsule),
          sessionExists: () async => true,
          startupSync: sync,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Synthetic 0'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(helper.starts, 1);
    await sync.cancel();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Synthetic 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('400 px catalog keeps gutters and clears the search immediately', (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      catalog.app(
        CatalogScreen(
          appsRepository: catalog.FakeCatalog(),
          steamGameService: SteamGameService(processManager: SteamProcessManager()),
          settings: const AppSettings(
            locale: Locale('ru'),
            cardType: SteamAppCardType.libraryCapsule,
            refreshOnStartup: false,
          ),
          sessionExists: () async => true,
        ),
      ),
    );
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(CatalogScreen.searchKey)).dx, 20);
    await tester.enterText(find.byType(TextField), 'does not exist');
    await tester.pump();
    expect(find.text('Synthetic 0'), findsNothing);
    await tester.tap(find.byType(SteamClearButton));
    await tester.pump();
    expect(find.text('Synthetic 0'), findsOneWidget);
    expect(find.byType(SteamClearButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings open during games while refresh and logout remain blocked', (tester) async {
    final manager = SteamProcessManager();
    var active = true;
    final SteamProcessRegistration registration = manager.register(
      game: true,
      isActive: () => active,
      stop: () async => active = false,
    );
    final helper = FakeSteamHelperClient();
    final sessions = MemorySteamSessionStore()..saved = true;
    final sync = SteamLibrarySyncController(processManager: manager, client: helper, sessions: sessions);
    final library = SteamLibraryController(sync: sync);
    await sync.restoreOrSignIn(refresh: false);
    expect(sync.hasSavedSession, isTrue);
    await library.refresh();
    await library.logout();
    expect(helper.starts, 0);
    expect(sessions.forgotten, isFalse);
    await tester.pumpWidget(
      catalog.app(
        CatalogScreen(
          appsRepository: catalog.FakeCatalog(),
          steamGameService: SteamGameService(processManager: manager),
          settings: const AppSettings(
            locale: Locale('ru'),
            cardType: SteamAppCardType.libraryCapsule,
            refreshOnStartup: false,
          ),
          sessionExists: () async => true,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip(lookupGeneratedLocalizations(const Locale('ru')).settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    active = false;
    registration.release();
    library.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('session options have a separate tab and unlock when the last game stops', (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final manager = SteamProcessManager();
    var active = true;
    final SteamProcessRegistration registration = manager.register(
      game: true,
      isActive: () => active,
      stop: () async => active = false,
    );
    manager.updateActivity();
    await tester.pumpWidget(
      catalog.app(
        SettingsScreen(processManager: manager, appsRepository: catalog.FakeCatalog(), onLibraryUpdated: () async {}),
      ),
    );
    final GeneratedLocalizations l10n = lookupGeneratedLocalizations(const Locale('ru'));
    expect(find.text(l10n.refreshOnStartup), findsNothing);
    await tester.tap(find.text(l10n.sessionSettingsShort));
    await tester.pumpAndSettle();
    expect(find.text(l10n.sessionSettings), findsOneWidget);
    expect(find.text(l10n.refreshOnStartup), findsOneWidget);
    final List<CheckboxListTile> checkboxes = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(checkboxes, hasLength(3));
    expect((checkboxes[1].title! as Text).data, l10n.invisibleWhilePlaying);
    expect((checkboxes[2].title! as Text).data, l10n.experimentalSteamKit);
    expect(checkboxes[1].onChanged, isNull);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile).last).onChanged, isNull);
    active = false;
    manager.updateActivity();
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile).last).onChanged, isNotNull);
    registration.release();
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving an update asks first and cancels only after confirmation', (tester) async {
    final sync = SteamLibrarySyncController(
      processManager: SteamProcessManager(),
      client: FakeSteamHelperClient(),
      sessions: MemorySteamSessionStore()..saved = true,
    );
    final key = GlobalKey<SteamIntegrationViewState>();
    await tester.pumpWidget(catalog.app(SteamIntegrationView(key: key, controller: sync, autoStartQr: false)));
    // The operation stays pending until cancellation.
    final Future<void> operation = sync.start(SteamSignInMethod.session);
    await tester.pump();
    final GeneratedLocalizations l10n = lookupGeneratedLocalizations(const Locale('ru'));
    final Future<bool> firstLeave = key.currentState!.confirmLeave();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10n.leaveLibraryUpdateMessage), findsOneWidget);
    await tester.tap(find.text(l10n.cancel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(await firstLeave, isFalse);
    expect(sync.busy, isTrue);
    final Future<bool> secondLeave = key.currentState!.confirmLeave();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(l10n.leaveScreen));
    await tester.pump(const Duration(milliseconds: 400));
    expect(await secondLeave, isTrue);
    await operation;
    expect(sync.busy, isFalse);
    expect(tester.takeException(), isNull);
  });
}
