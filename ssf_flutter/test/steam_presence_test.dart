import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_presence.dart';

void main() {
  test('concurrent games restore status only after the last release', () async {
    final lease = FakePresenceLease();
    var opens = 0;
    final controller = GamePresenceController(
      open: (_, {required localClientRequired}) async {
        opens++;
        return lease;
      },
    );
    final List<Future<void> Function()> releases = await Future.wait([
      controller.acquire('account'),
      controller.acquire('account'),
    ]);
    expect(opens, 1);
    expect(controller.isActive, isTrue);
    await releases.first();
    await releases.first(); // Failed starts and stop completion can race.
    expect(lease.closed, 0);
    await releases.last();
    expect(lease.closed, 1);
    expect(controller.isActive, isFalse);
  });

  test('a new launch waits for restoration of the previous session', () async {
    final restoring = Completer<void>();
    final first = FakePresenceLease(restoring: restoring.future);
    var opens = 0;
    final controller = GamePresenceController(
      open: (_, {required localClientRequired}) async => ++opens == 1 ? first : FakePresenceLease(),
    );
    final Future<void> Function() release = await controller.acquire('account');
    final Future<void> ending = release();
    final Future<Future<void> Function()> next = controller.acquire('account');
    await Future<void>.delayed(Duration.zero);
    expect(opens, 1);
    expect(controller.isActive, isTrue);
    restoring.complete();
    await ending;
    await (await next)();
    expect(opens, 2);
    expect(controller.isActive, isFalse);
  });

  test('failed acquisition does not poison later launches', () async {
    var opens = 0;
    final lease = FakePresenceLease();
    final controller = GamePresenceController(
      open: (_, {required localClientRequired}) async {
        if (++opens == 1) {
          throw StateError('client unavailable');
        }
        return lease;
      },
    );
    await expectLater(controller.acquire('account'), throwsStateError);
    final Future<void> Function() release = await controller.acquire('account');
    await release();
    expect(lease.closed, 1);
  });

  test('a different account cannot share an active status lease', () async {
    final lease = FakePresenceLease();
    final controller = GamePresenceController(open: (_, {required localClientRequired}) async => lease);
    final Future<void> Function() release = await controller.acquire('first');
    await expectLater(controller.acquire('second'), throwsException);
    expect(lease.closed, 0);
    await release();
    expect(lease.closed, 1);
  });
}

class FakePresenceLease({final Future<void>? restoring}) implements SteamPresenceLease {
  int closed = 0;

  @override
  Future<void> close() async {
    closed++;
    await restoring;
  }
}
