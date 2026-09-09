import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_app_context_menu.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_screen.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_screen.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_dropdown.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_flyout.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

import 'catalog_presentation_test.dart' show FakeCatalog, app;
import 'root_context_test.dart' show EmptyCatalog;
import 'settings_scope_test.dart' show SettingsRepositoryFake, initial;

void main() {
  testWidgets('dropdown flips, selects and dismisses with Escape and outside click', (tester) async {
    String? selected;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: SteamDropdown<String>(
              items: const ['first', 'second'],
              value: 'first',
              labelBuilder: (v) => v,
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('first'));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('second')).bottom,
      lessThan(tester.getRect(find.byType(SteamDropdown<String>)).top),
    );
    await tester.tap(find.text('second'));
    await tester.pumpAndSettle();
    expect(selected, 'second');
    expect(find.text('second'), findsNothing);
    await tester.tap(find.text('first'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    await tester.tap(find.text('first'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('right-click menu fits at edge and submenu selection dismisses both', (tester) async {
    CatalogAppMenuAction? action;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: CatalogAppContextMenu(
              app: const LocalApp(appId: 480, name: 'Test', type: SteamAppType.game),
              onActionSelected: (value) => action = value,
              childBuilder: (_) => const SizedBox(width: 180, height: 240, child: Text('card')),
            ),
          ),
        ),
      ),
    );
    final TestGesture gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.down(tester.getBottomRight(find.byType(CatalogAppContextMenu)) - const Offset(5, 5));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Добавить в избранное'), findsOneWidget);
    final Rect menu = tester.getRect(find.byType(SteamFlyoutReveal).first);
    expect(menu.right, lessThanOrEqualTo(800));
    expect(menu.bottom, lessThanOrEqualTo(600));
    final double widestText = tester
        .widgetList<Text>(find.descendant(of: find.byType(SteamFlyoutReveal), matching: find.byType(Text)))
        .map((text) => tester.getSize(find.text(text.data!)).width)
        .reduce((a, b) => a > b ? a : b);
    expect(menu.width, closeTo(widestText + 20, 1));
    await tester.tap(find.text('Изменить…'));
    await tester.pumpAndSettle();
    expect(find.byType(SteamFlyoutReveal), findsNWidgets(2));

    final Finder submenuButtons = find.descendant(
      of: find.byType(SteamFlyoutReveal).last,
      matching: find.byType(TextButton),
    );
    await tester.tap(submenuButtons.first);
    await tester.pumpAndSettle();
    expect(action, CatalogAppMenuAction.currentTime);
    expect(find.byType(SteamFlyoutReveal), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language notification uses the newly selected locale', (tester) async {
    await tester.pumpWidget(
      SettingsScope(
        repository: SettingsRepositoryFake(),
        initialSettings: initial,
        child: Builder(
          builder: (context) => MaterialApp(
            theme: buildSteamTheme(),
            locale: SettingsScope.of(context).settings.locale,
            localizationsDelegates: Localization.localizationDelegates,
            supportedLocales: Localization.supportedLocales,
            home: SettingsScreen(
              processManager: SteamProcessManager(),
              appsRepository: FakeCatalog(),
              onLibraryUpdated: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SteamDropdown<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Английский'));
    await tester.pumpAndSettle();
    expect(find.text('Settings saved'), findsOneWidget);
    expect(find.text('Настройки сохранены'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty cache with a session offers refresh instead of login', (tester) async {
    await tester.pumpWidget(
      app(
        CatalogScreen(
          appsRepository: EmptyCatalog(),
          steamGameService: SteamGameService(processManager: SteamProcessManager()),
          settings: initial,
          sessionExists: () async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Подключить Steam'), findsNothing);
    expect(find.text('Обновить библиотеку'), findsOneWidget);
    expect(find.textContaining('Вход в Steam уже выполнен'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
