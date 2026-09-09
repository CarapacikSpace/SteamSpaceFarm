import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ssf_flutter/src/storage/app_paths.dart';

class SteamSessionStore({Directory? directory}) {
  final Directory directory = directory ?? AppPaths.steamSession;

  File get _file => File(p.join(directory.path, 'session.dpapi'));

  Future<bool> exists() => _file.exists();

  Future<void> forget() async {
    if (_file.existsSync()) {
      await _file.delete();
    }
  }
}
