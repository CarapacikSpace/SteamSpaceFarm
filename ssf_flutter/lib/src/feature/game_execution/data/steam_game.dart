import 'dart:async';
import 'dart:io' show File, Platform, Process;
import 'dart:math';

import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/runner_process.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_presence.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steamkit_session.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/windows_runner_job.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/process_action_queue.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/steam_game_process.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';

class SteamGameService({required final SteamProcessManager processManager}) {
  bool experimentalSteamKit = false;
  bool invisibleWhilePlaying = false;
  final _presence = GamePresenceController();
  final _presenceFailures = StreamController<void>.broadcast();
  Stream<void> get presenceRestorationFailures => _presenceFailures.stream;
  SteamKitSession? _steamKitSession;
  final _launchActions = ProcessActionQueue();
  final _stopActions = ProcessActionQueue();
  final _launches = <Future<void>>{};
  Future<void>? _stopping;

  bool get hasProcesses => _owned.isNotEmpty || _launches.isNotEmpty || _presence.isActive;

  final _owned = <String, SteamGameProcess>{};
  final _random = Random.secure();
  int _generation = 0;

  Future<SteamGameProcess> launchApp(LocalApp app, {required String expectedSteamId, Duration? maximumRunTime}) async {
    if (!processManager.acceptingGameStarts || _stopping != null) {
      throw const GameRunnerException('launch_cancelled');
    }
    final int generation = _generation;
    SteamGameProcess? launched;
    late final Future<void> operation;
    operation = _launchActions
        .run(() async {
          if (generation != _generation || !processManager.acceptingGameStarts) {
            throw const GameRunnerException('launch_cancelled');
          }
          launched = await _launchApp(app, expectedSteamId: expectedSteamId, maximumRunTime: maximumRunTime);
        }, shouldRun: () => generation == _generation && processManager.acceptingGameStarts)
        .whenComplete(() => _launches.remove(operation));
    _launches.add(operation);
    await operation;
    if (launched == null) {
      throw const GameRunnerException('launch_cancelled');
    }
    return launched!;
  }

  Future<SteamGameProcess> _launchApp(LocalApp app, {required String expectedSteamId, Duration? maximumRunTime}) async {
    if (app.appId <= 0 || int.tryParse(expectedSteamId) == null || int.parse(expectedSteamId) <= 0) {
      throw const GameRunnerException('invalid_identity');
    }
    final Future<void> Function()? release = invisibleWhilePlaying
        ? await _presence.acquire(expectedSteamId, localClientRequired: !experimentalSteamKit)
        : null;
    try {
      if (!processManager.acceptingGameStarts || _stopping != null) {
        throw const GameRunnerException('launch_cancelled');
      }
      final SteamGameProcess game = await _startApp(
        app,
        expectedSteamId: expectedSteamId,
        maximumRunTime: maximumRunTime,
      );
      if (release != null) {
        unawaited(
          game.connection.exitCode
              .then((_) => release())
              .catchError((Object error) {
                AppLogger.info('Steam status restoration failed: $error', name: 'SteamGame');
                _presenceFailures.add(null);
              })
              .whenComplete(processManager.updateActivity),
        );
      }
      return game;
    } on Object {
      try {
        await release?.call();
      } on Object catch (error) {
        AppLogger.info('Steam status restoration failed: $error', name: 'SteamGame');
        _presenceFailures.add(null);
      }
      rethrow;
    }
  }

  Future<SteamGameProcess> _startApp(LocalApp app, {required String expectedSteamId, Duration? maximumRunTime}) async {
    final int generation = _generation;
    if (experimentalSteamKit) {
      SteamKitSession? session = _steamKitSession;
      if (session == null || session.closed) {
        if (session != null) {
          await session.shutdown();
        }
        if (generation != _generation) {
          throw const GameRunnerException('launch_cancelled');
        }
        session = _steamKitSession = SteamKitSession(steamId: expectedSteamId, invisible: invisibleWhilePlaying);
      }
      if (session.steamId != expectedSteamId) {
        throw const GameRunnerException('account_mismatch');
      }
      final runId = 'kit-${List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
      final SteamKitGameConnection connection = await session.launch(app.appId, runId, maximumRunTime);
      final launched = SteamGameProcess(app: app, connection: connection);
      _owned[runId] = launched;
      unawaited(connection.exitCode.then((_) => _owned.remove(runId)));
      if (generation != _generation || connection.exited) {
        await connection.stop(force: true);
        throw const GameRunnerException('launch_cancelled');
      }
      return launched;
    }
    final File file = AppPaths.executable('ssf_game');

    if (!await file.exists()) {
      throw const GameRunnerException('runner_not_found');
    }
    final String runId = List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    final arguments = <String>[
      app.appId.toString(),
      '--managed',
      '--expected-steam-id',
      expectedSteamId,
      '--run-id',
      runId,
      if (Platform.isWindows) ...['--job-name', 'Local\\ssf_game_$runId'],
      if (maximumRunTime != null) ...[
        '--run-seconds',
        (maximumRunTime.inMilliseconds / Duration.millisecondsPerSecond).ceil().toString(),
      ],
    ];
    final WindowsRunnerJob? job = Platform.isWindows ? WindowsRunnerJob('Local\\ssf_game_$runId') : null;
    final Process process;
    try {
      process = await RunnerProcess.start(file.path, arguments, workingDirectory: AppPaths.data.path);
    } on Object {
      job?.close();
      rethrow;
    }
    final connection = GameRunnerConnection(
      process: process,
      appId: app.appId,
      expectedSteamId: expectedSteamId,
      runId: runId,
      onDiagnostic: (message) => AppLogger.info(message, name: 'SteamGame'),
    );
    final launched = SteamGameProcess(app: app, connection: connection);
    _owned[runId] = launched;
    unawaited(
      connection.exitCode.then((_) {
        job?.close();
        _owned.remove(runId);
      }),
    );
    try {
      if (generation != _generation) {
        throw const GameRunnerException('launch_cancelled');
      }
      await connection.waitUntilReady();
      if (generation != _generation || connection.exited) {
        throw const GameRunnerException('launch_cancelled');
      }
      AppLogger.info('Started AppID ${app.appId}', name: 'Game');
      return launched;
    } on Object {
      await _stopConnection(launched, force: true);
      rethrow;
    }
  }

  Future<void> killProcessById(SteamGameProcess process) async {
    await _stopConnection(process);
    if (!process.connection.exited) {
      throw const GameRunnerException('stop_not_confirmed');
    }
    AppLogger.info('Stopped AppID ${process.app.appId}', name: 'Game');
  }

  Future<void> _stopConnection(SteamGameProcess process, {bool force = false}) => force
      ? process.connection.stop(force: true)
      : _stopActions.run(() => process.connection.stop(), shouldRun: () => !process.connection.exited);

  Future<void> updateDeadline(SteamGameProcess process, Duration? remaining) =>
      remaining != null && remaining <= Duration.zero
      ? killProcessById(process)
      : process.connection.updateDeadline(remaining);

  Future<void> killAllProcesses() => _stopping ??= _killAllProcesses().whenComplete(() => _stopping = null);

  Future<void> _killAllProcesses() async {
    _generation++;
    _launchActions.cancelPending();
    _stopActions.cancelPending();
    await Future.wait([
      if (_steamKitSession != null) _steamKitSession!.shutdown(),
      ..._owned.values.toList().map((process) => process.connection.stop(force: true)),
      ..._launches.toList().map((launch) => launch.catchError((Object _) {})),
    ]);
    await _presence.settled;
    if (hasProcesses) {
      throw const GameRunnerException('stop_not_confirmed');
    }
  }
}
