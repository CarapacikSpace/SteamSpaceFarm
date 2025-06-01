import 'dart:developer' as dev show log;
import 'dart:io' show File, Platform, Process;

import 'package:space_farm/src/common/utils.dart';

class SteamKitService {
  SteamKitService();

  Future<int> getApps(String login, String password) async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final ext = platform == 'windows' ? '.exe' : '';
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final fileName =
        'process${Platform.pathSeparator}get_steam_apps${Platform.pathSeparator}GetSteamApps_${normalizedPlatform}_$arch$ext';
    final file = File(fileName);

    if (!file.existsSync()) {
      throw Exception('Executable not found: $fileName');
    }

    dev.log('Running $fileName');
    final process = await Process.run(file.path, [login, password], runInShell: true);

    dev.log('stdout:');
    dev.log(process.stdout.toString());

    dev.log('stderr:');
    dev.log(process.stderr.toString());

    final exitCode = process.exitCode;
    dev.log('Process exited with code $exitCode');

    if (exitCode != 0) {
      throw Exception('Process exited with code $exitCode\n${process.stderr}');
    }
    return exitCode;
  }

  Future<int> logout() async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final ext = platform == 'windows' ? '.exe' : '';
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final fileName =
        'process${Platform.pathSeparator}get_steam_apps${Platform.pathSeparator}GetSteamApps_${normalizedPlatform}_$arch$ext';
    final file = File(fileName);

    if (!file.existsSync()) {
      throw Exception('Executable not found: $fileName');
    }

    dev.log('Running $fileName');
    final process = await Process.run(file.path, ['--logout'], runInShell: true);

    dev.log('stdout:');
    dev.log(process.stdout.toString());

    dev.log('stderr:');
    dev.log(process.stderr.toString());

    final exitCode = process.exitCode;
    dev.log('Process exited with code $exitCode');
    return exitCode;
  }

  Future<void> killAllProcesses() async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final prefix = 'GetSteamApps_${normalizedPlatform}_$arch';

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
