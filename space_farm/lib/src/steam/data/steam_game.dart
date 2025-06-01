import 'dart:developer' as dev show log;
import 'dart:io' show File, Platform, Process;

import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/common/utils.dart';
import 'package:space_farm/src/steam/model/steam_game_process.dart';

class SteamGameService {
  SteamGameService();

  Future<SteamGameProcess> launchApp(LocalApp app) async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final ext = platform == 'windows' ? '.exe' : '';
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final fileName =
        'process${Platform.pathSeparator}steam_game${Platform.pathSeparator}SteamGame_${normalizedPlatform}_$arch$ext';
    final file = File(fileName);

    if (!file.existsSync()) {
      throw Exception('Executable not found: $fileName');
    }

    dev.log('Launching AppID ${app.appId}...');
    final process = await Process.start(file.path, [app.appId.toString()]);

    return SteamGameProcess(app: app, pid: process.pid, process: process);
  }

  void killProcessById(SteamGameProcess p) {
    try {
      if (p.process.kill()) {
        dev.log("Killed '${p.app.name}' (PID ${p.pid})");
      } else {
        dev.log("Failed to kill '${p.app.name}' (PID ${p.pid}): not active or access denied");
      }
    } on Object catch (e) {
      dev.log("Failed to kill '${p.app.name}' (PID ${p.pid}): $e");
    }
  }

  Future<void> killProcesses(List<SteamGameProcess> launchedGames) async {
    for (final p in launchedGames) {
      killProcessById(p);
    }
  }

  Future<void> killAllProcesses() async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final prefix = 'SteamGame_${normalizedPlatform}_$arch';

    dev.log('Searching and terminating all processes with prefix: $prefix');

    if (platform == 'windows') {
      final result = await Process.run('tasklist', []);
      final lines = result.stdout.toString().split('\n');

      for (final line in lines) {
        if (line.contains(prefix)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            final pid = int.tryParse(parts[1]);
            if (pid != null) {
              try {
                await Process.run('taskkill', ['/F', '/PID', '$pid']);
                dev.log('Terminated process $prefix (PID $pid)');
              } on Object catch (e) {
                dev.log('Failed to terminate PID $pid: $e');
              }
            }
          }
        }
      }
    } else if (platform == 'linux' || platform == 'macos') {
      final result = await Process.run('ps', ['-e']);
      final lines = result.stdout.toString().split('\n');

      for (final line in lines) {
        if (line.contains(prefix)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            final pid = int.tryParse(parts[0]);
            if (pid != null) {
              try {
                await Process.run('kill', ['-9', '$pid']);
                dev.log('Terminated process $prefix (PID $pid)');
              } on Object catch (e) {
                dev.log('Failed to terminate PID $pid: $e');
              }
            }
          }
        }
      }
    } else {
      dev.log('Unsupported platform: $platform');
    }
  }
}
