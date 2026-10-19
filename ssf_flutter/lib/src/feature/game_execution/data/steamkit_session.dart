import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';

typedef SteamKitProcessStarter = Future<Process> Function(String executable, List<String> arguments);

/// One helper connection publishes the full set of playing AppIDs to Steam.
class SteamKitSession({
  required final String steamId,
  bool invisible = false,
  bool dataOnly = false,
  SteamKitProcessStarter? startProcess,
  String? sessionDirectory,
}) {
  this {
    _spawn = (startProcess ?? _start)(AppPaths.executable('ssf_steam_helper').path, [
      '--steamkit-play',
      '--data-dir',
      sessionDirectory ?? AppPaths.steamSession.path,
      '--expected-steam-id',
      steamId,
      if (invisible) '--invisible',
      if (dataOnly) '--data-only',
    ]);
    unawaited(_open());
    unawaited(_ready.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
  }

  static Future<Process> _start(String executable, List<String> args) async {
    await AppPaths.nativeRuntime.create(recursive: true);
    return await Process.start(
      executable,
      args,
      workingDirectory: AppPaths.data.path,
      environment: {'DOTNET_BUNDLE_EXTRACT_BASE_DIR': AppPaths.nativeRuntime.path},
    );
  }

  late final Future<Process> _spawn;
  Process? _process;
  final _ready = Completer<void>();
  final _games = <String, SteamKitGameConnection>{};
  StreamSubscription<String>? _output;
  StreamSubscription<List<int>>? _errors;
  Future<void>? _closing;
  bool _failed = false;
  bool closed = false;
  bool keepAlive = false;
  int _requestId = 0;
  int _queryGeneration = 0;
  final _requests = <String, Completer<Map<String, dynamic>>>{};

  Future<Map<String, dynamic>> query(String command, {List<int> appIds = const []}) async {
    final int generation = _queryGeneration;
    await _ready.future.timeout(const Duration(seconds: 65));
    if (closed || generation != _queryGeneration) {
      throw const GameRunnerException('steamkit_session_failed');
    }
    final id = '${++_requestId}';
    final completion = Completer<Map<String, dynamic>>();
    // Cancellation or a fast helper failure can arrive while stdin is flushing.
    unawaited(completion.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
    _requests[id] = completion;
    try {
      _process!.stdin.writeln(jsonEncode({'v': 1, 'command': command, 'requestId': id, 'appIds': appIds}));
      await _process!.stdin.flush().timeout(const Duration(seconds: 2));
      return await completion.future.timeout(const Duration(minutes: 5, seconds: 5));
    } finally {
      _requests.remove(id);
    }
  }

  void _failRequests() {
    for (final Completer<Map<String, dynamic>> request in _requests.values) {
      if (!request.isCompleted) {
        request.completeError(const GameRunnerException('steamkit_session_failed'));
      }
    }
    _requests.clear();
  }

  void cancelQueries() {
    _queryGeneration++;
    if (!closed && _process != null) {
      try {
        _process!.stdin.writeln('{"v":1,"command":"cancel_data"}');
      } on Object {
        /* Already closed. */
      }
    }
    _failRequests();
  }

  static int _nextId = -1;

  Future<void> _open() async {
    try {
      final Process process = _process = await _spawn;
      unawaited(
        process.exitCode.then((code) {
          closed = true;
          _failReady();
          _failRequests();
          for (final SteamKitGameConnection game in _games.values.toList()) {
            game.finish(_failed || (code == 0 && _closing == null) ? 6 : code);
          }
          _games.clear();
          unawaited(_output?.cancel());
          unawaited(_errors?.cancel());
        }),
      );
      if (closed) {
        process.kill();
        return;
      }
      _errors = process.stderr.listen((_) {}, onError: (Object _) {});
      _output = _lines(process.stdout).listen(
        _event,
        onError: (Object _) => _failSession(),
        onDone: () {
          if (!closed) {
            _failSession();
          }
        },
      );
    } on Object {
      closed = true;
      _failReady();
    }
  }

  void _failReady() {
    if (!_ready.isCompleted) {
      _ready.completeError(const GameRunnerException('steamkit_session_failed'));
    }
  }

  Future<SteamKitGameConnection> launch(int appId, String runId, Duration? duration) async {
    try {
      await _ready.future.timeout(const Duration(seconds: 65));
      if (closed) {
        throw const GameRunnerException('steamkit_session_failed');
      }
      final game = SteamKitGameConnection(this, appId, runId, _nextId--);
      _games[runId] = game;
      await send(game, 'start', duration);
      await game.waitUntilReady();
      return game;
    } on Object {
      await shutdown();
      rethrow;
    }
  }

  void _event(String line) {
    try {
      final value = jsonDecode(line) as Map<String, dynamic>;
      if (value['v'] != 1 || value['steamId'] != steamId) {
        throw const FormatException('identity');
      }
      if (value['event'] == 'data') {
        final Completer<Map<String, dynamic>>? request = _requests[value['requestId']];
        if (request != null && !request.isCompleted) {
          if (value['error'] != null) {
            request.completeError(const GameRunnerException('session_data_failed'));
          } else {
            request.complete(value);
          }
        }
        return;
      }
      if (value['event'] == 'session_ready') {
        if (_ready.isCompleted || value['runId'] != '' || value['appId'] != 0) {
          throw const FormatException('ready');
        }
        _ready.complete();
        return;
      }
      if (value['event'] == 'session_failed') {
        throw const FormatException('session');
      }
      final SteamKitGameConnection? game = _games[value['runId']];
      if (game == null) {
        return;
      } // A stop acknowledgement may follow an expired deadline.
      if (value['appId'] != game.appId) {
        throw const FormatException('app');
      }
      switch (value['event']) {
        case 'ready':
          game.ready();
        case 'stopped':
          if (_games.length == 1 && !keepAlive) {
            // Keep the last game active until the shared helper has disconnected.
            unawaited(shutdown());
          } else {
            game.finish(0);
            _games.remove(game.runId);
          }
        case 'deadline_updated':
          break;
        default:
          throw const FormatException('event');
      }
    } on Object {
      _failSession();
    }
  }

  void _failSession() {
    _failed = true;
    _failReady();
    unawaited(shutdown());
  }

  Future<void> send(SteamKitGameConnection game, String command, [Duration? duration]) async {
    if (closed) {
      throw const GameRunnerException('steamkit_session_failed');
    }
    _process!.stdin.writeln(
      jsonEncode({
        'v': 1,
        'command': command,
        'runId': game.runId,
        'appId': game.appId,
        'runSeconds': duration == null ? null : (duration.inMilliseconds / 1000).ceil(),
      }),
    );
    await _process!.stdin.flush().timeout(const Duration(seconds: 2));
  }

  Future<void> shutdown() => _closing ??= _shutdown();

  Future<void> _shutdown() async {
    closed = true;
    _failReady();
    _failRequests();
    Process process;
    try {
      process = await _spawn;
    } on Object {
      return;
    }
    try {
      process.stdin.writeln('{"v":1,"command":"stop_all"}');
      await process.stdin.flush().timeout(const Duration(seconds: 1));
      await process.stdin.close().timeout(const Duration(seconds: 1));
    } on Object {
      /* A terminated helper already closed its pipe. */
    }
    try {
      await process.exitCode.timeout(const Duration(seconds: 3));
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await process.exitCode.timeout(const Duration(seconds: 3));
    }
  }

  static Stream<String> _lines(Stream<List<int>> stream) async* {
    final pending = <int>[];
    await for (final chunk in stream) {
      for (final byte in chunk) {
        if (byte == 10) {
          yield utf8.decode(pending);
          pending.clear();
        } else {
          if (pending.length >= 2 * 1024 * 1024) {
            throw const FormatException('frame_too_large');
          }
          pending.add(byte);
        }
      }
    }
    if (pending.isNotEmpty) {
      yield utf8.decode(pending);
    }
  }
}

final class SteamKitGameConnection(
  final SteamKitSession _session,
  final int appId,
  @override final String runId,
  @override final int pid,
) implements GameConnection {
  this {
    unawaited(_ready.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
  }

  @override
  Process get process => _session._process!;
  @override
  final Stopwatch elapsed = Stopwatch();
  @override
  bool exited = false;
  final _ready = Completer<void>();
  final _exit = Completer<int>();
  Future<void>? _stopping;

  @override
  Future<int> get exitCode => _exit.future;

  void ready() {
    if (_ready.isCompleted) {
      throw const FormatException('duplicate ready');
    }
    elapsed.start();
    _ready.complete();
  }

  void finish(int code) {
    if (exited) {
      return;
    }
    exited = true;
    elapsed.stop();
    if (!_ready.isCompleted) {
      _ready.completeError(const GameRunnerException('steamkit_session_failed'));
    }
    _exit.complete(code);
  }

  @override
  Future<void> waitUntilReady({Duration timeout = const Duration(seconds: 15)}) => _ready.future.timeout(timeout);

  @override
  Future<void> updateDeadline(Duration? remaining) => exited
      ? Future.value()
      : remaining != null && remaining <= Duration.zero
      ? stop()
      : _session.send(this, 'update_deadline', remaining);

  @override
  Future<void> stop({bool force = false}) {
    if (exited) {
      return Future.value();
    }
    if (force) {
      return _session.shutdown();
    }
    return _stopping ??= _stop();
  }

  Future<void> _stop() async {
    try {
      await _session.send(this, 'stop');
      await exitCode.timeout(const Duration(seconds: 3));
    } on Object {
      await _session.shutdown();
    }
    if (!exited) {
      throw const GameRunnerException('stop_not_confirmed');
    }
  }
}
