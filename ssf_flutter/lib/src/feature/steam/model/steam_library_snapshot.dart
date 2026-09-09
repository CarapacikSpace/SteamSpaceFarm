import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';

class const SteamLibrarySnapshot({
  required final String steamId,
  required final bool partial,
  required final List<LocalApp> apps,
  final bool personalOwnershipComplete = false,
  final bool familyOwnershipComplete = false,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final Object? id = json['steamId'];
    if (json['schemaVersion'] != 1 || id is! String || !RegExp(r'^7656119[0-9]{10}$').hasMatch(id)) {
      throw const FormatException('Invalid library account');
    }
    final apps = <LocalApp>[];
    final ids = <int>{};
    for (final dynamic item in json['apps'] as List<dynamic>) {
      final entry = item as Map<String, dynamic>;
      final appId = entry['appId'] as int;
      final hours = entry['hours'] as num?;
      if (appId <= 0 ||
          appId > 0xFFFFFFFF ||
          !ids.add(appId) ||
          (hours != null && (!hours.isFinite || hours < 0 || hours > 100000000))) {
        throw const FormatException('Invalid library entry');
      }
      final LibraryOwnership ownership = switch (entry['ownership']) {
        'personal' => LibraryOwnership.personal,
        'family' => LibraryOwnership.family,
        null => LibraryOwnership.unknown,
        _ => throw const FormatException('Invalid ownership'),
      };
      final String? name = (entry['name'] as String?)?.trim();
      final Object? timestamp = entry['lastPlayedAtUnixSeconds'];
      if (timestamp != null && (timestamp is! int || timestamp < 0 || timestamp > 4294967295)) {
        throw const FormatException('Invalid last played timestamp');
      }
      apps.add(
        LocalApp(
          appId: appId,
          name: name == null || name.isEmpty ? 'App $appId' : name,
          type: SteamAppType.fromString(entry['type'] as String?),
          libraryOwnership: ownership,
          playtimeMinutes: hours == null ? null : (hours * 60).round(),
          lastPlayed: timestamp is int && timestamp > 0
              ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
              : null,
        ),
      );
    }
    final sources = json['sources'] as Map<String, dynamic>?;
    final familyComplete = (sources?['family'] as Map<String, dynamic>?)?['status'] == 'complete';
    return SteamLibrarySnapshot(
      steamId: id,
      partial: json['partial'] as bool,
      apps: apps,
      personalOwnershipComplete:
          (sources?['personalLicenses'] as Map<String, dynamic>?)?['status'] == 'complete' && familyComplete,
      familyOwnershipComplete: familyComplete,
    );
  }

  List<LocalApp> merge(List<LocalApp> cached) {
    final Set<int> returnedIds = apps.map((app) => app.appId).toSet();
    final Map<int, LocalApp> byId = {
      for (final app in cached)
        app.appId: returnedIds.contains(app.appId)
            ? app
            : app.copyWith(libraryOwnership: _mergeOwnership(app, LibraryOwnership.unknown)),
    };
    for (final LocalApp app in apps) {
      final LocalApp? old = byId[app.appId];
      byId[app.appId] = LocalApp(
        appId: app.appId,
        name: app.name == 'App ${app.appId}' ? old?.name ?? app.name : app.name,
        type: app.type == SteamAppType.other ? old?.type ?? app.type : app.type,
        libraryOwnership: _mergeOwnership(old, app.libraryOwnership),
        isLibraryOwnershipManual: old?.isLibraryOwnershipManual ?? false,
        playtimeMinutes: app.playtimeMinutes ?? old?.playtimeMinutes,
        stopAtMinutes: old?.stopAtMinutes,
        isFavorite: old?.isFavorite ?? false,
        isHidden: old?.isHidden ?? false,
        icon: old?.icon,
        lastPlayed: app.lastPlayed ?? old?.lastPlayed,
      );
    }
    return byId.values.toList();
  }

  LibraryOwnership _mergeOwnership(LocalApp? old, LibraryOwnership incoming) {
    if (old == null) {
      return incoming;
    }
    if (old.isLibraryOwnershipManual) {
      return old.libraryOwnership;
    }
    if (incoming == LibraryOwnership.personal) {
      return incoming;
    }
    if (old.libraryOwnership == LibraryOwnership.personal && !personalOwnershipComplete) {
      return LibraryOwnership.personal;
    }
    if (incoming == LibraryOwnership.family) {
      return incoming;
    }
    if (old.libraryOwnership == LibraryOwnership.family && !familyOwnershipComplete) {
      return LibraryOwnership.family;
    }
    return LibraryOwnership.unknown;
  }
}
