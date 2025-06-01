import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/common/components/prefs_storage/prefs_storage.dart';
import 'package:space_farm/src/common/components/prefs_storage/settings/settings_data_source.dart';
import 'package:space_farm/src/initialization/model/dependencies_container.dart';
import 'package:space_farm/src/settings/data/settings_repository.dart';
import 'package:space_farm/src/settings/logic/app_settings_bloc.dart';
import 'package:space_farm/src/steam/data/steam_game.dart';
import 'package:space_farm/src/steam/data/steam_hours.dart';
import 'package:space_farm/src/steam/data/steam_kit.dart';

/// {@template composition_root}
/// A place where Application-Wide dependencies are initialized.
///
/// Application-Wide dependencies are dependencies that have a global scope,
/// used in the entire application and have a lifetime that is the same as the application.
/// {@endtemplate}
///
/// {@template composition_process}
/// Composition of dependencies is a process of creating and configuring
/// instances of classes that are required for the application to work.
/// {@endtemplate}
/// Composes dependencies and returns the result of composition.
Future<CompositionResult> composeDependencies() async {
  final stopwatch = clock.stopwatch()..start();

  // Create the dependencies container using functions.
  final dependencies = await createDependenciesContainer();

  stopwatch.stop();
  log('Dependencies initialized successfully in ${stopwatch.elapsedMilliseconds} ms.');

  return CompositionResult(dependencies: dependencies, millisecondsSpent: stopwatch.elapsedMilliseconds);
}

/// {@template composition_result}
/// Result of composition.
///
/// {@macro composition_process}
/// {@endtemplate}
final class CompositionResult {
  /// {@macro composition_result}
  const CompositionResult({required this.dependencies, required this.millisecondsSpent});

  /// The dependencies container.
  final DependenciesContainer dependencies;

  /// The number of milliseconds spent composing dependencies.
  final int millisecondsSpent;

  @override
  String toString() =>
      'CompositionResult('
      'dependencies: $dependencies, '
      'millisecondsSpent: $millisecondsSpent'
      ')';
}

/// Creates the full dependencies container.
Future<DependenciesContainer> createDependenciesContainer() async {
  final sharedPreferences = SharedPreferencesAsync();

  final prefsStorage = PrefsStorage(sharedPreferences: sharedPreferences);
  final appSettingsBloc = await createAppSettingsBloc(sharedPreferences);
  final steamKitService = SteamKitService();
  final steamHoursService = SteamHoursService();
  final steamGameService = SteamGameService();

  final IAppsRepository appsRepository = AppsRepository(
    loadAppsDataSource: prefsStorage.loadAppsDataSource,
    localAppsDataSource: prefsStorage.localAppsDataSource,
    steamKitService: steamKitService,
    steamHoursService: steamHoursService,
  );

  return DependenciesContainer(
    appSettingsBloc: appSettingsBloc,
    appsRepository: appsRepository,
    steamGameService: steamGameService,
  );
}

Future<AppSettingsBloc> createAppSettingsBloc(SharedPreferencesAsync sharedPreferences) async {
  final appSettingsRepository = AppSettingsRepository(
    datasource: AppSettingsDataSource(sharedPreferences: sharedPreferences),
  );

  final appSettings = await appSettingsRepository.getAppSettings();
  final initialState = AppSettingsState.idle(appSettings: appSettings);

  return AppSettingsBloc(appSettingsRepository: appSettingsRepository, initialState: initialState);
}
