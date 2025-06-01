import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:space_farm/src/apps/model/load_apps_data.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/utils/merge_app_lists.dart';
import 'package:space_farm/src/common/components/prefs_storage/load_apps/load_apps_data_source.dart';
import 'package:space_farm/src/common/components/prefs_storage/local_apps/local_apps_data_source.dart';
import 'package:space_farm/src/steam/data/steam_hours.dart';
import 'package:space_farm/src/steam/data/steam_kit.dart';
import 'package:space_farm/src/steam/model/steam_app_info.dart';
import 'package:space_farm/src/steam/model/steam_user.dart';

abstract interface class IAppsRepository {
  Future<String?> getApps$All(String login, String password, String apiKey);

  Future<void> getApps$Public(String apiKey, String steamId);

  Future<List<LocalApp>> getApps$FromCacheAndUpdate();

  Future<SteamUser?> loadSteamUserFromFile();

  Future<List<SteamAppInfo>> loadAppsFromFile();

  Future<LoadAppsData?> getLoadAppsData();

  Future<void> saveLoadAppsData(LoadAppsData data, {bool saveLoginAndPassword = true});

  Future<void> updateApp(LocalApp app);

  Future<void> updateApps(List<LocalApp> updatedApps);

  Future<void> killAllProcesses$SteamKit();
}

class AppsRepository implements IAppsRepository {
  AppsRepository({
    required ILoadAppsDataSource loadAppsDataSource,
    required ILocalAppsDataSource localAppsDataSource,
    required SteamKitService steamKitService,
    required SteamHoursService steamHoursService,
  }) : _loadAppsDataSource = loadAppsDataSource,
       _localAppsDataSource = localAppsDataSource,
       _steamKitService = steamKitService,
       _steamHoursService = steamHoursService;

  final ILoadAppsDataSource _loadAppsDataSource;
  final ILocalAppsDataSource _localAppsDataSource;
  final SteamKitService _steamKitService;
  final SteamHoursService _steamHoursService;

  List<SteamAppInfo> _apps = [];

  @override
  Future<String?> getApps$All(String login, String password, String apiKey) async {
    await _steamKitService.getApps(login, password);
    final user = await loadSteamUserFromFile();
    await loadAppsFromFile();
    if (user == null) {
      return null;
    }

    final steamId = user.steamId.toString();
    await getApps$Public(apiKey, steamId);

    return steamId;
  }

  @override
  Future<void> getApps$Public(String apiKey, String steamId) async {
    final ownedGames = await _steamHoursService.getOwnedGames(apiKey, steamId);
    final recentlyPlayedGames = await _steamHoursService.getRecentlyPlayedGames(apiKey, steamId);
    if (_apps.isEmpty) {
      await loadAppsFromFile();
    }
    final steamKitApps = _apps.toList(growable: false);

    List<LocalApp> cachedApps;
    try {
      cachedApps = await _localAppsDataSource.getData();
    } on Object {
      cachedApps = [];
    }

    final mergedApps = mergeAppsLists(
      steamKitApps: steamKitApps,
      ownedGames: ownedGames,
      recentlyPlayedGames: recentlyPlayedGames,
      cachedApps: cachedApps,
    );

    await _localAppsDataSource.setData(mergedApps);
  }

  @override
  Future<List<LocalApp>> getApps$FromCacheAndUpdate() async {
    final cachedApps = await _localAppsDataSource.getData();
    final data = await getLoadAppsData();

    if (data == null || !data.validateGames()) {
      return cachedApps;
    }

    try {
      await getApps$Public(data.apiKey, data.steamId);
      final updatedApps = await _localAppsDataSource.getData();
      return updatedApps;
    } on Object catch (e, st) {
      log('Failed to update hours: $e', stackTrace: st);
      return cachedApps;
    }
  }

  @override
  Future<SteamUser?> loadSteamUserFromFile() async {
    final file = File(p.join('cache', 'user.json'));
    if (!file.existsSync()) {
      return null;
    }
    final data = await file.readAsString();
    final user = SteamUser.fromJson(json.decode(data) as Map<String, dynamic>);

    return user;
  }

  @override
  Future<List<SteamAppInfo>> loadAppsFromFile() async {
    final file = File(p.join('cache', 'apps.json'));
    if (!file.existsSync()) {
      return [];
    }
    final data = await file.readAsString();
    final steamApps = SteamAppInfo.parseAppInfo(json.decode(data) as Map<String, dynamic>);
    _apps = steamApps;

    return steamApps;
  }

  @override
  Future<LoadAppsData?> getLoadAppsData() => _loadAppsDataSource.getData();

  @override
  Future<void> saveLoadAppsData(LoadAppsData data, {bool saveLoginAndPassword = true}) =>
      _loadAppsDataSource.setData(data, saveLoginAndPassword: saveLoginAndPassword);

  @override
  Future<void> updateApp(LocalApp app) async {
    final apps = await _localAppsDataSource.getData();
    final index = apps.indexWhere((a) => a.appId == app.appId);
    if (index == -1) {
      return;
    }
    final newApps = List.of(apps);
    newApps[index] = app;
    await _localAppsDataSource.setData(newApps);
  }

  @override
  Future<void> updateApps(List<LocalApp> updatedApps) async {
    final apps = await _localAppsDataSource.getData();
    final appMap = {for (final a in apps) a.appId: a};

    for (final app in updatedApps) {
      appMap[app.appId] = app;
    }

    final newList = appMap.values.toList();
    await _localAppsDataSource.setData(newList);
  }

  @override
  Future<void> killAllProcesses$SteamKit() => _steamKitService.killAllProcesses();
}
