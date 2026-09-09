import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/settings/logic/library_cache_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';

void main() {
  late CacheRepository repository;
  late LibraryCacheController controller;
  late int updates;
  setUp(() {
    repository = CacheRepository();
    updates = 0;
    controller = LibraryCacheController(
      repository: repository,
      onLibraryUpdated: () async {
        updates++;
      },
    );
  });
  tearDown(() => controller.dispose());

  test('a delayed count cannot restore applications after clearing', () async {
    final Future<void> count = controller.loadCount();
    final Future<LibraryCacheClearResult?> clear = controller.clear();
    expect(controller.clearing, isTrue);
    expect(await controller.clear(), isNull);
    await controller.loadCount();
    expect(repository.reads, hasLength(1));
    expect(repository.clears, 1);
    expect(repository.forgetAccount, isFalse);
    repository.clearResult.complete();
    expect(await clear, LibraryCacheClearResult.cleared);
    repository.reads.single.complete([const LocalApp(appId: 480, name: 'Synthetic', type: SteamAppType.game)]);
    await count;
    expect(controller.appCount, 0);
    expect(controller.loading, isFalse);
    expect(controller.clearing, isFalse);
    expect(updates, 1);
  });

  test('the latest count wins when reads complete out of order', () async {
    final Future<void> first = controller.loadCount();
    final Future<void> second = controller.loadCount();
    repository.reads.last.complete([]);
    await second;
    repository.reads.first.completeError(StateError('stale read failed'));
    await first;
    expect(controller.appCount, 0);
    expect(controller.countFailed, isFalse);
  });

  test('count and clear failures are recoverable and preserve the known count', () async {
    final Future<void> failed = controller.loadCount();
    repository.reads.last.completeError(StateError('unreadable'));
    await failed;
    expect(controller.countFailed, isTrue);
    final Future<void> retry = controller.loadCount();
    repository.reads.last.complete([const LocalApp(appId: 480, name: 'Synthetic', type: SteamAppType.game)]);
    await retry;
    expect(controller.countFailed, isFalse);
    final Future<LibraryCacheClearResult?> clear = controller.clear();
    repository.clearResult.completeError(StateError('read only'));
    expect(await clear, LibraryCacheClearResult.failed);
    expect(controller.appCount, 1);
    expect(controller.clearing, isFalse);
    expect(updates, 0);
    repository.clearResult = Completer<void>()..complete();
    expect(await controller.clear(), LibraryCacheClearResult.cleared);
    expect(controller.appCount, 0);
    expect(updates, 1);
  });

  test('failed catalog notification leaves a successfully cleared count at zero', () async {
    final failingController = LibraryCacheController(
      repository: repository,
      onLibraryUpdated: () async => throw StateError('catalog refresh failed'),
    );
    addTearDown(failingController.dispose);
    repository.clearResult.complete();
    expect(await failingController.clear(), LibraryCacheClearResult.failed);
    expect(failingController.appCount, 0);
    expect(failingController.clearing, isFalse);
  });

  test('disposing during operations prevents late notifications and UI callbacks', () async {
    final disposedController = LibraryCacheController(
      repository: repository,
      onLibraryUpdated: () async {
        updates++;
      },
    );
    var notifications = 0;
    disposedController.addListener(() => notifications++);
    final Future<void> count = disposedController.loadCount();
    final Future<LibraryCacheClearResult?> clear = disposedController.clear();
    disposedController.dispose();
    final before = notifications;
    repository.reads.single.complete([]);
    repository.clearResult.complete();
    await count;
    expect(await clear, isNull);
    expect(notifications, before);
    expect(updates, 0);
  });
}

class CacheRepository() implements IAppsRepository {
  final reads = <Completer<List<LocalApp>>>[];
  Completer<void> clearResult = Completer<void>();
  int clears = 0;
  bool? forgetAccount;

  @override
  Future<List<LocalApp>> getAppsFromCache() {
    final result = Completer<List<LocalApp>>();
    reads.add(result);
    return result.future;
  }

  @override
  Future<void> clearLibraryCache({bool forgetAccount = false}) {
    clears++;
    this.forgetAccount = forgetAccount;
    return clearResult.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
