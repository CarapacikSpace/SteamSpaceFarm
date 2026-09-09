import 'dart:io' show Process;

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';

@immutable
class const SteamGameProcess({required final GameRunnerConnection connection, required final LocalApp app}) {
  int get pid => connection.process.pid;

  Process get process => connection.process;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SteamGameProcess && connection.runId == other.connection.runId;

  @override
  int get hashCode => connection.runId.hashCode;
}
