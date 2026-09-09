import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/utils/optional.dart';

class const LocalApp({
  required final int appId,
  required final String name,
  required final SteamAppType type,
  final int? stopAtMinutes,
  final bool isFavorite = false,
  final String? icon,
  final bool isHidden = false,
  final LibraryOwnership libraryOwnership = LibraryOwnership.unknown,
  final bool isLibraryOwnershipManual = false,
  final int? playtimeMinutes,
  final DateTime? lastPlayed,
}) {
  factory fromJson(Map<String, Object?> json) => LocalApp(
    appId: json['appId']! as int,
    name: json['name']! as String,
    stopAtMinutes: json['stopAtMinutes'] as int?,
    isFavorite: (json['isFavorite'] as bool?) ?? false,
    type: SteamAppType.values.firstWhere((e) => e.index == (json['type']! as int)),
    icon: json['icon'] as String?,
    isHidden: (json['isHidden'] as bool?) ?? false,
    libraryOwnership: _parseLibraryOwnership(json['libraryOwnership']),
    isLibraryOwnershipManual: (json['isLibraryOwnershipManual'] as bool?) ?? false,
    playtimeMinutes: json['playtimeMinutes'] as int?,
    lastPlayed: json['lastPlayed'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastPlayed']! as int, isUtc: true)
        : null,
  );

  LocalApp copyWith({
    Optional<int?> stopAtMinutes = const Optional.absent(),
    bool? isFavorite,
    int? playtimeMinutes,
    LibraryOwnership? libraryOwnership,
    bool? isLibraryOwnershipManual,
  }) => LocalApp(
    appId: appId,
    name: name,
    stopAtMinutes: stopAtMinutes.isPresent ? stopAtMinutes.value : this.stopAtMinutes,
    isFavorite: isFavorite ?? this.isFavorite,
    type: type,
    icon: icon,
    isHidden: isHidden,
    libraryOwnership: libraryOwnership ?? this.libraryOwnership,
    isLibraryOwnershipManual: isLibraryOwnershipManual ?? this.isLibraryOwnershipManual,
    playtimeMinutes: playtimeMinutes ?? this.playtimeMinutes,
    lastPlayed: lastPlayed,
  );

  Map<String, Object?> toJson() {
    return {
      'appId': appId,
      'name': name,
      if (stopAtMinutes != null) 'stopAtMinutes': stopAtMinutes,
      'isFavorite': isFavorite,
      'type': type.index,
      if (icon != null) 'icon': icon,
      'isHidden': isHidden,
      'libraryOwnership': libraryOwnership.name,
      'isLibraryOwnershipManual': isLibraryOwnershipManual,
      if (playtimeMinutes != null) 'playtimeMinutes': playtimeMinutes,
      if (lastPlayed != null) 'lastPlayed': lastPlayed?.millisecondsSinceEpoch,
    };
  }

  String get libraryCapsuleUrl =>
      'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/library_600x900.jpg';

  String get mainCapsuleUrl =>
      'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/capsule_616x353.jpg';

  String get storeHeaderUrl => 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/header.jpg';

  String? get appIconUrl => icon == null || icon!.isEmpty ? null : _formatImageUrl(icon!);

  List<String> get libraryCapsuleImageUrls => [libraryCapsuleUrl, mainCapsuleUrl, storeHeaderUrl];

  List<String> get mainCapsuleImageUrls => [mainCapsuleUrl, storeHeaderUrl];

  List<String> get storeHeaderImageUrls => [storeHeaderUrl];

  List<String> get appIconImageUrls => [if (appIconUrl case final String url) url];

  String _formatImageUrl(String path) {
    if (path.contains('/') || path.contains('.')) {
      return path;
    }

    return 'https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/apps/$appId/$path.jpg';
  }
}

LibraryOwnership _parseLibraryOwnership(Object? value) {
  if (value case final String name) {
    for (final LibraryOwnership ownership in LibraryOwnership.values) {
      if (ownership.name == name) {
        return ownership;
      }
    }
  }
  return LibraryOwnership.unknown;
}

extension SortX on List<LocalApp> {
  void sortByPlaytimeTypeName() {
    sort((a, b) {
      final int timeCompare = (b.playtimeMinutes ?? -1).compareTo(a.playtimeMinutes ?? -1);
      if (timeCompare != 0) {
        return timeCompare;
      }

      final int typeCompare = a.type.index.compareTo(b.type.index);
      if (typeCompare != 0) {
        return typeCompare;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }
}
