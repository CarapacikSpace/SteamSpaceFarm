import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';
import 'package:ssf_flutter/src/utils/serial_task_queue.dart';

abstract interface class IAppsRepository() {
  Future<List<LocalApp>> getAppsFromCache();

  Future<String?> getCatalogSteamId();

  Future<void> updateApp(LocalApp app);

  Future<void> updateApps(List<LocalApp> updatedApps);

  Future<void> importSteamLibrary(SteamLibrarySnapshot snapshot);

  Future<void> clearLibraryCache({bool forgetAccount = false});
}

class AppsRepository({final Directory? libraryDirectory}) implements IAppsRepository {
  final _mutations = SerialTaskQueue();

  @override
  Future<List<LocalApp>> getAppsFromCache() async {
    final Map<String, dynamic>? library = await _readLibrary();
    if (library == null) {
      return [];
    }
    return (library['apps'] as List<dynamic>)
        .map((dynamic app) => LocalApp.fromJson(app as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String?> getCatalogSteamId() async => (await _readLibrary())?['steamId'] as String?;

  Future<void> _saveApps(List<LocalApp> apps) async {
    final Map<String, dynamic>? library = await _readLibrary();
    await _saveLibrary({
      'schemaVersion': 1,
      'steamId': null,
      ...?library,
      'apps': apps.map((a) => a.toJson()).toList(),
    });
  }

  @override
  Future<void> clearLibraryCache({bool forgetAccount = false}) => _mutations.run(() async {
    final Map<String, dynamic>? previous = await _readLibrary();
    await _saveLibrary({
      'schemaVersion': 1,
      'steamId': forgetAccount ? null : previous?['steamId'],
      'apps': <dynamic>[],
    });
  });

  File get _libraryFile => File(p.join((libraryDirectory ?? AppPaths.library).path, 'catalog.json'));

  Future<Map<String, dynamic>?> _readLibrary() async {
    final File file = _libraryFile;
    return file.existsSync() ? jsonDecode(await file.readAsString()) as Map<String, dynamic> : null;
  }

  Future<void> _saveLibrary(Map<String, dynamic> library) async {
    final File file = _libraryFile;
    await file.parent.create(recursive: true);
    await _writeAtomically(file, const JsonEncoder.withIndent('  ').convert(library));
  }

  @override
  Future<void> importSteamLibrary(SteamLibrarySnapshot snapshot) => _mutations.run(() async {
    final Map<String, dynamic>? previous = await _readLibrary();

    final List<LocalApp> cached = previous?['steamId'] == snapshot.steamId ? await getAppsFromCache() : [];
    final List<LocalApp> apps = snapshot.merge(cached);
    await _saveLibrary({
      'schemaVersion': 1,
      'steamId': snapshot.steamId,
      'partial': snapshot.partial,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'apps': apps.map((a) => a.toJson()).toList(),
    });
  });

  @override
  Future<void> updateApp(LocalApp app) => _mutations.run(() async {
    final List<LocalApp> apps = await getAppsFromCache();
    final int index = apps.indexWhere((a) => a.appId == app.appId);
    if (index == -1) {
      return;
    }
    final List<LocalApp> newApps = List.of(apps);
    newApps[index] = app;
    await _saveApps(newApps);
  });

  @override
  Future<void> updateApps(List<LocalApp> updatedApps) => _mutations.run(() async {
    final List<LocalApp> apps = await getAppsFromCache();
    final Map<int, LocalApp> appMap = {for (final a in apps) a.appId: a};

    for (final app in updatedApps) {
      appMap[app.appId] = app;
    }

    final List<LocalApp> newList = appMap.values.toList();
    await _saveApps(newList);
  });

  static Future<void> _writeAtomically(File target, String contents) async {
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(contents, flush: true);
    await temporary.rename(target.path);
  }
}
