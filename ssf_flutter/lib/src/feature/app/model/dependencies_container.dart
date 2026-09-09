import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_repository.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';

class const DependenciesContainer({
  required final IAppsRepository appsRepository,
  required final SteamGameService steamGameService,
  required final SteamProcessManager processManager,
  required final IAppSettingsRepository settingsRepository,
  required final AppSettings initialSettings,
});
