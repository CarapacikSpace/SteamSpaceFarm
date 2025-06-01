import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/model/optional.dart';
import 'package:space_farm/src/shared/snackbar.dart';
import 'package:space_farm/src/steam/data/steam_game.dart';
import 'package:space_farm/src/steam/model/steam_game_process.dart';

class GameLauncher {
  GameLauncher({
    required this.context,
    required this.appsRepository,
    required this.steamGame,
    required this.onUpdateAppList,
  });

  final BuildContext context;
  final IAppsRepository appsRepository;
  final SteamGameService steamGame;
  final ValueChanged<LocalApp> onUpdateAppList;

  final launchedGames = <SteamGameProcess>[];
  final batchLaunchedAppIds = <int>{};
  final batchQueue = Queue<LocalApp>();
  final gameStartTimes = <int, DateTime>{};
  final gameTimers = <int, Timer>{};

  Future<void> toggleGame(LocalApp app) async {
    final appId = app.appId;
    final launchedProcess = launchedGames.firstWhereOrNull((p) => p.app.appId == appId);

    if (launchedProcess != null) {
      try {
        steamGame.killProcessById(launchedProcess);
        batchLaunchedAppIds.remove(appId);
      } on Object catch (e, st) {
        showSnack(context, 'Error killing process $appId: $e\n$st');
      }

      launchedGames.removeWhere((p) => p.app.appId == appId);
      gameTimers[appId]?.cancel();
      gameTimers.remove(appId);

      final startedAt = gameStartTimes.remove(appId);
      if (startedAt != null) {
        final playedMinutes = DateTime.now().difference(startedAt).inMinutes;
        final stopAtMinutes = app.stopAtMinutes == null || playedMinutes >= app.stopAtMinutes!
            ? null
            : app.stopAtMinutes!;
        final updatedApp = app.copyWith(
          playtimeMinutes: (app.playtimeMinutes ?? 0) + playedMinutes,
          stopAtMinutes: Optional.of(stopAtMinutes),
        );
        try {
          onUpdateAppList.call(updatedApp);
          await appsRepository.updateApp(app);
        } on Object catch (e, st) {
          if (context.mounted) {
            showSnack(context, 'Error update game time $appId: $e\n$st');
          }
        }
      }
      return;
    }
    try {
      final launched = await steamGame.launchApp(app);
      launchedGames.add(launched);
      gameStartTimes[appId] = DateTime.now();
      onUpdateAppList.call(app);

      if (app.stopAtMinutes == null) {
        return;
      }
      gameTimers[appId] = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final startedAt = gameStartTimes[appId];
        final now = DateTime.now();
        final alreadyPlayed = app.playtimeMinutes ?? 0;
        final sessionMinutes = startedAt != null ? now.difference(startedAt).inMinutes : 0;
        final totalMinutes = alreadyPlayed + sessionMinutes;

        if (totalMinutes >= app.stopAtMinutes!) {
          timer.cancel();
          await toggleGame(app);

          if (batchQueue.isNotEmpty) {
            final random = Random();
            final next = batchQueue.removeFirst();
            batchLaunchedAppIds.add(next.appId);
            await toggleGame(next);
            await Future<void>.delayed(Duration(milliseconds: 500 + random.nextInt(500)));
          }
        }
      });
    } on Object catch (e, st) {
      if (context.mounted) {
        showSnack(context, 'Error running process $appId: $e\n$st');
      }
    }
  }
}
