import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/process_action_queue.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';

import 'support/steam_helper_fakes.dart';

void main() {
  test('global stop requests every owner immediately and coalesces repeats', () async {
    final manager = SteamProcessManager();
    final gates = [Completer<void>(), Completer<void>()];
    final active = [true, true];
    final stopped = <int>[];
    for (var i = 0; i < 2; i++) {
      manager.register(
        isActive: () => active[i],
        stop: () async {
          stopped.add(i);
          await gates[i].future;
          active[i] = false;
        },
      );
    }
    final Future<void> stop = manager.stopAll();
    expect(stopped, [0, 1]);
    expect(manager.acceptingStarts, isFalse);
    expect(identical(stop, manager.stopAll()), isTrue);
    for (final gate in gates) {
      gate.complete();
    }
    await stop;
    expect(manager.acceptingStarts, isTrue);
  });

  test('failed disposal keeps a helper reachable for forced stop retry', () async {
    final manager = SteamProcessManager();
    final helper = FakeSteamHelperClient();
    final sync = SteamLibrarySyncController(
      processManager: manager,
      client: helper,
      sessions: MemorySteamSessionStore(),
    );
    final Future<void> run = sync.start(SteamSignInMethod.qr);
    helper.failCancel = true;
    sync.dispose();
    await expectLater(manager.shutdown(), throwsStateError);
    expect(helper.running, isTrue);
    helper.failCancel = false;
    await manager.shutdown();
    await run;
    expect(helper.running, isFalse);
    expect(manager.acceptingStarts, isFalse);
  });

  test('stopping one app instance leaves other instances alone', () async {
    final first = SteamProcessManager();
    final second = SteamProcessManager();
    var secondActive = true;
    second.register(
      isActive: () => secondActive,
      stop: () async {
        secondActive = false;
      },
    );
    await first.stopAll();
    expect(secondActive, isTrue);
    await second.stopAll();
    expect(secondActive, isFalse);
  });

  test('normal actions wait between calls; emergency cancellation skips cooldown and pending actions', () async {
    final waiting = Completer<void>();
    final release = Completer<void>();
    final waits = <Duration>[];
    final queue = ProcessActionQueue(
      nextDelay: () => const Duration(milliseconds: 500),
      wait: (duration) {
        waits.add(duration);
        waiting.complete();
        return release.future;
      },
    );
    final calls = <int>[];
    await queue.run(() async {
      calls.add(1);
    });
    expect(waits, isEmpty);
    final Future<void> pending = queue.run(() async {
      calls.add(2);
    });
    await waiting.future;
    expect(waits.single.inMilliseconds, inInclusiveRange(300, 500));
    queue.cancelPending();
    await pending;
    expect(calls, [1]);
    release.complete();
    await queue.run(() async {
      calls.add(3);
    });
    expect(calls, [1, 3]);
  });
}
