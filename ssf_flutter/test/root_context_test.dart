import 'dart:ui' show AppExitResponse;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/composition_root.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/app/model/dependencies_container.dart';
import 'package:ssf_flutter/src/feature/app/widget/material_context.dart';
import 'package:ssf_flutter/src/feature/app/widget/root_context.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';

import 'settings_scope_test.dart' show SettingsRepositoryFake, initial;

void main() {
  testWidgets('root rebuilds locale and cancels close on a failed stop, allowing retry', (tester) async {
    final manager = SteamProcessManager();
    var active = true;
    var failStop = true;
    manager.register(
      isActive: () => active,
      stop: () async {
        if (failStop) {
          throw StateError('synthetic stop failure');
        }
        active = false;
      },
    );
    await tester.pumpWidget(
      RootContext(
        compositionResult: CompositionResult(
          millisecondsSpent: 0,
          dependencies: DependenciesContainer(
            processManager: manager,
            steamGameService: SteamGameService(processManager: manager),
            appsRepository: EmptyCatalog(),
            settingsRepository: SettingsRepositoryFake(),
            initialSettings: initial,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final SettingsScopeState settings = SettingsScope.of(tester.element(find.byType(MaterialContext)), listen: false);
    final Future<bool> saved = settings.update((current) => current.copyWith(locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(await saved, isTrue);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, const Locale('en'));
    expect(await tester.binding.handleRequestAppExit(), AppExitResponse.cancel);
    await tester.pump(const Duration(milliseconds: 300));
    expect(active, isTrue);
    final Finder notice = find.byKey(const ValueKey('steam-notice'));
    expect(notice, findsOneWidget);
    expect(tester.getSize(notice).height, greaterThanOrEqualTo(31));
    expect(tester.getCenter(notice).dx, closeTo(tester.view.physicalSize.width / 2 / tester.view.devicePixelRatio, 1));
    failStop = false;
    expect(await tester.binding.handleRequestAppExit(), AppExitResponse.exit);
    expect(active, isFalse);
    expect(tester.takeException(), isNull);
  });
}

class EmptyCatalog() implements IAppsRepository {
  @override
  Future<List<LocalApp>> getAppsFromCache() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
