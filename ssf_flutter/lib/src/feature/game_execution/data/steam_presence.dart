import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';

abstract interface class SteamPresenceLease() {
  Future<void> close();
}

/// One desktop status lease spans all games, including launches still in flight.
typedef SteamPresenceOpener = Future<SteamPresenceLease> Function(String steamId, {required bool localClientRequired});

class GamePresenceController({SteamPresenceOpener? open}) {
  final SteamPresenceOpener _open = open ?? _DesktopPresenceLease.open;
  Future<void> _tail = Future.value();
  SteamPresenceLease? _lease;
  String? _steamId;
  int _users = 0;
  int _operations = 0;
  bool get isActive => _users > 0 || _operations > 0;

  Future<T> _serialize<T>(Future<T> Function() action) {
    _operations++;
    final Future<T> result = _tail.then((_) => action()).whenComplete(() => _operations--);
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<Future<void> Function()> acquire(String steamId, {bool localClientRequired = true}) => _serialize(() async {
    if (_lease == null) {
      _lease = await _open(steamId, localClientRequired: localClientRequired);
      _steamId = steamId;
    } else if (_steamId != steamId) {
      throw const GameRunnerException('account_mismatch');
    }
    _users++;
    Future<void>? released;
    return () => released ??= _serialize(() async {
      if (--_users != 0) {
        return;
      }
      final SteamPresenceLease lease = _lease!;
      _lease = null;
      _steamId = null;
      await lease.close();
    });
  });

  Future<void> get settled => _tail;
}

class _DesktopPresenceLease(final Process _process) implements SteamPresenceLease {
  Future<void>? _closing;

  static Future<SteamPresenceLease> open(String steamId, {required bool localClientRequired}) async {
    await AppPaths.nativeRuntime.create(recursive: true);
    final Process process = await Process.start(
      AppPaths.executable('ssf_steam_helper').path,
      ['--steam-presence', '--expected-steam-id', steamId, if (!localClientRequired) '--optional-client'],
      workingDirectory: AppPaths.data.path,
      environment: {'DOTNET_BUNDLE_EXTRACT_BASE_DIR': AppPaths.nativeRuntime.path},
    );
    final lease = _DesktopPresenceLease(process);
    final ready = Completer<void>();
    final StreamSubscription<List<int>> errors = process.stderr.listen((_) {});
    final StreamSubscription<String> output = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line == 'SSF_PRESENCE_READY:$steamId' && !ready.isCompleted) {
              ready.complete();
            }
          },
          onError: (Object error) {
            if (!ready.isCompleted) {
              ready.completeError(error);
            }
          },
          onDone: () {
            if (!ready.isCompleted) {
              ready.completeError(const GameRunnerException('steam_presence_failed'));
            }
          },
        );
    unawaited(
      process.exitCode.then((_) async {
        await output.cancel();
        await errors.cancel();
        if (!ready.isCompleted) {
          ready.completeError(const GameRunnerException('steam_presence_failed'));
        }
      }),
    );
    try {
      await ready.future.timeout(const Duration(seconds: 12));
      return lease;
    } on Object {
      await lease.close();
      throw const GameRunnerException('steam_presence_failed');
    }
  }

  @override
  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    try {
      await _process.stdin.close().timeout(const Duration(seconds: 1));
    } on Object {
      /* EOF may already have been delivered. */
    }
    try {
      // The helper can retry restoration three times, each taking up to 5 s.
      final int code = await _process.exitCode.timeout(const Duration(seconds: 20));
      if (code != 0) {
        throw const GameRunnerException('steam_presence_failed');
      }
    } on TimeoutException {
      _process.kill();
      await _process.exitCode;
      throw const GameRunnerException('steam_presence_failed');
    }
  }
}
