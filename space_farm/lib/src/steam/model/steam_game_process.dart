import 'dart:io' show Process;

import 'package:flutter/foundation.dart';
import 'package:space_farm/src/apps/model/local_app.dart';

@immutable
class SteamGameProcess {
  const SteamGameProcess({required this.pid, required this.process, required this.app});

  final int pid;
  final Process process;
  final LocalApp app;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SteamGameProcess && runtimeType == other.runtimeType && pid == other.pid && app == other.app;

  @override
  int get hashCode => Object.hash(pid, app);
}
