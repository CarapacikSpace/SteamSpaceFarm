import 'package:ssf_flutter/src/feature/settings/data/settings_data_source.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';

abstract interface class IAppSettingsRepository() {
  Future<void> setAppSettings(AppSettings appSettings);

  Future<AppSettings?> getAppSettings();
}

final class const AppSettingsRepository({required final IAppSettingsDataSource datasource})
    implements IAppSettingsRepository {
  @override
  Future<AppSettings?> getAppSettings() => datasource.getAppSettings();

  @override
  Future<void> setAppSettings(AppSettings appSettings) => datasource.setAppSettings(appSettings);
}
