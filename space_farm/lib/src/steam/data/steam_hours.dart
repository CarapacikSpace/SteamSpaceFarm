import 'dart:convert' show json, utf8;

import 'package:http/http.dart' as http;
import 'package:space_farm/src/steam/model/steam_hour_info.dart';

class SteamHoursService {
  SteamHoursService();

  Future<List<SteamHourInfo>> getOwnedGames(String apiKey, String steamId) async {
    final uri = Uri.parse(
      'https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?'
      'key=$apiKey&steamid=$steamId&include_appinfo=1&include_played_free_games=1',
    );
    final client = http.Client();
    try {
      final response = await client.get(uri);
      if (response.statusCode == 429) {
        throw Exception('Steam API: Rate limit exceeded. Please wait a few minutes before sending another request.');
      } else if (response.statusCode >= 400) {
        throw Exception('Steam API: HTTP error ${response.statusCode}');
      }

      final decodedResponse = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final result = ((decodedResponse['response'] as Map<String, dynamic>?)?['games'] ?? <dynamic>[]) as List<dynamic>;

      return result.map((e) => SteamHourInfo.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    } finally {
      client.close();
    }
  }

  Future<List<SteamHourInfo>> getRecentlyPlayedGames(String apiKey, String steamId) async {
    final uri = Uri.parse(
      'https://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v1/?'
      'key=$apiKey&steamid=$steamId&include_appinfo=1&include_played_free_games=1',
    );
    final client = http.Client();
    try {
      final response = await client.get(uri);
      if (response.statusCode == 429) {
        throw Exception('Steam API: Rate limit exceeded. Please wait a few minutes before sending another request.');
      } else if (response.statusCode >= 400) {
        throw Exception('Steam API: HTTP error ${response.statusCode}');
      }

      final decodedResponse = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final result = ((decodedResponse['response'] as Map<String, dynamic>?)?['games'] ?? <dynamic>[]) as List<dynamic>;

      return result.map((e) => SteamHourInfo.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    } finally {
      client.close();
    }
  }
}
