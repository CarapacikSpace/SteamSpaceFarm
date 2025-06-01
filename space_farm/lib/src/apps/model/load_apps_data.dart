class LoadAppsData {
  const LoadAppsData({required this.login, required this.password, required this.apiKey, required this.steamId});

  factory LoadAppsData.fromJson(Map<String, Object?> json) => LoadAppsData(
    login: json['login'] as String? ?? '',
    password: json['password'] as String? ?? '',
    apiKey: json['apiKey'] as String? ?? '',
    steamId: json['steamId'] as String? ?? '',
  );

  final String login;
  final String password;
  final String apiKey;
  final String steamId;

  bool validateAllGames() {
    final isValidLogin = login.isNotEmpty;
    final isValidPassword = password.isNotEmpty;
    final isValidApiKey = apiKey.isNotEmpty;
    final result = isValidLogin && isValidPassword && isValidApiKey;

    return result;
  }

  bool validateGames() {
    final isValidApiKey = apiKey.isNotEmpty;
    final isValidSteamId = steamId.isNotEmpty;

    return isValidApiKey && isValidSteamId;
  }

  Map<String, Object?> toJson({bool saveLoginAndPassword = true}) => {
    if (saveLoginAndPassword) 'login': login,
    if (saveLoginAndPassword) 'password': password,
    'apiKey': apiKey,
    'steamId': steamId,
  };
}
