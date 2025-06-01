import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_farm/src/apps/model/load_apps_data.dart';
import 'package:space_farm/src/common/persisted_entry.dart';

abstract interface class ILoadAppsDataSource {
  Future<LoadAppsData?> getData();

  Future<void> setData(LoadAppsData data, {required bool saveLoginAndPassword});

  Future<void> remove();
}

final class LoadAppsDataSource implements ILoadAppsDataSource {
  LoadAppsDataSource({required this.sharedPreferences});

  final SharedPreferencesAsync sharedPreferences;

  late final _data = StringPreferencesEntry(sharedPreferences: sharedPreferences, key: 'loadApps.data');

  @override
  Future<LoadAppsData?> getData() => _data.read().then((v) {
    if (v == null) {
      return null;
    }
    return LoadAppsData.fromJson(json.decode(v) as Map<String, dynamic>);
  });

  @override
  Future<void> setData(LoadAppsData data, {required bool saveLoginAndPassword}) =>
      _data.set(json.encode(data.toJson(saveLoginAndPassword: saveLoginAndPassword)));

  @override
  Future<void> remove() async {
    await _data.remove();
  }
}
