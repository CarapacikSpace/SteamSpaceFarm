import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_farm/src/common/components/prefs_storage/load_apps/load_apps_data_source.dart';
import 'package:space_farm/src/common/components/prefs_storage/local_apps/local_apps_data_source.dart';
import 'package:space_farm/src/common/components/prefs_storage/settings/settings_data_source.dart';

final class PrefsStorage {
  PrefsStorage({required SharedPreferencesAsync sharedPreferences}) : _sharedPreferences = sharedPreferences;

  final SharedPreferencesAsync _sharedPreferences;

  ILoadAppsDataSource? _loadAppsDataSource;
  ILocalAppsDataSource? _localAppsDataSource;
  IAppSettingsDataSource? _appSettingsDatasource;

  ILoadAppsDataSource get loadAppsDataSource =>
      _loadAppsDataSource ??= LoadAppsDataSource(sharedPreferences: _sharedPreferences);

  ILocalAppsDataSource get localAppsDataSource =>
      _localAppsDataSource ??= LocalAppsDataSource(sharedPreferences: _sharedPreferences);

  IAppSettingsDataSource get appSettingsDatasource =>
      _appSettingsDatasource ??= AppSettingsDataSource(sharedPreferences: _sharedPreferences);

  Future<void> remove() async {
    await loadAppsDataSource.remove();
    await localAppsDataSource.remove();
  }
}
