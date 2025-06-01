import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';
import 'package:space_farm/src/time_boost/model/game_filter_type.dart';
import 'package:space_farm/src/time_boost/model/sort_type.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class GameFilterController {
  const GameFilterController({
    required this.searchController,
    required this.minController,
    required this.maxController,
    required this.timeFilterType,
    required this.gameFilterType,
    required this.selectedTypes,
    required this.sortType,
    required this.launchedAppIds,
  });

  final TextEditingController searchController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final TimeFilterType timeFilterType;
  final GameFilterType gameFilterType;
  final Set<SteamAppType> selectedTypes;
  final SortType sortType;
  final Set<int> launchedAppIds;

  List<LocalApp> apply(List<LocalApp> apps) {
    final query = searchController.text.trim().toLowerCase();
    final extractedAppId = _extractAppId(query);
    final min = int.tryParse(minController.text.trim());
    final max = int.tryParse(maxController.text.trim());

    final filtered =
        apps.where((a) {
          final matchName = a.name.toLowerCase().contains(query);
          final matchId = extractedAppId != null && a.appId == extractedAppId;

          final playtime = a.playtimeMinutes ?? -1;
          final playtimeInUnits = timeFilterType == TimeFilterType.hours ? playtime / 60 : playtime;
          final minOk = min == null || playtimeInUnits >= min;
          final maxOk = max == null || playtimeInUnits < max;

          final matchCategory = selectedTypes.contains(a.type);

          final matchFilter = switch (gameFilterType) {
            GameFilterType.all => true,
            GameFilterType.running => launchedAppIds.contains(a.appId),
            GameFilterType.marked => a.stopAtMinutes != null && (a.playtimeMinutes ?? 0) < a.stopAtMinutes!,
            GameFilterType.hidden => a.isHidden,
            GameFilterType.favorite => a.isFavorite,
          };

          return (matchName || matchId) && minOk && maxOk && matchCategory && matchFilter;
        }).toList()..sort(
          (a, b) => switch (sortType) {
            SortType.playtime => (b.playtimeMinutes ?? 0).compareTo(a.playtimeMinutes ?? 0),
            SortType.name => _stripLeadingArticle(a.name).compareTo(_stripLeadingArticle(b.name)),
            SortType.lastPlayed => (b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
              a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
          },
        );

    return filtered;
  }

  String _stripLeadingArticle(String name) {
    final lower = name.toLowerCase().trim();
    final cleaned = lower.replaceFirst(RegExp(r'^(a|an|the)\s+', caseSensitive: false), '');

    return cleaned;
  }

  int? _extractAppId(String input) {
    final regex = RegExp(r'(\d+)(?:/|$)');
    final uriPattern = RegExp(r'(steamcommunity\.com|store\.steampowered\.com)/app/(\d+)');

    final match = uriPattern.firstMatch(input);
    if (match != null) {
      return int.tryParse(match.group(2)!);
    }

    final numberMatch = regex.firstMatch(input);
    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(1)!);
    }

    return null;
  }
}
