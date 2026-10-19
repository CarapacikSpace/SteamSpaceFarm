import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_launcher.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/session_work_queue.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_drops.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_farming_mode.dart';
import 'package:ssf_flutter/src/utils/optional.dart';

import 'game_launcher_test.dart' show FakeRepository, FakeSteam, accountId, first, second;

void main() {
  late FakeRepository repository;
  late CardSteam steam;
  late GameLauncher launcher;
  late SessionWorkQueue work;
  late Map<int, LocalApp> apps;
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ssf-cards-test-');
    repository = FakeRepository();
    steam = CardSteam();
    apps = {first.appId: first, second.appId: second};
    launcher = GameLauncher(
      appsRepository: repository,
      steamGame: steam,
      latestAppById: (id) => apps[id],
      onUpdateAppList: (app) => apps[app.appId] = app,
      onStateChanged: () {},
      onUserError: (_) {},
    );
    work = SessionWorkQueue(
      launcher: launcher,
      service: steam,
      repository: repository,
      appById: launcher.currentApp,
      cacheFile: File('${directory.path}/cards.json'),
      groupDuration: const Duration(milliseconds: 30),
      soloDuration: const Duration(milliseconds: 20),
      settleDelay: const Duration(milliseconds: 5),
      clockTick: const Duration(milliseconds: 10),
      refreshInterval: const Duration(milliseconds: 40),
    );
    for (final LocalApp app in apps.values) {
      work.drops[app.appId] = CardDrops(appId: app.appId, name: app.name, remaining: 1, checkedAt: DateTime.now());
    }
  });
  tearDown(() async {
    await launcher.stopAll();
    work.dispose();
    launcher.dispose();
    await directory.delete(recursive: true);
  });

  test('cards suspend ordinary hours, then resume the same task and retain the status lease', () async {
    await launcher.toggleGame(first);
    work.mode = CardFarmingMode.sequential;
    await work.start([second]);
    await until(() => steam.starts.contains(second.appId));
    expect(launcher.launchedGames.map((game) => game.app.appId), [second.appId]);
    expect(launcher.suspendedCount, 1);
    expect(steam.holds, 1);
    steam.count = 0;
    work.setMode(CardFarmingMode.fast); // Ends the current phase and rechecks its drops.
    await until(() => !work.active);
    expect(steam.starts, [first.appId, second.appId, first.appId]);
    expect(steam.holds, 0);
  });

  test('unknown card count never completes a task or resumes ordinary hours', () async {
    await launcher.toggleGame(first);
    steam.count = null;
    await work.start([second]);
    await until(() => work.failed);
    expect(work.jobs.keys, contains(second.appId));
    expect(launcher.suspended, isTrue);
    expect(launcher.launchedGames, isEmpty);
    expect(steam.starts, [first.appId]);
  });

  test('stop all cancels a pending server query and cannot resume suspended hours', () async {
    await launcher.toggleGame(first);
    steam.gate = Completer<Map<String, dynamic>>();
    await work.start([second]);
    await until(() => work.loading);
    await launcher.stopAll().timeout(const Duration(seconds: 2));
    expect(launcher.launchedGames, isEmpty);
    expect(launcher.suspendedCount, 0);
    expect(work.active, isFalse);
    expect(steam.starts, [first.appId]);
    expect(steam.holds, 0);
  });

  test('fast mode uses a group followed by individual sessions and cancels all delayed starts', () async {
    await work.start([first, second]);
    await until(() => steam.starts.length >= 4);
    expect(steam.starts.take(4), [first.appId, second.appId, first.appId, second.appId]);
    await launcher.stopAll();
    final int count = steam.starts.length;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(steam.starts.length, count);
  });

  test('technical suspension preserves sequential work and remaining duration', () async {
    await launcher.startSequential(
      [first, second],
      runDuration: const Duration(minutes: 10),
      lowPlaytimeRunDuration: const Duration(minutes: 10),
      launchDelay: Duration.zero,
    );
    await launcher.suspendHours();
    expect(launcher.isSequentialActive, isTrue);
    expect(launcher.sequentialQueue.map((app) => app.appId), [first.appId, second.appId]);
    await launcher.resumeHours();
    expect(launcher.launchedGames.single.app.appId, first.appId);
    expect(launcher.sequentialQueue.single.appId, second.appId);
  });

  test('hourly refresh stops, reads time and resumes without adding the session twice', () async {
    apps[first.appId] = first.copyWith(playtimeMinutes: 20);
    await launcher.toggleGame(apps[first.appId]!);
    work.refreshHourly = true;
    await until(() => steam.timeQueries > 0 && !work.active);
    work.refreshHourly = false;
    expect(apps[first.appId]!.playtimeMinutes, 40);
    expect(apps[first.appId]!.confirmedPlaytimeMinutes, 40);
    expect(steam.starts, [first.appId, first.appId]);
    expect(steam.holds, 0);
    await launcher.applyConfirmedMinutes({first.appId: 30});
    expect(apps[first.appId]!.playtimeMinutes, 40);
    expect(apps[first.appId]!.confirmedPlaytimeMinutes, 30);
  });

  test('suspended batch resumes in its original order', () async {
    launcher.updateMaxRunningGames(1);
    await launcher.launchBatch([first, second], mode: BatchLaunchMode.favorites);
    await launcher.suspendHours();
    await launcher.resumeHours();
    expect(launcher.launchedGames.single.app.appId, first.appId);
    expect(launcher.batchQueue.single.appId, second.appId);
  });

  test('hours can be queued for the same game while cards own its session', () async {
    work.mode = CardFarmingMode.sequential;
    await work.start([first]);
    await until(() => launcher.launchedGames.isNotEmpty);
    await launcher.launchBatch([first, second], mode: BatchLaunchMode.favorites);
    expect(launcher.batchQueue.map((app) => app.appId), [first.appId, second.appId]);
    expect(steam.starts, [first.appId]);
    await work.stop();
    expect(steam.starts, [first.appId, first.appId, second.appId]);
  });

  test('combined mode groups low playtime games then switches to one game', () async {
    work.mode = CardFarmingMode.combined;
    await work.start([first, second]);
    await until(() => steam.starts.length == 2);
    expect(work.phase, WorkPhase.group);
    apps[first.appId] = first.copyWith(playtimeMinutes: 120);
    apps[second.appId] = second.copyWith(playtimeMinutes: 120);
    work.togglePause();
    await until(() => launcher.launchedGames.isEmpty);
    work.togglePause();
    await until(() => steam.starts.length == 3);
    expect(work.phase, WorkPhase.single);
    expect(launcher.launchedGames.single.app.appId, first.appId);
  });

  test('server time meeting a suspended target prevents a restart', () async {
    apps[first.appId] = first.copyWith(playtimeMinutes: 20, stopAtMinutes: const Optional.of(40));
    await launcher.toggleGame(apps[first.appId]!);
    work.refreshHourly = true;
    await until(() => steam.timeQueries > 0 && !work.active);
    work.refreshHourly = false;
    expect(launcher.launchedGames, isEmpty);
    expect(steam.starts, [first.appId]);
  });

  test('clearing the card cache clears in-memory results on reload', () async {
    await work.refresh(appIds: [first.appId]);
    expect(work.drops, isNotEmpty);
    await File('${directory.path}/cards.json').delete();
    await work.loadCache();
    expect(work.drops, isEmpty);
    expect(work.checkedAt, isNull);
  });
}

Future<void> until(bool Function() condition) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition not reached');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

class CardSteam() extends FakeSteam {
  int? count = 1;
  int holds = 0;
  int timeQueries = 0;
  Completer<Map<String, dynamic>>? gate;

  @override
  Future<Future<void> Function()> holdSession(String steamId) async {
    holds++;
    return () async {
      holds--;
    };
  }

  @override
  void cancelDataQueries() {
    if (gate case final pending? when !pending.isCompleted) {
      pending.completeError(StateError('cancelled'));
    }
  }

  @override
  Future<Map<String, dynamic>> queryData(String steamId, String command, {List<int> appIds = const []}) async {
    if (gate != null) {
      return await gate!.future;
    }
    if (command == 'playtime') {
      timeQueries++;
      return {
        'minutes': {'${first.appId}': 40},
      };
    }
    return {
      'cards': {
        'steamId': accountId,
        'complete': true,
        'checkedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'games': [
          for (final id in appIds) {'appId': id, 'name': 'Game $id', 'remaining': count},
        ],
      },
    };
  }
}
