import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract final class AppPaths() {
  static Directory? _support;

  static Future<void> initialize() async {
    _support ??= await getApplicationSupportDirectory();
    await data.create(recursive: true);
  }

  static Directory get data => _support ?? (throw StateError('Application paths are not initialized'));

  static Directory get library => Directory(p.join(data.path, 'library'));

  static Directory get steamSession => Directory(p.join(data.path, 'steam'));

  static Directory get nativeRuntime => Directory(p.join(data.path, 'native_runtime'));

  static Directory get executables => File(Platform.resolvedExecutable).parent;

  static File executable(String name) => File(p.join(executables.path, Platform.isWindows ? '$name.exe' : name));
}
