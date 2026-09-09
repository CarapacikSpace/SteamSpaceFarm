import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 10));

final class FakeProcess({final bool allowKill = true, final int processId = 12345}) implements Process {
  this {
    _input.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      commands.add(jsonDecode(line) as Map<String, dynamic>);
    });
    stdin = IOSink(_input.sink);
    addTearDown(_closeInput);
  }

  final output = StreamController<List<int>>();
  final errors = StreamController<List<int>>();
  final _input = StreamController<List<int>>();
  final _exit = Completer<int>();
  final commands = <Map<String, dynamic>>[];
  int killCount = 0;

  @override
  late final IOSink stdin;

  @override
  int get pid => processId;

  @override
  Stream<List<int>> get stdout => output.stream;

  @override
  Stream<List<int>> get stderr => errors.stream;

  @override
  Future<int> get exitCode => _exit.future;

  void finish(int code) {
    if (_exit.isCompleted) {
      return;
    }
    _exit.complete(code);
    unawaited(output.close());
    unawaited(errors.close());
  }

  Future<void> _closeInput() async {
    await stdin.close();
    await _input.close();
  }

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killCount++;
    if (!allowKill) {
      return false;
    }
    finish(9);
    return true;
  }
}
