import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/settings/logic/app_settings_bloc.dart';
import 'package:space_farm/src/steam/data/steam_game.dart';

class DependenciesContainer {
  const DependenciesContainer({
    required this.appSettingsBloc,
    required this.appsRepository,
    required this.steamGameService,
  });

  final AppSettingsBloc appSettingsBloc;
  final IAppsRepository appsRepository;
  final SteamGameService steamGameService;
}
