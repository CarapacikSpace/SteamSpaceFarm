import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';

enum SteamHelperFailure() {
  start,
  protocol,
  transport,
  input,
  stop,
  timeout,
}

class const SteamHelperException(final SteamHelperFailure failure) implements Exception;

abstract interface class SteamHelperClient() {
  bool get running;

  Future<int> run({
    required SteamSignInMethod method,
    required Directory sessionDirectory,
    required void Function(SteamHelperEvent) onEvent,
  });

  Future<void> sendInput(String requestId, String value);

  Future<void> cancel({bool force = false});
}

typedef SteamHelperProcessStarter = Future<Process> Function(String executable, List<String> arguments);

class ProcessSteamHelperClient({SteamHelperProcessStarter? startProcess}) implements SteamHelperClient {
  final SteamHelperProcessStarter _startProcess = startProcess ?? _start;
  _HelperOperation? _active;

  static Future<Process> _start(String executable, List<String> arguments) async {
    await AppPaths.nativeRuntime.create(recursive: true);
    return await Process.start(
      executable,
      arguments,
      workingDirectory: AppPaths.data.path,
      environment: {'DOTNET_BUNDLE_EXTRACT_BASE_DIR': AppPaths.nativeRuntime.path},
    );
  }

  @override
  bool get running => _active != null;

  @override
  Future<int> run({
    required SteamSignInMethod method,
    required Directory sessionDirectory,
    required void Function(SteamHelperEvent) onEvent,
  }) {
    if (_active != null) {
      throw StateError('Helper already running');
    }
    final operation = _HelperOperation(startProcess: _startProcess, onEvent: onEvent);
    _active = operation;
    return operation.run(method, sessionDirectory).whenComplete(() {
      if (identical(_active, operation) && operation.stopped) {
        _active = null;
      }
    });
  }

  @override
  Future<void> sendInput(String requestId, String value) async {
    final _HelperOperation? operation = _active;
    if (operation == null) {
      throw const SteamHelperException(SteamHelperFailure.input);
    }
    await operation.sendInput(requestId, value);
  }

  @override
  Future<void> cancel({bool force = false}) async {
    final _HelperOperation? operation = _active;
    if (operation == null) {
      return;
    }
    await operation.cancel(force: force);
    if (identical(_active, operation) && operation.stopped) {
      _active = null;
    }
  }
}

class _HelperOperation({
  required final SteamHelperProcessStarter startProcess,
  required final void Function(SteamHelperEvent) onEvent,
}) {
  Future<Process>? _starting;
  Process? _process;
  Future<void>? _cancelling;
  bool _cancelled = false;
  bool stopped = false;

  Future<int> run(SteamSignInMethod method, Directory directory) async {
    StreamSubscription<String>? output;
    StreamSubscription<List<int>>? errors;
    try {
      await directory.create(recursive: true);
      if (_cancelled) {
        stopped = true;
        return 4;
      }
      final String cliMethod = method == SteamSignInMethod.session ? 'auto' : method.name;
      try {
        _starting = startProcess(AppPaths.executable('ssf_steam_helper').path, [
          '--events',
          '--$cliMethod',
          '--timeout-seconds',
          '600',
          '--data-dir',
          directory.path,
        ]);
        _process = await _starting;
      } on Object {
        stopped = true;
        throw const SteamHelperException(SteamHelperFailure.start);
      }
      final Process process = _process!;
      if (_cancelled) {
        await cancel();
        return 4;
      }
      final done = Completer<void>();
      SteamHelperFailure? failure;
      output = decodeHelperLines(process.stdout).listen(
        (line) {
          if (_cancelled || failure != null) {
            return;
          }
          try {
            onEvent(SteamHelperEvent.parse(line));
          } on Object {
            failure = SteamHelperFailure.protocol;
            process.kill();
          }
        },
        onError: (Object _) {
          failure = SteamHelperFailure.protocol;
          process.kill();
        },
        onDone: done.complete,
      );

      errors = process.stderr.listen((_) {}, onError: (Object _) {});
      final int code;
      try {
        code = await process.exitCode.timeout(const Duration(seconds: 615));
        stopped = true;
      } on TimeoutException {
        await _killAndWait(process);
        throw const SteamHelperException(SteamHelperFailure.timeout);
      }
      try {
        await done.future.timeout(const Duration(seconds: 2));
      } on TimeoutException {
        throw const SteamHelperException(SteamHelperFailure.transport);
      }
      if (failure != null && !_cancelled) {
        throw SteamHelperException(failure!);
      }
      return code;
    } catch (_) {
      if (_process == null) {
        stopped = true;
      }
      rethrow;
    } finally {
      await output?.cancel();
      await errors?.cancel();
      if (stopped) {
        try {
          await _process?.stdin.close().timeout(const Duration(seconds: 1));
        } on Object {
          AppLogger.info('Helper input already closed', name: 'Steam');
        }
      }
    }
  }

  Future<void> sendInput(String requestId, String value) async {
    final Process? process = _process;
    if (process == null || stopped || _cancelled) {
      throw const SteamHelperException(SteamHelperFailure.input);
    }
    try {
      process.stdin.writeln(jsonEncode({'v': 1, 'command': 'auth.input', 'requestId': requestId, 'value': value}));
      await process.stdin.flush().timeout(const Duration(seconds: 2));
    } on Object {
      throw const SteamHelperException(SteamHelperFailure.input);
    }
  }

  Future<void> cancel({bool force = false}) {
    _cancelled = true;
    if (force) {
      return _forceCancel();
    }
    return _cancelling ??= _cancel();
  }

  Future<void> _forceCancel() async {
    final Process process;
    try {
      if (_starting == null) {
        stopped = true;
        return;
      }
      process = await _starting!;
    } on Object {
      stopped = true;
      return;
    }
    if (!stopped) {
      await _killAndWait(process);
    }
  }

  Future<void> _cancel() async {
    final Process process;
    try {
      final Future<Process>? starting = _starting;
      if (starting == null) {
        stopped = true;
        return;
      }
      process = await starting;
    } on Object {
      stopped = true;
      return;
    }
    if (stopped) {
      return;
    }
    try {
      process.stdin.writeln('{"v":1,"command":"cancel"}');
      await process.stdin.flush().timeout(const Duration(seconds: 1));
      await process.stdin.close().timeout(const Duration(seconds: 1));
      await process.exitCode.timeout(const Duration(seconds: 3));
      stopped = true;
    } on Object {
      await _killAndWait(process);
    }
  }

  Future<void> _killAndWait(Process process) async {
    process.kill();
    try {
      await process.exitCode.timeout(const Duration(seconds: 3));
      stopped = true;
    } on Object {
      _cancelling = null;
      throw const SteamHelperException(SteamHelperFailure.stop);
    }
  }
}

Stream<String> decodeHelperLines(Stream<List<int>> stream) async* {
  final bytes = <int>[];
  await for (final chunk in stream) {
    for (final byte in chunk) {
      if (byte == 10) {
        yield utf8.decode(bytes);
        bytes.clear();
      } else {
        if (bytes.length >= 8 * 1024 * 1024) {
          throw const FormatException('frame_limit');
        }
        bytes.add(byte);
      }
    }
  }
  if (bytes.isNotEmpty) {
    throw const FormatException('incomplete_frame');
  }
}
