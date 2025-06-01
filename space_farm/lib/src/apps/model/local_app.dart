import 'package:space_farm/src/apps/model/optional.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';

class LocalApp {
  const LocalApp({
    required this.appId,
    required this.name,
    required this.type,
    this.stopAtMinutes,
    this.isFavorite = false,
    this.reviewPercentage,
    this.logo,
    this.icon,
    this.isHidden = false,
    this.playtimeMinutes,
    this.lastPlayed,
  });

  factory LocalApp.fromJson(Map<String, Object?> json) => LocalApp(
    appId: json['appId']! as int,
    name: json['name']! as String,
    stopAtMinutes: json['stopAtMinutes'] as int?,
    isFavorite: (json['isFavorite'] as bool?) ?? false,
    type: SteamAppType.values.firstWhere((e) => e.index == (json['type']! as int)),
    reviewPercentage: json['reviewPercentage'] as int?,
    logo: json['logo'] as String?,
    icon: json['icon'] as String?,
    isHidden: (json['isHidden'] as bool?) ?? false,
    playtimeMinutes: json['playtimeMinutes'] as int?,
    lastPlayed: json['lastPlayed'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastPlayed']! as int, isUtc: true)
        : null,
  );

  final int appId;
  final String name;
  final int? stopAtMinutes;
  final bool isFavorite;

  // From SteamAppInfo
  final SteamAppType type;
  final int? reviewPercentage;
  final String? logo;
  final String? icon;
  final bool isHidden;

  // From SteamHourInfo
  final int? playtimeMinutes;
  final DateTime? lastPlayed;

  double get hours => (playtimeMinutes ?? 0) / 60;

  LocalApp copyWith({Optional<int?> stopAtMinutes = const Optional.absent(), bool? isFavorite, int? playtimeMinutes}) =>
      LocalApp(
        appId: appId,
        name: name,
        stopAtMinutes: stopAtMinutes.isPresent ? stopAtMinutes.value : this.stopAtMinutes,
        isFavorite: isFavorite ?? this.isFavorite,
        type: type,
        reviewPercentage: reviewPercentage,
        logo: logo,
        icon: icon,
        isHidden: isHidden,
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
      if (reviewPercentage != null) 'reviewPercentage': reviewPercentage,
      if (logo != null) 'logo': logo,
      if (icon != null) 'icon': icon,
      'isHidden': isHidden,
      if (playtimeMinutes != null) 'playtimeMinutes': playtimeMinutes,
      if (lastPlayed != null) 'lastPlayed': lastPlayed?.millisecondsSinceEpoch,
    };
  }

  String get headerUrl => 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/header.jpg';

  String get libraryUrl => 'https://cdn.akamai.steamstatic.com/steam/apps/$appId/library_600x900.jpg';

  String get iconUrl => 'https://cdn.akamai.steamstatic.com/steam/apps/$appId/$icon.jpg';

  String get logoUrl => logo != null && logo!.isNotEmpty
      ? _formatImageUrl(logo!)
      : 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/logo.png';

  String _formatImageUrl(String path) {
    if (path.contains('/') || path.contains('.')) {
      return path;
    }

    return 'https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/apps/$appId/$path.jpg';
  }
}

extension SortX on List<LocalApp> {
  void sortByPlaytimeTypeName() {
    sort((a, b) {
      final timeCompare = (b.playtimeMinutes ?? -1).compareTo(a.playtimeMinutes ?? -1);
      if (timeCompare != 0) {
        return timeCompare;
      }

      final typeCompare = a.type.index.compareTo(b.type.index);
      if (typeCompare != 0) {
        return typeCompare;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }
}
