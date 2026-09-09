import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/catalog/logic/app_sorting.dart';
import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

SteamLibrarySnapshot refresh({
  String personal = 'complete',
  String family = 'complete',
  String? ownership,
  Object? lastPlayed = 1780000000,
  bool missing = false,
}) => SteamLibrarySnapshot.fromJson({
  'schemaVersion': 1,
  'steamId': '76561198000000001',
  'partial': true,
  'sources': {
    'personalLicenses': {'status': personal},
    'family': {'status': family},
  },
  'apps': [
    if (!missing) {'appId': 480, 'name': 'Example', 'ownership': ownership, 'lastPlayedAtUnixSeconds': lastPlayed},
  ],
});

LocalApp cached(LibraryOwnership ownership, {bool manual = false}) => LocalApp(
  appId: 480,
  name: 'Example',
  type: SteamAppType.game,
  libraryOwnership: ownership,
  isLibraryOwnershipManual: manual,
  playtimeMinutes: 120,
  isFavorite: true,
  lastPlayed: DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true),
);

void main() {
  setUp(() => GeneratedLocalizations.load(const Locale('ru')));
  test('last played is UTC, persists and drives chronological ordering', () {
    final LocalApp old = cached(LibraryOwnership.personal);
    final LocalApp updated = refresh(ownership: 'personal').merge([old]).single;
    expect(updated.lastPlayed!.isUtc, isTrue);
    expect(updated.lastPlayed!.millisecondsSinceEpoch, 1780000000000);
    expect(LocalApp.fromJson(updated.toJson()).lastPlayed, updated.lastPlayed);
    expect(compareLocalApps(old, updated, key: AppSortKey.lastPlayed, direction: SortDirection.ascending), lessThan(0));
    expect(
      compareLocalApps(old, updated, key: AppSortKey.lastPlayed, direction: SortDirection.descending),
      greaterThan(0),
    );
    for (final Object? unavailable in [null, 0]) {
      expect(refresh(lastPlayed: unavailable).merge([old]).single.lastPlayed, old.lastPlayed);
    }
    for (final Object invalid in [-1, 4294967296, 1.5, 'yesterday']) {
      expect(() => refresh(lastPlayed: invalid), throwsFormatException);
    }
  });

  for (final missing in [false, true]) {
    test('confirmed access loss clears ownership, preserves app and user data (missing=$missing)', () {
      for (final LibraryOwnership ownership in [LibraryOwnership.personal, LibraryOwnership.family]) {
        final LocalApp updated = refresh(missing: missing).merge([cached(ownership)]).single;
        expect(updated.libraryOwnership, LibraryOwnership.unknown);
        expect(updated.isFavorite, isTrue);
        expect(updated.playtimeMinutes, 120);
      }
    });
    test('failed ownership source preserves previous evidence (missing=$missing)', () {
      expect(
        refresh(family: 'failed', missing: missing).merge([cached(LibraryOwnership.family)]).single.libraryOwnership,
        LibraryOwnership.family,
      );
      expect(
        refresh(
          personal: 'partial',
          missing: missing,
        ).merge([cached(LibraryOwnership.personal)]).single.libraryOwnership,
        LibraryOwnership.personal,
      );
      expect(
        refresh(family: 'failed', missing: missing).merge([cached(LibraryOwnership.personal)]).single.libraryOwnership,
        LibraryOwnership.personal,
      );
      expect(
        refresh(missing: missing).merge([cached(LibraryOwnership.family, manual: true)]).single.libraryOwnership,
        LibraryOwnership.family,
      );
    });
  }

  test('positive evidence wins but failed personal source cannot downgrade personal to family', () {
    expect(
      refresh(ownership: 'personal', family: 'failed').merge([cached(LibraryOwnership.family)]).single.libraryOwnership,
      LibraryOwnership.personal,
    );
    expect(
      refresh(ownership: 'family').merge([cached(LibraryOwnership.personal)]).single.libraryOwnership,
      LibraryOwnership.family,
    );
    expect(
      refresh(
        ownership: 'family',
        personal: 'partial',
      ).merge([cached(LibraryOwnership.personal)]).single.libraryOwnership,
      LibraryOwnership.personal,
    );
  });
}
