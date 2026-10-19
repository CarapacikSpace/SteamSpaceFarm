import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/steam/data/steam_session_store.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

const account = '76561198000000001';
const anotherAccount = '76561198000000002';

SteamLibrarySnapshot snapshot({
  String steamId = account,
  num? hours = 2.5,
  String? ownership = 'personal',
  String? name = 'Synthetic',
}) => SteamLibrarySnapshot.fromJson({
  'schemaVersion': 1,
  'steamId': steamId,
  'partial': true,
  'apps': [
    {'appId': 480, 'name': name, 'hours': hours, 'ownership': ownership, 'type': 'game'},
  ],
});

void main() {
  setUp(() => GeneratedLocalizations.delegate.load(const Locale('ru')));
  late Directory directory;
  late AppsRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ssf-library-test-');
    repository = AppsRepository(libraryDirectory: directory);
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  for (final malformed in ['{broken', '{"schemaVersion":1,"apps":[{"type":999}]}']) {
    test('corrupt catalog can be cleared and imported: $malformed', () async {
      final file = File(p.join(directory.path, 'catalog.json'));
      await file.writeAsString(malformed);
      await repository.clearLibraryCache();
      expect(await repository.getAppsFromCache(), isEmpty);
      final Iterable<File> backups = directory.listSync().whereType<File>().where((f) => f.path.contains('.corrupt-'));
      expect(backups, hasLength(1));
      expect(await backups.single.readAsString(), malformed);
      await file.writeAsString(malformed);
      await repository.importSteamLibrary(snapshot());
      expect((await repository.getAppsFromCache()).single.appId, 480);
      await file.writeAsString(malformed);
      await repository.clearLibraryCache(forgetAccount: true);
      expect(await repository.getCatalogSteamId(), isNull);
    });
  }

  test('imports names, minutes and nullable ownership without an API key', () async {
    await repository.importSteamLibrary(snapshot(ownership: null));
    final LocalApp app = (await repository.getAppsFromCache()).single;
    expect(app.name, 'Synthetic');
    expect(app.playtimeMinutes, 150);
    expect(app.type, SteamAppType.game);
    expect(app.libraryOwnership, LibraryOwnership.unknown);
    expect(await repository.getCatalogSteamId(), account);
  });

  test('refresh replaces artwork while partial metadata and user edits preserve it', () async {
    SteamLibrarySnapshot artworkSnapshot(String revision) => SteamLibrarySnapshot.fromJson({
      'schemaVersion': 1,
      'steamId': account,
      'partial': false,
      'apps': [
        {
          'appId': 480,
          'name': 'Synthetic',
          'type': 'game',
          'storeHeaderImage':
              'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/480/$revision/header.jpg',
          'libraryCapsuleImage':
              'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/480/$revision/library_capsule_2x.jpg',
        },
      ],
    });

    await repository.importSteamLibrary(snapshot());
    final LocalApp legacy = (await repository.getAppsFromCache()).single;
    expect(legacy.storeHeaderUrl, endsWith('/480/header.jpg'));
    expect(legacy.libraryCapsuleUrl, endsWith('/480/library_600x900.jpg'));
    await repository.importSteamLibrary(artworkSnapshot('first'));
    await repository.importSteamLibrary(artworkSnapshot('second'));
    final LocalApp current = (await repository.getAppsFromCache()).single;
    expect(current.storeHeaderImageUrls.first, contains('/second/header.jpg'));
    expect(current.libraryCapsuleImageUrls.first, contains('/second/library_capsule_2x.jpg'));
    expect(current.storeHeaderImageUrls.last, legacy.storeHeaderUrl);
    expect(current.libraryCapsuleImageUrls, contains(legacy.libraryCapsuleUrl));
    await repository.updateApp(current.copyWith(isFavorite: true, playtimeMinutes: 200));
    await repository.importSteamLibrary(snapshot(hours: null));
    final LocalApp retained = (await repository.getAppsFromCache()).single;
    expect(retained.storeHeaderImage, current.storeHeaderImage);
    expect(retained.libraryCapsuleImage, current.libraryCapsuleImage);
    expect(retained.isFavorite, isTrue);
  });

  test('only catalog.json is used and unrelated old files remain untouched', () async {
    final oldFile = File(p.join(directory.path, 'apps.json'));
    await oldFile.writeAsString('obsolete format');
    expect(await repository.getAppsFromCache(), isEmpty);
    expect(await repository.getCatalogSteamId(), isNull);
    await repository.importSteamLibrary(snapshot());
    expect(await File(p.join(directory.path, 'catalog.json')).readAsString(), contains('\n  "schemaVersion"'));
    await repository.clearLibraryCache(forgetAccount: true);
    expect(await oldFile.readAsString(), 'obsolete format');
  });

  test('partial refresh retains user edits and missing hours, but accepts actual zero', () async {
    await repository.importSteamLibrary(snapshot());
    final LocalApp app = (await repository.getAppsFromCache()).single;
    await repository.updateApp(app.copyWith(isFavorite: true));
    await repository.importSteamLibrary(snapshot(hours: null, name: null, ownership: null));
    final LocalApp updated = (await repository.getAppsFromCache()).single;
    expect(updated.playtimeMinutes, 150);
    expect(updated.name, 'Synthetic');
    expect(updated.isFavorite, isTrue);
    expect(updated.libraryOwnership, LibraryOwnership.personal);
    await repository.importSteamLibrary(snapshot(hours: 0));
    expect((await repository.getAppsFromCache()).single.playtimeMinutes, 0);
  });

  test('account switch never inherits hours or favorites', () async {
    await repository.importSteamLibrary(snapshot());
    await repository.updateApp((await repository.getAppsFromCache()).single.copyWith(isFavorite: true));
    await repository.importSteamLibrary(snapshot(steamId: anotherAccount, hours: null));
    final LocalApp app = (await repository.getAppsFromCache()).single;
    expect(app.playtimeMinutes, isNull);
    expect(app.isFavorite, isFalse);
    expect(await repository.getCatalogSteamId(), anotherAccount);
  });

  test('clear empties the catalog, logout also removes account metadata', () async {
    await repository.importSteamLibrary(snapshot());
    await repository.clearLibraryCache();
    expect(await repository.getAppsFromCache(), isEmpty);
    expect(await repository.getCatalogSteamId(), account);
    await repository.importSteamLibrary(snapshot());
    await repository.clearLibraryCache(forgetAccount: true);
    expect(await repository.getAppsFromCache(), isEmpty);
    expect(await repository.getCatalogSteamId(), isNull);
  });

  test('invalid Steam account and duplicate app IDs are rejected', () {
    expect(() => snapshot(steamId: '../foreign'), throwsFormatException);
    expect(() => snapshot(hours: -1), throwsFormatException);
    expect(() => snapshot(ownership: 'borrowed'), throwsFormatException);
    expect(
      () => SteamLibrarySnapshot.fromJson({
        'schemaVersion': 1,
        'steamId': account,
        'partial': false,
        'apps': [
          {'appId': 1},
          {'appId': 1},
        ],
      }),
      throwsFormatException,
    );
  });

  test('one active session is forgotten without deleting unrelated files', () async {
    final session = File('${directory.path}/session.dpapi');
    await session.writeAsString('fake encrypted bytes');
    final marker = File('${directory.path}/unrelated.txt');
    await marker.writeAsString('keep');
    final sessions = SteamSessionStore(directory: directory);
    expect(await sessions.exists(), isTrue);
    final auth = SteamLibrarySyncController(processManager: SteamProcessManager(), sessions: sessions);
    await auth.forgetSessions();
    auth.dispose();
    expect(session.existsSync(), isFalse);
    expect(marker.existsSync(), isTrue);
    expect(await sessions.exists(), isFalse);
  });
}
