class SteamHourInfo {
  const SteamHourInfo({
    required this.appid,
    required this.name,
    required this.playtimeMinutes,
    required this.lastPlayed,
  });

  factory SteamHourInfo.fromJson(Map<String, Object?> json) => SteamHourInfo(
    appid: json['appid'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    playtimeMinutes: json['playtime_forever'] as int? ?? 0,
    lastPlayed: DateTime.fromMillisecondsSinceEpoch((json['rtime_last_played'] as int? ?? 0) * 1000, isUtc: true),
  );

  final int appid;
  final String name;
  final int playtimeMinutes;
  final DateTime lastPlayed;

  Map<String, Object?> toJson() {
    return {
      'appid': appid,
      'name': name,
      'playtime_forever': playtimeMinutes,
      'rtime_last_played': lastPlayed.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
