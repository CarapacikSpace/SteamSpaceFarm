import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steamkit_session.dart';

import 'support/fake_process.dart';

const account = '76561198000000001';

void main() {
  late FakeProcess process;
  late SteamKitSession session;
  setUp(() async {
    process = FakeProcess();
    session = SteamKitSession(
      steamId: account,
      sessionDirectory: 'unused',
      startProcess: (_, args) async {
        expect(args, contains('--steamkit-play'));
        return process;
      },
    );
    await tick();
    emit(process, 'session_ready', '', 0);
  });
  tearDown(() async {
    process.finish(0);
    await session.shutdown();
  });

  test('one helper owns concurrent games with independent stops and deadlines', () async {
    final Future<SteamKitGameConnection> firstFuture = session.launch(632360, 'first', const Duration(seconds: 60));
    await tick();
    emit(process, 'ready', 'first', 632360);
    final SteamKitGameConnection first = await firstFuture;
    final Future<SteamKitGameConnection> secondFuture = session.launch(230410, 'second', null);
    await tick();
    emit(process, 'ready', 'second', 230410);
    final SteamKitGameConnection second = await secondFuture;
    expect(first.pid, isNot(second.pid));
    expect(first.process, same(second.process));
    await second.updateDeadline(const Duration(seconds: 10));
    final Future<void> stopping = first.stop();
    await tick();
    emit(process, 'stopped', 'first', 632360);
    await stopping;
    expect(first.exited, isTrue);
    expect(second.exited, isFalse);
    expect(session.closed, isFalse);
    expect(process.commands.where((command) => command['command'] == 'start'), hasLength(2));
    expect(
      process.commands.any((command) => command['command'] == 'update_deadline' && command['runSeconds'] == 10),
      isTrue,
    );
    final Future<void> lastStop = second.stop();
    await tick();
    emit(process, 'stopped', 'second', 230410);
    await tick();
    expect(second.exited, isFalse);
    expect(process.commands.last['command'], 'stop_all');
    process.finish(0);
    await lastStop;
    expect(second.exited, isTrue);
  });

  test('helper exit finishes all games and stops their playtime clocks', () async {
    final Future<SteamKitGameConnection> pending = session.launch(570, 'dota', null);
    await tick();
    emit(process, 'ready', 'dota', 570);
    final SteamKitGameConnection game = await pending;
    process.finish(6);
    expect(await game.exitCode, 6);
    expect(game.exited, isTrue);
    expect(game.elapsed.isRunning, isFalse);
    expect(session.closed, isTrue);
  });

  for (final protocolFailure in [false, true]) {
    test(
      'unexpected ${protocolFailure ? "protocol failure" : "clean helper exit"} stays a failure after ready',
      () async {
        final Future<SteamKitGameConnection> pending = session.launch(570, 'dota', null);
        await tick();
        emit(process, 'ready', 'dota', 570);
        final SteamKitGameConnection game = await pending;
        if (protocolFailure) {
          emit(process, 'session_failed', '', 0);
          await tick();
        }
        process.finish(0);
        expect(await game.exitCode, isNot(0));
        expect(game.elapsed.isRunning, isFalse);
      },
    );
  }
}

void emit(FakeProcess process, String event, String runId, int appId) => process.output.add(
  utf8.encode('${jsonEncode({'v': 1, 'event': event, 'runId': runId, 'appId': appId, 'steamId': account})}\n'),
);
