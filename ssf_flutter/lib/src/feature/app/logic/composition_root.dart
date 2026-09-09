import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/app/model/dependencies_container.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_data_source.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_repository.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';

Future<CompositionResult> composeDependencies() async {
  final stopwatch = Stopwatch()..start();
  await AppPaths.initialize();
  final repository = AppSettingsRepository(
    datasource: AppSettingsDataSource(sharedPreferences: SharedPreferencesAsync()),
  );
  final AppSettings settings =
      await repository.getAppSettings() ??
      AppSettings(locale: Localization.deviceLocale, cardType: SteamAppCardType.libraryCapsule);
  final manager = SteamProcessManager();
  final dependencies = DependenciesContainer(
    appsRepository: AppsRepository(),
    steamGameService: SteamGameService(processManager: manager),
    processManager: manager,
    settingsRepository: repository,
    initialSettings: settings,
  );
  AppLogger.info('Ready in ${stopwatch.elapsedMilliseconds} ms');
  return CompositionResult(dependencies: dependencies, millisecondsSpent: stopwatch.elapsedMilliseconds);
}

class const CompositionResult({
  required final DependenciesContainer dependencies,
  required final int millisecondsSpent,
});
