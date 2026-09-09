import 'dart:async';
import 'dart:convert';
import 'dart:io';

final class GameRunnerConnection({
  required final Process process,
  required final int appId,
  required final String expectedSteamId,
  required final String runId,
  final void Function(String message)? onDiagnostic,
}) {
  this {
    _output = _lines(process.stdout).listen(
      _onEvent,
      onError: (Object error, StackTrace stack) => _protocolFailure('invalid_output'),
      onDone: () {
        if (!_ready.isCompleted) {
          _protocolFailure('output_closed_before_ready');
        }
      },
    );

    _errors = process.stderr.listen(
      (bytes) => onDiagnostic?.call(utf8.decode(bytes.take(2048).toList(), allowMalformed: true)),
      onError: (Object error, StackTrace stack) => onDiagnostic?.call('runner_stderr_error'),
    );
    exitCode = process.exitCode.then((code) {
      exited = true;
      elapsed.stop();
      if (!_ready.isCompleted) {
        _ready.completeError(GameRunnerException('exited_before_ready', exitCode: code));
      }
      unawaited(_finishStreams());
      return code;
    });
    unawaited(_ready.future.then<void>((_) {}, onError: (Object error, StackTrace stack) {}));
  }

  final Stopwatch elapsed = Stopwatch();
  final Completer<void> _ready = Completer<void>();
  late final StreamSubscription<String> _output;
  late final StreamSubscription<List<int>> _errors;
  late final Future<int> exitCode;
  Future<void>? _stopping;
  bool exited = false;

  Future<void> waitUntilReady({Duration timeout = const Duration(seconds: 15)}) => _ready.future.timeout(timeout);

  Future<void> updateDeadline(Duration? remaining) async {
    if (exited) {
      return;
    }
    if (remaining != null && remaining <= Duration.zero) {
      await stop();
      return;
    }
    await _send({
      'command': 'update_deadline',
      'runSeconds': remaining == null ? null : (remaining.inMilliseconds / 1000).ceil(),
    });
  }

  Future<void> stop({bool force = false}) {
    if (exited) {
      return Future<void>.value();
    }
    final Future<void>? pending = _stopping;
    if (pending != null) {
      return force ? _stop(force: true) : pending;
    }
    final Future<void> operation = _stop(force: force);
    _stopping = operation;
    unawaited(
      operation.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {
          _stopping = null;
        },
      ),
    );
    return operation;
  }

  Future<void> _stop({required bool force}) async {
    if (!force) {
      try {
        await _send({'command': 'stop'});
        await process.stdin.close().timeout(const Duration(seconds: 1));
      } on Object {
        onDiagnostic?.call('runner_stop_input_closed');
      }
      try {
        await exitCode.timeout(const Duration(seconds: 3));
        return;
      } on TimeoutException {
        onDiagnostic?.call('runner_stop_timeout');
      }
    }
    if (!exited) {
      process.kill(ProcessSignal.sigkill);
    }
    try {
      await exitCode.timeout(const Duration(seconds: 3));
    } on TimeoutException {
      throw const GameRunnerException('stop_not_confirmed');
    }
  }

  Future<void> _send(Map<String, Object?> command) async {
    process.stdin.writeln(jsonEncode(command));
    await process.stdin.flush().timeout(const Duration(seconds: 1));
  }

  void _onEvent(String line) {
    try {
      final Object? value = jsonDecode(line);
      if (value is! Map<String, dynamic> || value['v'] != 1 || value['runId'] != runId) {
        _protocolFailure('incompatible_protocol');
        return;
      }
      switch (value['event']) {
        case 'ready':
          if (_ready.isCompleted || value['appId'] != appId || value['steamId'] != expectedSteamId) {
            _protocolFailure('identity_mismatch');
            return;
          }
          elapsed.start();
          _ready.complete();
        case 'failed':
          _protocolFailure(value['code'] is String ? value['code'] as String : 'runner_failed');
        case 'stopping' || 'stopped' || 'deadline_updated':
          break;
        default:
          _protocolFailure('unknown_event');
      }
    } on Object {
      _protocolFailure('invalid_output');
    }
  }

  void _protocolFailure(String code) {
    if (!_ready.isCompleted) {
      _ready.completeError(GameRunnerException(code));
    }
    onDiagnostic?.call('runner_protocol_error: $code');
    if (!exited) {
      process.kill(ProcessSignal.sigkill);
    }
  }

  Future<void> _finishStreams() async {
    try {
      await process.stdin.close().timeout(const Duration(seconds: 1));
    } on Object {
      onDiagnostic?.call('runner_input_already_closed');
    }
    await _output.cancel();
    await _errors.cancel();
  }

  static Stream<String> _lines(Stream<List<int>> stream) async* {
    final pending = <int>[];
    await for (final chunk in stream) {
      for (final byte in chunk) {
        if (byte == 10) {
          yield utf8.decode(pending);
          pending.clear();
        } else {
          if (pending.length >= 8192) {
            throw const FormatException('Runner frame exceeds 8192 bytes');
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

final class const GameRunnerException(final String code, {final int? exitCode}) implements Exception {
  @override
  String toString() => 'GameRunnerException($code, exitCode: $exitCode)';
}
