import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_launcher.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/steam_game_process.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

import 'support/fake_process.dart';

const first = LocalApp(appId: 480, name: 'First', type: SteamAppType.game);
const second = LocalApp(appId: 570, name: 'Second', type: SteamAppType.game);
const accountId = '76561198000000001';

void main() {
  setUp(() => GeneratedLocalizations.delegate.load(const Locale('ru')));
  late FakeRepository repository;
  late FakeSteam service;
  late GameLauncher launcher;
  late List<String> errors;
  setUp(() {
    repository = FakeRepository();
    service = FakeSteam();
    errors = [];
    launcher = GameLauncher(
      appsRepository: repository,
      steamGame: service,
      onUpdateAppList: (_) {},
      onStateChanged: () {},
      onUserError: errors.add,
      maxRunningGames: 1,
    );
  });
  tearDown(() async {
    service
      ..failStop = false
      ..releaseStart();
    await launcher.stopAll();
    launcher.dispose();
  });

  test('a running helper failure reports the app once and saves elapsed time', () async {
    await launcher.toggleGame(first);
    (service.workers.single.process as FakeProcess).finish(6);
    await tick();
    expect(launcher.launchedGames, isEmpty);
    expect(repository.writes, hasLength(1));
    expect(errors, hasLength(1));
    expect(errors.single, contains(first.name));
    expect(errors.single, contains(first.appId.toString()));
  });

  for (final sequential in [false, true]) {
    test('unexpected exit pauses the ${sequential ? "sequential" : "batch"} queue until resume', () async {
      if (sequential) {
        await launcher.startSequential(
          [first, second],
          runDuration: const Duration(hours: 1),
          lowPlaytimeRunDuration: const Duration(hours: 1),
          launchDelay: Duration.zero,
        );
      } else {
        await launcher.launchBatch([first, second], mode: BatchLaunchMode.marked);
      }
      (service.workers.single.process as FakeProcess).finish(6);
      await tick();
      expect(launcher.isQueuePaused, isTrue);
      expect(launcher.queuedCount, 1);
      expect(service.starts, [first.appId]);
      expect(errors, hasLength(1));
      launcher.setQueuePaused(paused: false);
      await tick();
      expect(service.starts, [first.appId, second.appId]);
    });
  }

  test('normal completion and requested forced stops do not report interruptions', () async {
    await launcher.toggleGame(first);
    (service.workers.single.process as FakeProcess).finish(0);
    await tick();
    service.stopExitCode = 9;
    await launcher.toggleGame(second);
    await launcher.stopGame(second.appId);
    await launcher.toggleGame(first);
    await launcher.stopAll();
    await tick();
    expect(errors, isEmpty);
  });

  test('exhausted status restoration is shown to the user', () async {
    service.restorationFailures.add(null);
    await tick();
    expect(errors, hasLength(1));
    expect(errors.single, contains('status'));
    launcher.dispose();
    service.restorationFailures.add(null);
    await tick();
    expect(errors, hasLength(1));
  });

  test('pause during a failed automatic start retains the next game until resume', () async {
    final failing = FailingSecondSteam();
    final queue = GameLauncher(
      appsRepository: repository,
      steamGame: failing,
      onUpdateAppList: (_) {},
      onStateChanged: () {},
      onUserError: errors.add,
    );
    addTearDown(() async {
      await queue.stopAll();
      queue.dispose();
    });
    const third = LocalApp(appId: 730, name: 'Third', type: SteamAppType.game);
    await queue.startSequential(
      [first, second, third],
      runDuration: const Duration(hours: 1),
      lowPlaytimeRunDuration: const Duration(hours: 1),
      launchDelay: Duration.zero,
    );
    await queue.stopGame(first.appId);
    await failing.entered.future;
    queue.setQueuePaused(paused: true);
    failing.releaseFailure.complete();
    await tick();
    expect(queue.isQueuePaused, isTrue);
    expect(queue.isSequentialActive, isTrue);
    expect(queue.queuedCount, 1);
    expect(failing.starts, [480, 570]);
    queue.setQueuePaused(paused: false);
    await tick();
    expect(failing.starts, [480, 570, 730]);
    expect(queue.launchedGames.single.app.appId, 730);
  });

  test('pending ready reserves capacity before another launch', () async {
    service.startGate = Completer<void>();
    final Future<void> start = launcher.toggleGame(first);
    await tick();
    expect(launcher.occupiedSlots, 1);
    await launcher.toggleGame(second);
    expect(service.starts, [480]);
    service.releaseStart();
    await start;
    expect(launcher.launchedGames.single.app.appId, 480);
  });

  test('stop all cancels pending ready and queued toggles', () async {
    service.startGate = Completer<void>();
    final Future<void> start = launcher.toggleGame(first);
    final Future<void> queuedToggle = launcher.toggleGame(first);
    await tick();
    final Future<void> stopping = launcher.stopAll();
    service.releaseStart();
    await Future.wait([start, queuedToggle, stopping]).timeout(const Duration(seconds: 2));
    expect(service.starts, [480]);
    expect(launcher.occupiedSlots, 0);
    expect(service.workers.every((worker) => worker.connection.exited), isTrue);
    expect(repository.writes, isEmpty);
  });

  test('failed stop stays tracked; repeated stop never relaunches and writes once', () async {
    await launcher.toggleGame(first);
    service.failStop = true;
    await launcher.stopGame(first.appId);
    expect(launcher.launchedGames, hasLength(1));
    expect(repository.writes, isEmpty);
    expect(errors, isNotEmpty);
    service.failStop = false;
    await Future.wait([launcher.stopGame(first.appId), launcher.stopGame(first.appId)]);
    await tick();
    expect(service.starts, [480]);
    expect(launcher.launchedGames, isEmpty);
    expect(repository.writes, hasLength(1));
  });

  test('batch deduplicates AppID and finishes after confirmed exit', () async {
    await launcher.launchBatch([first, first], mode: BatchLaunchMode.marked);
    await launcher.stopGame(first.appId).timeout(const Duration(seconds: 2));
    await tick();
    expect(service.starts, [480]);
    expect(launcher.isBatchActive, isFalse);
    expect(launcher.occupiedSlots, 0);
  });

  test('missing catalog account blocks process creation', () async {
    repository.catalogId = null;
    await launcher.toggleGame(first);
    expect(service.starts, isEmpty);
    expect(errors, hasLength(1));
    expect(launcher.occupiedSlots, 0);
  });

  test('manager stop interrupts batch startup without launching remaining games', () async {
    service.startGate = Completer<void>();
    final Future<void> batch = launcher.launchBatch([first, second], mode: BatchLaunchMode.marked);
    await tick();
    final Future<void> stopped = service.processManager.stopAll();
    service.releaseStart();
    await Future.wait([batch, stopped]);
    expect(service.starts, [first.appId]);
    expect(launcher.isBatchActive, isFalse);
    expect(launcher.occupiedSlots, 0);
  });
}

class FakeRepository() implements IAppsRepository {
  String? catalogId = accountId;
  final writes = <LocalApp>[];

  @override
  Future<String?> getCatalogSteamId() async => catalogId;

  @override
  Future<void> updateApp(LocalApp app) async => writes.add(app);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSteam() extends SteamGameService {
  this : super(processManager: SteamProcessManager()) {
    addTearDown(_closeRestorationFailures);
  }

  @override
  bool get hasProcesses => workers.any((worker) => !worker.connection.exited);
  Completer<void>? startGate;
  bool failStop = false;
  int stopExitCode = 0;
  final restorationFailures = StreamController<void>.broadcast();
  Future<void> _closeRestorationFailures() => restorationFailures.close();
  @override
  Stream<void> get presenceRestorationFailures => restorationFailures.stream;
  final starts = <int>[];
  final workers = <SteamGameProcess>[];

  void releaseStart() {
    if (startGate case final gate? when !gate.isCompleted) {
      gate.complete();
    }
  }

  @override
  Future<SteamGameProcess> launchApp(LocalApp app, {required String expectedSteamId, Duration? maximumRunTime}) async {
    starts.add(app.appId);
    final process = FakeProcess(processId: app.appId);
    final connection = GameRunnerConnection(
      process: process,
      appId: app.appId,
      expectedSteamId: expectedSteamId,
      runId: 'run-${app.appId}',
    );
    final worker = SteamGameProcess(app: app, connection: connection);
    workers.add(worker);
    process.output.add(
      utf8.encode(
        '${jsonEncode({'v': 1, 'event': 'ready', 'runId': connection.runId, 'appId': app.appId, 'steamId': expectedSteamId})}\n',
      ),
    );
    await connection.waitUntilReady();
    await startGate?.future;
    return worker;
  }

  @override
  Future<void> killProcessById(SteamGameProcess process) async {
    if (failStop) {
      throw StateError('synthetic stop failure');
    }
    (process.process as FakeProcess).finish(stopExitCode);
    await process.connection.exitCode;
  }

  @override
  Future<void> killAllProcesses() async {
    for (final SteamGameProcess worker in workers) {
      await killProcessById(worker);
    }
  }
}

class FailingSecondSteam() extends FakeSteam {
  final entered = Completer<void>();
  final releaseFailure = Completer<void>();
  @override
  Future<SteamGameProcess> launchApp(LocalApp app, {required String expectedSteamId, Duration? maximumRunTime}) async {
    if (app.appId == second.appId) {
      starts.add(app.appId);
      entered.complete();
      await releaseFailure.future;
      throw StateError('synthetic startup failure');
    }
    return await super.launchApp(app, expectedSteamId: expectedSteamId, maximumRunTime: maximumRunTime);
  }
}
