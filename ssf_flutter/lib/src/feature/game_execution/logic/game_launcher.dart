import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/bulk_actions.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/steam_game_process.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';
import 'package:ssf_flutter/src/utils/optional.dart';

enum BatchLaunchMode() {
  marked,
  favorites,
}

const int minimumConcurrentGames = 1;
const int maximumConcurrentGames = 30;
const int defaultConcurrentGames = 30;

class GameLauncher({
  required final IAppsRepository appsRepository,
  required final SteamGameService steamGame,
  required final ValueChanged<LocalApp> onUpdateAppList,
  required final VoidCallback onStateChanged,
  required final ValueChanged<String> onUserError,
  final LocalApp? Function(int appId)? latestAppById,
  var int _maxRunningGames = defaultConcurrentGames,
}) {
  this {
    _registration = steamGame.processManager.register(
      isActive: () =>
          occupiedSlots > 0 ||
          _appOperations.isNotEmpty ||
          isBatchActive ||
          isSequentialActive ||
          steamGame.hasProcesses,
      stop: stopAll,
    );
    RangeError.checkValueInInterval(
      _maxRunningGames,
      minimumConcurrentGames,
      maximumConcurrentGames,
      'maxRunningGames',
    );
  }

  final launchedGames = <SteamGameProcess>[];
  late final SteamProcessRegistration _registration;
  final batchLaunchedAppIds = <int>{};
  final batchQueue = Queue<LocalApp>();
  final gameStartTimes = <int, DateTime>{};
  final gameTimers = <int, Timer>{};
  final sequentialQueue = Queue<LocalApp>();
  final _appOperations = <int, Future<void>>{};
  final _startingAppIds = <int>{};
  final _cancelledStarts = <int>{};
  final _runnerTargets = <int, int?>{};
  int _launchGeneration = 0;
  bool _stoppingAll = false;
  Future<void>? _stopAllOperation;

  bool _isFillingBatch = false;
  bool _sequentialActive = false;
  bool _batchPaused = false;
  bool _sequentialPaused = false;
  bool _disposed = false;
  int? _sequentialAppId;
  Timer? _sequentialTimer;
  Timer? _sequentialDelayTimer;
  Duration _sequentialRunDuration = const Duration(seconds: 60);
  Duration _sequentialLowPlaytimeRunDuration = const Duration(seconds: 60);
  Duration _sequentialLaunchDelay = const Duration(seconds: 10);
  BatchLaunchMode? _batchMode;

  bool get isSequentialActive => _sequentialActive;

  bool get isBatchActive => _batchMode != null;

  bool get isQueuePaused => (_batchMode != null && _batchPaused) || (_sequentialActive && _sequentialPaused);

  BatchLaunchMode? get batchMode => _batchMode;

  int get sequentialRemaining => sequentialQueue.length + (_sequentialAppId == null ? 0 : 1);

  int get batchRemaining => batchQueue.length + batchLaunchedAppIds.length;

  int get queuedCount => _sequentialActive ? sequentialQueue.length : batchQueue.length;

  int? get sequentialAppId => _sequentialAppId;

  int get maxRunningGames => _maxRunningGames;

  int get occupiedSlots => launchedGames.length + _startingAppIds.length;

  void updateMaxRunningGames(int value) {
    RangeError.checkValueInInterval(value, minimumConcurrentGames, maximumConcurrentGames, 'value');
    if (_maxRunningGames == value) {
      return;
    }
    _maxRunningGames = value;
    if (_batchMode != null && !_disposed) {
      unawaited(_fillBatchSlots());
    }
  }

  void setQueuePaused({required bool paused}) {
    if (_batchMode != null) {
      if (_batchPaused == paused) {
        return;
      }
      _batchPaused = paused;
      _notifyStateChanged();
      if (!paused && !_disposed) {
        unawaited(_fillBatchSlots());
      }
      return;
    }
    if (_sequentialActive) {
      if (_sequentialPaused == paused) {
        return;
      }
      _sequentialPaused = paused;
      if (paused) {
        _sequentialDelayTimer?.cancel();
        _sequentialDelayTimer = null;
      }
      _notifyStateChanged();
      if (!paused && _sequentialAppId == null && !_disposed) {
        unawaited(_scheduleNextSequential());
      }
    }
  }

  Future<void> toggleGame(LocalApp app) {
    final int generation = _launchGeneration;
    return _runSerialized(app.appId, () async {
      if (generation != _launchGeneration || _stoppingAll || _disposed || !steamGame.processManager.acceptingStarts) {
        return;
      }
      await _toggleGame(app);
    });
  }

  Future<void> stopGame(int appId) {
    _cancelledStarts.add(appId);
    return _runSerialized(appId, () async {
      final SteamGameProcess? process = launchedGames.firstWhereOrNull((candidate) => candidate.app.appId == appId);
      if (process != null) {
        await _stopRunningGame(process, latestApp: latestAppById?.call(appId) ?? process.app, killProcess: true);
      }
      _cancelledStarts.remove(appId);
    });
  }

  Future<void> launchBatch(Iterable<LocalApp> apps, {required BatchLaunchMode mode}) async {
    if (_sequentialActive ||
        _batchMode != null ||
        _stoppingAll ||
        _disposed ||
        !steamGame.processManager.acceptingStarts) {
      return;
    }
    _batchMode = mode;
    _batchPaused = false;
    batchQueue
      ..clear()
      ..addAll(
        {for (final app in apps) app.appId: app}.values
            .where((app) => !launchedGames.any((process) => process.app.appId == app.appId)),
      );
    if (batchQueue.isEmpty) {
      _batchMode = null;
      _notifyStateChanged();
      return;
    }
    _notifyStateChanged();
    await _fillBatchSlots();
  }

  Future<void> stopBatch() async {
    _batchMode = null;
    _batchPaused = false;
    batchQueue.clear();
    for (final int appId in batchLaunchedAppIds.toList()) {
      await stopGame(appId);
    }
    _notifyStateChanged();
  }

  Future<void> startSequential(
    Iterable<LocalApp> apps, {
    required Duration runDuration,
    required Duration lowPlaytimeRunDuration,
    required Duration launchDelay,
  }) async {
    if (runDuration <= Duration.zero) {
      throw ArgumentError.value(runDuration, 'runDuration', 'Must be greater than zero.');
    }
    if (lowPlaytimeRunDuration <= Duration.zero) {
      throw ArgumentError.value(lowPlaytimeRunDuration, 'lowPlaytimeRunDuration', 'Must be greater than zero.');
    }
    if (launchDelay < Duration.zero) {
      throw ArgumentError.value(launchDelay, 'launchDelay', 'Must not be negative.');
    }
    if (_sequentialActive || _disposed || !steamGame.processManager.acceptingStarts) {
      return;
    }
    if (occupiedSlots > 0 || _batchMode != null || _stoppingAll) {
      onUserError(GeneratedLocalizations.current.sequentialQueueRequiresStoppedGames);
      return;
    }

    final uniqueApps = <int, LocalApp>{for (final app in apps) app.appId: app};
    if (uniqueApps.isEmpty) {
      return;
    }

    batchQueue.clear();
    _sequentialRunDuration = runDuration;
    _sequentialLowPlaytimeRunDuration = lowPlaytimeRunDuration;
    _sequentialLaunchDelay = launchDelay;
    sequentialQueue
      ..clear()
      ..addAll(uniqueApps.values);
    _sequentialActive = true;
    _sequentialPaused = false;
    _notifyStateChanged();
    await _launchNextSequential();
  }

  Future<void> stopSequential() async {
    if (!_sequentialActive && _sequentialAppId == null) {
      return;
    }

    _sequentialActive = false;
    _sequentialPaused = false;
    sequentialQueue.clear();
    _sequentialTimer?.cancel();
    _sequentialTimer = null;
    _sequentialDelayTimer?.cancel();
    _sequentialDelayTimer = null;
    final int? appId = _sequentialAppId;
    _sequentialAppId = null;
    _notifyStateChanged();

    if (appId != null) {
      await stopGame(appId);
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(
      stopAll()
          .catchError((Object error, StackTrace stack) {
            AppLogger.error('Runner cleanup failed', error, stack);
          })
          .whenComplete(_registration.release),
    );
    for (final Timer timer in gameTimers.values) {
      timer.cancel();
    }
  }

  Future<void> stopAll() => _stopAllOperation ??= _stopAll().whenComplete(() => _stopAllOperation = null);

  Future<void> _stopAll() async {
    _stoppingAll = true;
    _launchGeneration++;
    _batchMode = null;
    _sequentialActive = false;
    _batchPaused = false;
    _sequentialPaused = false;
    _sequentialAppId = null;
    batchQueue.clear();
    sequentialQueue.clear();
    _sequentialTimer?.cancel();
    _sequentialDelayTimer?.cancel();
    try {
      await steamGame.killAllProcesses();
      await Future.wait(_appOperations.values.toList());

      for (final SteamGameProcess process in launchedGames.toList()) {
        await _runSerialized(process.app.appId, () => _handleProcessExit(process));
      }
    } finally {
      _stoppingAll = false;
      _notifyStateChanged();
    }
  }

  Future<void> _toggleGame(LocalApp app) async {
    final int appId = app.appId;
    final SteamGameProcess? launchedProcess = launchedGames.firstWhereOrNull((p) => p.app.appId == appId);

    if (launchedProcess != null) {
      await _stopRunningGame(launchedProcess, latestApp: app, killProcess: true);
      return;
    }

    await _launchGame(app);
  }

  Future<void> _launchGame(LocalApp app) async {
    final int appId = app.appId;
    if (launchedGames.any((process) => process.app.appId == appId) || _startingAppIds.contains(appId)) {
      return;
    }
    if (_sequentialActive && _sequentialAppId != appId) {
      return;
    }
    if (_disposed ||
        _stoppingAll ||
        !steamGame.processManager.acceptingStarts ||
        _cancelledStarts.contains(appId) ||
        occupiedSlots >= maxRunningGames) {
      batchLaunchedAppIds.remove(appId);
      return;
    }

    final int generation = _launchGeneration;
    _startingAppIds.add(appId);
    _notifyStateChanged();
    try {
      final Duration? maximumRunTime = _maximumRunTimeFor(app);
      final String? expectedSteamId = await appsRepository.getCatalogSteamId();
      if (expectedSteamId == null || expectedSteamId.isEmpty) {
        throw const GameRunnerException('account_required');
      }
      if (_disposed || generation != _launchGeneration || _cancelledStarts.contains(appId)) {
        return;
      }
      final SteamGameProcess launched = await steamGame.launchApp(
        app,
        expectedSteamId: expectedSteamId,
        maximumRunTime: maximumRunTime,
      );
      if (_disposed || generation != _launchGeneration || _cancelledStarts.contains(appId)) {
        await steamGame.killProcessById(launched);
        return;
      }
      launchedGames.add(launched);
      _runnerTargets[appId] = app.stopAtMinutes;
      gameStartTimes[appId] = DateTime.now();
      onUpdateAppList.call(app);
      _notifyStateChanged();
      unawaited(launched.connection.exitCode.then((_) => _runSerialized(appId, () => _handleProcessExit(launched))));

      gameTimers[appId] = Timer.periodic(const Duration(seconds: 10), (_) {
        unawaited(_runSerialized(appId, () => _checkTarget(launched)));
      });
    } on Object catch (error) {
      batchLaunchedAppIds.remove(appId);
      if (!_disposed && !_cancelledStarts.contains(appId) && generation == _launchGeneration) {
        final String detail = switch (error) {
          GameRunnerException(code: 'job_setup_failed') => GeneratedLocalizations.current.runnerCleanupFailed,
          GameRunnerException(code: 'account_mismatch' || 'identity_mismatch' || 'catalog_account_mismatch') =>
            GeneratedLocalizations.current.runnerAccountMismatch,
          GameRunnerException(code: 'account_required' || 'invalid_identity') =>
            GeneratedLocalizations.current.runnerLibraryRequired,
          GameRunnerException(
            code: 'runner_not_found' ||
                'dll_missing' ||
                'dll_architecture' ||
                'dll_entrypoint' ||
                'incompatible_protocol' ||
                'exited_before_ready',
          ) =>
            GeneratedLocalizations.current.runnerUpdateRequired,
          _ => GeneratedLocalizations.current.runnerLaunchUnconfirmed,
        };
        onUserError(GeneratedLocalizations.current.gameLaunchFailed(app.name, appId, detail));
      }
    } finally {
      _startingAppIds.remove(appId);
      if (!launchedGames.any((process) => process.app.appId == appId)) {
        batchLaunchedAppIds.remove(appId);
      }
      _notifyStateChanged();
    }
  }

  Future<void> _checkTarget(SteamGameProcess process) async {
    final SteamGameProcess? current = launchedGames.firstWhereOrNull((candidate) => candidate.pid == process.pid);
    if (current == null) {
      return;
    }

    final LocalApp latestApp = latestAppById?.call(current.app.appId) ?? current.app;
    if (!_sequentialActive && _runnerTargets[latestApp.appId] != latestApp.stopAtMinutes) {
      final int? target = latestApp.stopAtMinutes;
      final int total = max(
        latestApp.playtimeMinutes ?? 0,
        (current.app.playtimeMinutes ?? 0) + current.connection.elapsed.elapsed.inMinutes,
      );
      try {
        await steamGame.updateDeadline(current, target == null ? null : Duration(minutes: target - total));
        _runnerTargets[latestApp.appId] = target;
      } on Object {
        onUserError(GeneratedLocalizations.current.gameDeadlineUpdateFailed(latestApp.name));
      }
    }
    if (latestApp.stopAtMinutes == null) {
      return;
    }

    final int sessionMinutes = current.connection.elapsed.elapsed.inMinutes;
    final int totalMinutes = max(latestApp.playtimeMinutes ?? 0, (current.app.playtimeMinutes ?? 0) + sessionMinutes);
    if (totalMinutes >= latestApp.stopAtMinutes!) {
      await _stopRunningGame(current, latestApp: latestApp, killProcess: true);
    }
  }

  Duration? _maximumRunTimeFor(LocalApp app) {
    if (_sequentialActive && _sequentialAppId == app.appId) {
      return sequentialRunDurationFor(
        app: app,
        configuredDuration: _sequentialRunDuration,
        lowPlaytimeDuration: _sequentialLowPlaytimeRunDuration,
      );
    }

    final int? targetMinutes = app.stopAtMinutes;
    if (targetMinutes == null) {
      return null;
    }
    final int remainingMinutes = targetMinutes - (app.playtimeMinutes ?? 0);
    return Duration(minutes: max(1, remainingMinutes));
  }

  Future<void> _handleProcessExit(SteamGameProcess process) async {
    final SteamGameProcess? current = launchedGames.firstWhereOrNull((candidate) => candidate.pid == process.pid);
    if (current == null) {
      return;
    }
    await _stopRunningGame(
      current,
      latestApp: latestAppById?.call(current.app.appId) ?? current.app,
      killProcess: false,
    );
  }

  Future<void> _stopRunningGame(
    SteamGameProcess process, {
    required LocalApp latestApp,
    required bool killProcess,
  }) async {
    final int appId = process.app.appId;
    final bool tracked = launchedGames.any((candidate) => candidate.pid == process.pid);
    if (!tracked) {
      return;
    }

    if (killProcess) {
      try {
        await steamGame.killProcessById(process);
      } on Object {
        onUserError(GeneratedLocalizations.current.gameStopFailed(latestApp.name, appId));
        return;
      }
    }

    batchLaunchedAppIds.remove(appId);
    final wasSequentialGame = _sequentialAppId == appId;
    if (wasSequentialGame) {
      _sequentialTimer?.cancel();
      _sequentialTimer = null;
      _sequentialAppId = null;
    }
    launchedGames.removeWhere((candidate) => candidate.pid == process.pid);
    gameTimers.remove(appId)?.cancel();
    final DateTime? startedAt = gameStartTimes.remove(appId);
    _runnerTargets.remove(appId);

    if (startedAt != null) {
      final int playedMinutes = process.connection.elapsed.elapsed.inMinutes;
      final int totalMinutes = max(latestApp.playtimeMinutes ?? 0, (process.app.playtimeMinutes ?? 0) + playedMinutes);
      final int? targetMinutes = latestApp.stopAtMinutes;
      final LocalApp updatedApp = latestApp.copyWith(
        playtimeMinutes: totalMinutes,
        stopAtMinutes: Optional.of(targetMinutes != null && totalMinutes >= targetMinutes ? null : targetMinutes),
      );
      try {
        await appsRepository.updateApp(updatedApp);
        if (!_disposed) {
          onUpdateAppList.call(updatedApp);
        }
      } on Object {
        if (!_disposed) {
          onUserError(GeneratedLocalizations.current.gamePlaytimeSaveFailed(latestApp.name, appId));
        }
      }
    }

    if (_batchMode != null && !_disposed) {
      unawaited(_fillBatchSlots());
    }
    if (wasSequentialGame && _sequentialActive && !_disposed) {
      unawaited(_scheduleNextSequential());
    }
    _notifyStateChanged();
  }

  Future<void> _fillBatchSlots() async {
    if (_isFillingBatch || _disposed || _stoppingAll || _batchMode == null || _sequentialActive || _batchPaused) {
      return;
    }
    _isFillingBatch = true;
    try {
      while (!_disposed &&
          !_stoppingAll &&
          _batchMode != null &&
          !_batchPaused &&
          occupiedSlots < maxRunningGames &&
          batchQueue.isNotEmpty) {
        final LocalApp next = batchQueue.removeFirst();
        if (launchedGames.any((process) => process.app.appId == next.appId)) {
          continue;
        }

        batchLaunchedAppIds.add(next.appId);
        final int generation = _launchGeneration;
        await _runSerialized(next.appId, () async {
          if (generation == _launchGeneration && _batchMode != null) {
            await _launchGame(next);
          }
        });
        if (!launchedGames.any((process) => process.app.appId == next.appId)) {
          batchLaunchedAppIds.remove(next.appId);
        }
      }
    } finally {
      _isFillingBatch = false;
      if (batchQueue.isEmpty && batchLaunchedAppIds.isEmpty) {
        _batchMode = null;
        _batchPaused = false;
      }
      _notifyStateChanged();
    }
  }

  Future<void> _launchNextSequential() async {
    if (!_sequentialActive || _disposed || _sequentialPaused || _sequentialAppId != null) {
      return;
    }

    while (!_disposed && _sequentialActive && !_stoppingAll && sequentialQueue.isNotEmpty) {
      final LocalApp next = sequentialQueue.removeFirst();
      _sequentialAppId = next.appId;
      final int generation = _launchGeneration;
      await _runSerialized(next.appId, () async {
        if (generation == _launchGeneration && _sequentialActive && _sequentialAppId == next.appId) {
          await _launchGame(next);
        }
      });
      if (!_sequentialActive || _disposed || _stoppingAll) {
        return;
      }
      final bool launched = launchedGames.any((process) => process.app.appId == next.appId);
      if (!launched) {
        _sequentialAppId = null;
        if (_sequentialLaunchDelay > Duration.zero) {
          await _scheduleNextSequential();
          _notifyStateChanged();
          return;
        }
        continue;
      }

      final Duration runDuration = sequentialRunDurationFor(
        app: next,
        configuredDuration: _sequentialRunDuration,
        lowPlaytimeDuration: _sequentialLowPlaytimeRunDuration,
      );
      _sequentialTimer = Timer(runDuration, () {
        unawaited(_finishSequentialGame(next.appId));
      });
      _notifyStateChanged();
      return;
    }

    _sequentialActive = false;
    _sequentialPaused = false;
    _notifyStateChanged();
  }

  Future<void> _scheduleNextSequential() async {
    if (!_sequentialActive ||
        _disposed ||
        _sequentialPaused ||
        _sequentialAppId != null ||
        _sequentialDelayTimer != null) {
      return;
    }
    if (sequentialQueue.isEmpty) {
      _sequentialActive = false;
      _sequentialPaused = false;
      _notifyStateChanged();
      return;
    }
    if (_sequentialLaunchDelay <= Duration.zero) {
      await _launchNextSequential();
      return;
    }

    _sequentialDelayTimer = Timer(_sequentialLaunchDelay, () {
      _sequentialDelayTimer = null;
      unawaited(_launchNextSequential());
    });
    _notifyStateChanged();
  }

  Future<void> _finishSequentialGame(int appId) async {
    if (!_sequentialActive || _sequentialAppId != appId) {
      return;
    }
    final SteamGameProcess? process = launchedGames.firstWhereOrNull((candidate) => candidate.app.appId == appId);
    if (process == null) {
      _sequentialAppId = null;
      await _scheduleNextSequential();
      return;
    }
    await stopGame(process.app.appId);
  }

  void _notifyStateChanged() {
    if (!_disposed) {
      onStateChanged.call();
    }
  }

  Future<void> _runSerialized(int appId, Future<void> Function() action) {
    final Future<void> previous = _appOperations[appId] ?? Future<void>.value();
    late final Future<void> current;
    current = previous
        .catchError((Object _) {})
        .then((_) async {
          await action();
        })
        .whenComplete(() {
          if (identical(_appOperations[appId], current)) {
            unawaited(_appOperations.remove(appId));
          }
        });
    _appOperations[appId] = current;
    return current;
  }
}
