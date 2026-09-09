import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_controller.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';

import 'support/steam_helper_fakes.dart';

void main() {
  test('import blocks logout and refresh; duplicate events never import twice', () async {
    final helper = FakeSteamHelperClient();
    final sessions = MemorySteamSessionStore();
    final sync = SteamLibrarySyncController(processManager: SteamProcessManager(), client: helper, sessions: sessions);
    final repository = PendingRepository();
    var updates = 0;
    final controller = SteamLibraryController(
      sync: sync,
      repository: repository,
      onLibraryUpdated: () async {
        updates++;
      },
    );
    addTearDown(controller.dispose);
    final Future<void> run = sync.start(SteamSignInMethod.qr);
    helper
      ..emit(const SteamAuthenticated('76561198000000001'))
      ..emit(const SteamLibraryResult(SteamLibrarySnapshot(steamId: '76561198000000001', partial: false, apps: [])))
      ..finish();
    await run;
    expect(controller.saving, isTrue);
    await controller.logout();
    await controller.refresh();
    expect(repository.imports, 1);
    expect(repository.clears, 0);
    expect(helper.starts, 1);
    expect(sessions.forgotten, isFalse);
    repository.imported.complete();
    await Future<void>.delayed(Duration.zero);
    expect(controller.phase, SteamCatalogPhase.updated);
    expect(controller.noticeRevision, 1);
    expect(updates, 1);
    sync.discardLibraryResult();
    expect(repository.imports, 1);
  });

  test('disposing during persistence does not call a dead screen or notify', () async {
    final helper = FakeSteamHelperClient();
    final sync = SteamLibrarySyncController(
      processManager: SteamProcessManager(),
      client: helper,
      sessions: MemorySteamSessionStore(),
    );
    final repository = PendingRepository();
    var updates = 0;
    final controller = SteamLibraryController(
      sync: sync,
      repository: repository,
      onLibraryUpdated: () async {
        updates++;
      },
    );
    final Future<void> run = sync.start(SteamSignInMethod.qr);
    helper
      ..emit(const SteamAuthenticated('76561198000000001'))
      ..emit(const SteamLibraryResult(SteamLibrarySnapshot(steamId: '76561198000000001', partial: true, apps: [])))
      ..finish();
    await run;
    controller.dispose();
    repository.imported.complete();
    await Future<void>.delayed(Duration.zero);
    expect(updates, 0);
    expect(controller.noticeRevision, 0);
  });

  test('logout waits for helper cancellation before clearing the account', () async {
    final helper = FakeSteamHelperClient();
    final sessions = MemorySteamSessionStore()..saved = true;
    final sync = SteamLibrarySyncController(processManager: SteamProcessManager(), client: helper, sessions: sessions);
    final repository = PendingRepository();
    final controller = SteamLibraryController(sync: sync, repository: repository);
    addTearDown(controller.dispose);
    unawaited(sync.start(SteamSignInMethod.qr));
    helper.failCancel = true;
    await controller.logout();
    expect(repository.clears, 0);
    expect(sessions.forgotten, isFalse);
    expect(controller.phase, SteamCatalogPhase.signOutFailed);
    helper.failCancel = false;
    await controller.logout();
    expect(repository.clears, 1);
    expect(repository.forgotAccount, isTrue);
    expect(sessions.forgotten, isTrue);
    expect(controller.notice, SteamLibraryNotice.signedOut);
  });

  test('shared manager stops every active Steam operation', () async {
    final manager = SteamProcessManager();
    final helpers = [FakeSteamHelperClient(), FakeSteamHelperClient()];
    final List<SteamLibrarySyncController> controllers = helpers
        .map(
          (helper) =>
              SteamLibrarySyncController(processManager: manager, client: helper, sessions: MemorySteamSessionStore()),
        )
        .toList();
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
    final List<Future<void>> runs = controllers.map((controller) => controller.start(SteamSignInMethod.qr)).toList();
    await manager.stopAll();
    await Future.wait(runs);
    expect(controllers.every((controller) => !controller.busy && controller.wasCancelled), isTrue);
    expect(helpers.every((helper) => !helper.running), isTrue);
  });
}

class PendingRepository() implements IAppsRepository {
  final imported = Completer<void>();
  int imports = 0;
  int clears = 0;
  bool forgotAccount = false;

  @override
  Future<void> importSteamLibrary(SteamLibrarySnapshot snapshot) async {
    imports++;
    await imported.future;
  }

  @override
  Future<void> clearLibraryCache({bool forgetAccount = false}) async {
    clears++;
    forgotAccount = forgetAccount;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
