import 'dart:async';
import 'dart:io';
import 'dart:isolate';

final class RunnerProcess._() implements Process {
  static Future<Process> start(String executable, List<String> arguments, {required String workingDirectory}) async {
    final process = RunnerProcess._();
    try {
      await Isolate.spawn(
        _run,
        (process._events.sendPort, executable, arguments, workingDirectory),
        onError: process._events.sendPort,
        onExit: process._events.sendPort,
        debugName: 'ssf_runner',
      );
      return await process._started.future;
    } on Object {
      process._events.close();
      rethrow;
    }
  }

  late final ReceivePort _events = ReceivePort()..listen(_onEvent);
  final _started = Completer<Process>();
  final _exit = Completer<int>();
  final _stdout = StreamController<List<int>>();
  final _stderr = StreamController<List<int>>();
  late final SendPort _commands;
  late final int _pid;
  var _ended = false;

  @override
  int get pid => _pid;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  Stream<List<int>> get stdout => _stdout.stream;

  @override
  Stream<List<int>> get stderr => _stderr.stream;
  IOSink? _input;

  @override
  IOSink get stdin {
    if (_input == null) {
      _input = IOSink(_RunnerInput(_commands));
      unawaited(_input!.done.then<void>((_) {}, onError: (Object _) {}));
    }
    return _input!;
  }

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    if (_ended) {
      return false;
    }
    _commands.send(('kill', signal));
    return true;
  }

  void _onEvent(dynamic event) {
    switch (event) {
      case ('started', final SendPort commands, final int processId):
        _commands = commands;
        _pid = processId;
        _started.complete(this);
      case ('stdout', final List<int> bytes):
        _stdout.add(bytes);
      case ('stderr', final List<int> bytes):
        _stderr.add(bytes);
      case ('failed', final String executable, final List<String> arguments, final String message, final int code):
        _started.completeError(ProcessException(executable, arguments, message, code));
        _finish(-1);
      case ('exit', final int code):
        _finish(code);
      case null:
        if (!_ended) {
          if (!_started.isCompleted) {
            _started.completeError(StateError('Runner worker exited before startup'));
          }
          _finish(-1);
        }
      case final List<dynamic> _:
        if (!_started.isCompleted) {
          _started.completeError(StateError('Runner worker failed'));
        }
        _finish(-1);
    }
  }

  void _finish(int code) {
    if (_ended) {
      return;
    }
    _ended = true;
    unawaited(_input?.close().then<void>((_) {}, onError: (Object _) {}));
    _exit.complete(code);
    unawaited(_stdout.close());
    unawaited(_stderr.close());
    _events.close();
  }

  static Future<void> _run((SendPort, String, List<String>, String) request) async {
    final (events, executable, arguments, directory) = request;
    Process? process;
    final commands = ReceivePort();
    try {
      process = await Process.start(executable, arguments, workingDirectory: directory);
      final Process child = process;

      unawaited(child.stdin.done.then<void>((_) {}, onError: (Object _) {}));
      final Future<void> output = child.stdout.forEach((bytes) => events.send(('stdout', bytes)));
      final Future<void> errors = child.stderr.forEach((bytes) => events.send(('stderr', bytes)));
      commands.listen((dynamic command) async {
        switch (command) {
          case ('write', final List<int> bytes, final SendPort reply):
            try {
              child.stdin.add(bytes);
              await child.stdin.flush();
              reply.send(true);
            } on Object {
              reply.send(false);
            }
          case ('close', final SendPort reply):
            try {
              await child.stdin.close();
              reply.send(true);
            } on Object {
              reply.send(false);
            }
          case ('kill', final ProcessSignal signal):
            child.kill(signal);
        }
      });
      events.send(('started', commands.sendPort, child.pid));
      final int code = await child.exitCode;
      await Future.wait([output, errors]);
      events.send(('exit', code));
    } on ProcessException catch (error) {
      events.send(('failed', executable, arguments, error.message, error.errorCode));
    } finally {
      if (process != null) {
        process.kill();
        await process.exitCode;
      }
      commands.close();
    }
  }
}

final class _RunnerInput(final SendPort commands) implements StreamConsumer<List<int>> {
  Future<void> _send(Object Function(SendPort) command) async {
    final reply = ReceivePort();
    try {
      commands.send(command(reply.sendPort));
      final dynamic result = await reply.first.timeout(const Duration(seconds: 2));
      if (result != true) {
        throw const FileSystemException('Runner input is closed');
      }
    } finally {
      reply.close();
    }
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final List<int> bytes in stream) {
      await _send((reply) => ('write', bytes, reply));
    }
  }

  @override
  Future<void> close() => _send((reply) => ('close', reply));
}
