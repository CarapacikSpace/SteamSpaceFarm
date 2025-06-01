class SteamUser {
  const SteamUser({required this.login, required this.steamId, required this.steam3Id});

  factory SteamUser.fromJson(Map<String, dynamic> json) => SteamUser(
    login: json['login'] as String? ?? '',
    steamId: int.tryParse(json['steamId'].toString()) ?? 0,
    steam3Id: json['steam3Id'] as String? ?? '',
  );

  final String login;
  final int steamId;
  final String steam3Id;

  Map<String, Object?> toJson() => {'login': login, 'steamId': steamId, 'steam3Id': steam3Id};
}
