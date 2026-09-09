import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/logic/catalog_controller.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_launcher.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/bulk_actions.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/steam_game_process.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

class GameExecutionController({
  required final IAppsRepository appsRepository,
  required final SteamGameService steamGameService,
  required final CatalogController catalogController,
  required final ValueChanged<String> onUserError,
}) extends ChangeNotifier {
  late final GameLauncher _launcher = GameLauncher(
    appsRepository: appsRepository,
    steamGame: steamGameService,
    onUpdateAppList: catalogController.replaceAppInMemory,
    onStateChanged: _notifyIfMounted,
    latestAppById: catalogController.appById,
    onUserError: onUserError,
  );
  final Set<int> _appOperations = <int>{};
  bool _groupOperationActive = false;
  bool _disposed = false;

  Set<int> get runningAppIds => _launcher.launchedGames.map((process) => process.app.appId).toSet();

  Set<int> get automaticRunningAppIds => <int>{
    ..._launcher.batchLaunchedAppIds,
    if (_launcher.sequentialAppId case final int appId) appId,
  }.intersection(runningAppIds);

  Set<int> get manualRunningAppIds => runningAppIds.difference(automaticRunningAppIds);

  int get runningCount => _launcher.launchedGames.length;

  int get automaticRunningCount => automaticRunningAppIds.length;

  int get manualRunningCount => manualRunningAppIds.length;

  int get concurrentLimit => _launcher.maxRunningGames;

  bool get isBatchActive => _launcher.isBatchActive;

  bool get isSequentialActive => _launcher.isSequentialActive;

  bool get isQueueActive => isBatchActive || isSequentialActive;

  bool get isQueuePaused => _launcher.isQueuePaused;

  bool get isBusy =>
      _groupOperationActive || _appOperations.isNotEmpty || !steamGameService.processManager.acceptingStarts;

  int get queuedCount => _launcher.queuedCount;

  int get queueRemaining => isSequentialActive ? _launcher.sequentialRemaining : _launcher.batchRemaining;

  BatchLaunchMode? get batchMode => _launcher.batchMode;

  LocalApp? get currentSequentialApp {
    final int? appId = _launcher.sequentialAppId;
    if (appId == null) {
      return null;
    }
    for (final SteamGameProcess process in _launcher.launchedGames) {
      if (process.app.appId == appId) {
        return process.app;
      }
    }
    return null;
  }

  bool isRunning(int appId) => runningAppIds.contains(appId);

  bool isAppBusy(int appId) => _appOperations.contains(appId);

  void updateConcurrentLimit(int value) {
    _launcher.updateMaxRunningGames(value);
    _notifyIfMounted();
  }

  Future<String?> toggleApp(LocalApp app) async {
    if (!_appOperations.add(app.appId)) {
      return null;
    }
    _notifyIfMounted();
    try {
      if (!isRunning(app.appId)) {
        if (isSequentialActive) {
          return GeneratedLocalizations.current.sequentialQueueBlocksManualLaunch;
        }
        if (_launcher.occupiedSlots >= concurrentLimit) {
          return GeneratedLocalizations.current.concurrentLimitReached(concurrentLimit);
        }
      }
      await _launcher.toggleGame(app);
      return null;
    } finally {
      _appOperations.remove(app.appId);
      _notifyIfMounted();
    }
  }

  Future<String?> startBulk(BulkLaunchRequest request, List<LocalApp> candidates) async {
    if (_groupOperationActive || isQueueActive) {
      return GeneratedLocalizations.current.activeQueueMustStop;
    }
    if (candidates.isEmpty) {
      return GeneratedLocalizations.current.selectionHasNoEligibleApps;
    }
    if (request.mode == BulkLaunchMode.allSequential && runningCount > 0) {
      return GeneratedLocalizations.current.sequentialQueueRequiresStoppedGames;
    }
    _groupOperationActive = true;
    _notifyIfMounted();
    try {
      switch (request.mode) {
        case BulkLaunchMode.marked:
          await _launcher.launchBatch(candidates, mode: BatchLaunchMode.marked);
        case BulkLaunchMode.favorites:
          await _launcher.launchBatch(candidates, mode: BatchLaunchMode.favorites);
        case BulkLaunchMode.allSequential:
          await _launcher.startSequential(
            candidates,
            runDuration: Duration(seconds: request.runSeconds),
            lowPlaytimeRunDuration: Duration(seconds: request.lowPlaytimeRunSeconds),
            launchDelay: Duration(seconds: request.delaySeconds),
          );
      }
      return null;
    } finally {
      _groupOperationActive = false;
      _notifyIfMounted();
    }
  }

  void toggleQueuePause() {
    if (!isQueueActive) {
      return;
    }
    _launcher.setQueuePaused(paused: !isQueuePaused);
  }

  Future<void> stopQueue() => _runGroupOperation(() async {
    if (isSequentialActive) {
      await _launcher.stopSequential();
    } else if (isBatchActive) {
      await _launcher.stopBatch();
    }
  });

  Future<void> stopManualApps() => _runGroupOperation(() async {
    for (final int appId in manualRunningAppIds.toList()) {
      final LocalApp? app = _runningApp(appId);
      if (app != null) {
        await _launcher.stopGame(app.appId);
      }
    }
  });

  Future<void> hardStop() async {
    final Future<void> stopping = steamGameService.processManager.stopAll();
    _notifyIfMounted();
    try {
      await stopping;
    } finally {
      _notifyIfMounted();
    }
  }

  LocalApp? _runningApp(int appId) {
    for (final SteamGameProcess process in _launcher.launchedGames) {
      if (process.app.appId == appId) {
        return process.app;
      }
    }
    return null;
  }

  Future<void> _runGroupOperation(Future<void> Function() operation) async {
    if (_groupOperationActive) {
      return;
    }
    _groupOperationActive = true;
    _notifyIfMounted();
    try {
      await operation();
    } finally {
      _groupOperationActive = false;
      _notifyIfMounted();
    }
  }

  void _notifyIfMounted() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _launcher.dispose();
    super.dispose();
  }
}
