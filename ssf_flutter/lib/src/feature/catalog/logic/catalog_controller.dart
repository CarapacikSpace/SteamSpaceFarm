import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';

class CatalogController({required final IAppsRepository appsRepository, final Future<bool> Function()? sessionExists})
    extends ChangeNotifier {
  List<LocalApp> _apps = const [];
  Object? _error;
  bool _isLoading = true;
  bool _isDisposed = false;
  bool _hasSession = false;

  bool get hasSession => _hasSession;

  List<LocalApp> get apps => _apps;

  Object? get error => _error;

  bool get isLoading => _isLoading;

  LocalApp? appById(int appId) {
    for (final LocalApp app in _apps) {
      if (app.appId == appId) {
        return app;
      }
    }
    return null;
  }

  Future<void> loadCache() async {
    _isLoading = true;
    _error = null;
    _notifyIfMounted();

    try {
      _apps = await appsRepository.getAppsFromCache();
      _apps.sortByPlaytimeTypeName();
      try {
        _hasSession = await sessionExists?.call() ?? false;
      } on Object catch (error, stack) {
        _hasSession = false;
        AppLogger.error('Session status unavailable', error, stack, name: 'Catalog');
      }
    } on Object catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      _notifyIfMounted();
    }
  }

  Future<void> updateApp(LocalApp updatedApp) async {
    await appsRepository.updateApp(updatedApp);
    final int index = _apps.indexWhere((app) => app.appId == updatedApp.appId);
    if (index == -1) {
      return;
    }
    final List<LocalApp> updatedApps = List.of(_apps);
    updatedApps[index] = updatedApp;
    _apps = updatedApps;
    _notifyIfMounted();
  }

  Future<void> updateApps(List<LocalApp> updatedApps) async {
    if (updatedApps.isEmpty) {
      return;
    }
    await appsRepository.updateApps(updatedApps);
    final Map<int, LocalApp> replacements = {for (final app in updatedApps) app.appId: app};
    _apps = [for (final app in _apps) replacements[app.appId] ?? app];
    _notifyIfMounted();
  }

  void replaceAppInMemory(LocalApp updatedApp) {
    final int index = _apps.indexWhere((app) => app.appId == updatedApp.appId);
    if (index == -1) {
      return;
    }
    final List<LocalApp> updatedApps = List.of(_apps);
    updatedApps[index] = updatedApp;
    _apps = updatedApps;
    _notifyIfMounted();
  }

  void _notifyIfMounted() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
