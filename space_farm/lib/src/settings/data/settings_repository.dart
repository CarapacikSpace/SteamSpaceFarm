import 'package:space_farm/src/common/components/prefs_storage/settings/settings_data_source.dart';
import 'package:space_farm/src/settings/model/app_settings.dart';

abstract interface class IAppSettingsRepository {
  Future<void> setAppSettings(AppSettings appSettings);

  Future<AppSettings?> getAppSettings();
}

final class AppSettingsRepository implements IAppSettingsRepository {
  const AppSettingsRepository({required this.datasource});

  final IAppSettingsDataSource datasource;

  @override
  Future<AppSettings?> getAppSettings() => datasource.getAppSettings();

  @override
  Future<void> setAppSettings(AppSettings appSettings) => datasource.setAppSettings(appSettings);
}
