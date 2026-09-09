import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';

enum LibraryCacheClearResult() {
  cleared,
  failed,
}

class LibraryCacheController({
  required final IAppsRepository repository,
  required final Future<void> Function() onLibraryUpdated,
}) extends ChangeNotifier {
  int? _appCount;
  bool _loading = false;
  bool _countFailed = false;
  bool _clearing = false;
  bool _disposed = false;
  int _revision = 0;

  int? get appCount => _appCount;

  bool get loading => _loading;

  bool get countFailed => _countFailed;

  bool get clearing => _clearing;

  Future<void> loadCount() async {
    if (_disposed || _clearing) {
      return;
    }
    final int revision = ++_revision;
    _loading = true;
    _countFailed = false;
    notifyListeners();
    try {
      final int count = (await repository.getAppsFromCache()).length;
      if (_disposed || revision != _revision) {
        return;
      }
      _appCount = count;
    } on Object {
      if (_disposed || revision != _revision) {
        return;
      }
      _countFailed = true;
    }
    _loading = false;
    notifyListeners();
  }

  Future<LibraryCacheClearResult?> clear() async {
    if (_disposed || _clearing) {
      return null;
    }
    _revision++;
    _clearing = true;
    notifyListeners();
    LibraryCacheClearResult result;
    try {
      await repository.clearLibraryCache();
      if (_disposed) {
        return null;
      }
      _appCount = 0;
      _countFailed = false;
      _loading = false;
      notifyListeners();
      await onLibraryUpdated();
      result = LibraryCacheClearResult.cleared;
    } on Object {
      _countFailed = _appCount == null;
      result = LibraryCacheClearResult.failed;
    }
    if (_disposed) {
      return null;
    }
    _loading = false;
    _clearing = false;
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    super.dispose();
  }
}
