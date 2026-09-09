import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/steam/data/steam_helper_client.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_sync_state.dart';

import 'support/fake_process.dart';
import 'support/steam_helper_fakes.dart';

void main() {
  test('NDJSON handles split UTF-8 and rejects incomplete, oversized and unknown frames', () async {
    final List<int> bytes = utf8.encode('{"v":1,"event":"auth.qr","data":{"challengeUrl":"пример"}}\n');
    final List<String> lines = await decodeHelperLines(Stream.fromIterable(bytes.map((b) => [b]))).toList();
    expect((SteamHelperEvent.parse(lines.single) as SteamQrChallenge).url, 'пример');
    await expectLater(decodeHelperLines(Stream.value([123])).drain<void>(), throwsFormatException);
    await expectLater(
      decodeHelperLines(Stream.value(List.filled(8 * 1024 * 1024 + 1, 65))).drain<void>(),
      throwsFormatException,
    );
    expect(
      () => SteamHelperEvent.parse('{"v":1,"event":"auth.input","data":{"kind":"unknown","requestId":"x"}}'),
      throwsFormatException,
    );
  });

  test('transport rejects malformed output and owns the process until exit', () async {
    final Directory directory = await Directory.systemTemp.createTemp('ssf-helper-transport-');
    addTearDown(() => directory.delete(recursive: true));
    final process = FakeProcess();
    final started = Completer<void>();
    final client = ProcessSteamHelperClient(
      startProcess: (_, _) async {
        started.complete();
        return process;
      },
    );
    final Future<int> run = client.run(method: SteamSignInMethod.qr, sessionDirectory: directory, onEvent: (_) {});
    final Future<void> expectation = expectLater(run, throwsA(isA<SteamHelperException>()));
    await started.future;
    process.output.add(utf8.encode('{broken}\n'));
    await expectation;
    expect(process.killCount, 1);
    expect(client.running, isFalse);
  });

  test('cancel during process start waits for that child and prevents a duplicate', () async {
    final Directory directory = await Directory.systemTemp.createTemp('ssf-helper-start-');
    addTearDown(() => directory.delete(recursive: true));
    final starting = Completer<Process>();
    final entered = Completer<void>();
    final process = FakeProcess();
    final client = ProcessSteamHelperClient(
      startProcess: (_, _) {
        entered.complete();
        return starting.future;
      },
    );
    final Future<int> run = client.run(method: SteamSignInMethod.qr, sessionDirectory: directory, onEvent: (_) {});
    await entered.future;
    final Future<void> cancel = client.cancel();
    expect(client.running, isTrue);
    expect(
      () => client.run(method: SteamSignInMethod.qr, sessionDirectory: directory, onEvent: (_) {}),
      throwsStateError,
    );
    starting.complete(process);
    await tick();
    process.finish(4);
    await cancel;
    expect(await run, 4);
    expect(client.running, isFalse);
    expect(process.commands.single['command'], 'cancel');
  });

  test('force stop bypasses normal cancellation grace period', () async {
    final Directory directory = await Directory.systemTemp.createTemp('ssf-helper-force-');
    addTearDown(() => directory.delete(recursive: true));
    final process = FakeProcess();
    final started = Completer<void>();
    final client = ProcessSteamHelperClient(
      startProcess: (_, _) async {
        started.complete();
        return process;
      },
    );
    final Future<int> run = client.run(method: SteamSignInMethod.qr, sessionDirectory: directory, onEvent: (_) {});
    await started.future;
    await tick();
    final Future<void> normal = client.cancel();
    await client.cancel(force: true).timeout(const Duration(milliseconds: 250));
    await normal;
    await run;
    expect(process.killCount, 1);
    expect(client.running, isFalse);
  });

  test('library is published only after successful exit and matching account', () async {
    for (final (String account, int exit, bool success) in [
      ('76561198000000001', 0, true),
      ('76561198000000002', 0, false),
      ('76561198000000001', 1, false),
    ]) {
      final helper = FakeSteamHelperClient();
      final controller = SteamLibrarySyncController(
        processManager: SteamProcessManager(),
        client: helper,
        sessions: MemorySteamSessionStore(),
      );
      final Future<void> run = controller.start(SteamSignInMethod.qr);
      helper
        ..emit(const SteamAuthenticated('76561198000000001'))
        ..emit(SteamLibraryResult(SteamLibrarySnapshot(steamId: account, partial: false, apps: [])));
      expect(controller.library, isNull);
      helper.finish(exit);
      await run;
      expect(controller.library != null, success);
      expect(controller.state.phase, success ? SteamSyncPhase.completed : SteamSyncPhase.failed);
      controller.dispose();
    }
  });

  test('cancelled generation cannot affect the next login; failed stop keeps ownership', () async {
    final helper = FakeSteamHelperClient();
    final controller = SteamLibrarySyncController(
      processManager: SteamProcessManager(),
      client: helper,
      sessions: MemorySteamSessionStore(),
    );
    final Future<void> first = controller.start(SteamSignInMethod.qr);
    final void Function(SteamHelperEvent) oldListener = helper.listener!;
    helper.failCancel = true;
    await controller.cancel();
    expect(controller.busy, isTrue);
    await controller.start(SteamSignInMethod.credentials);
    expect(helper.starts, 1);
    helper.failCancel = false;
    await controller.cancel();
    await first;
    final Future<void> second = controller.start(SteamSignInMethod.credentials, username: 'test', password: 'secret');
    oldListener(const SteamAuthenticated('76561198000000001'));
    expect(controller.authenticated, isFalse);
    helper.emit(const SteamAuthInput(requestId: 'password', kind: SteamAuthInputKind.password));
    await tick();
    expect(helper.inputs.single, ('password', 'secret'));
    await controller.cancel();
    await second;
    controller.dispose();
  });
}
