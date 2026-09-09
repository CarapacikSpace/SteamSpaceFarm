import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';

final RegExp _titleSymbolsPattern = RegExp(r'\s*[^\p{L}\p{N}\s]+\s*', unicode: true);

enum SortDirection() {
  ascending,
  descending;

  int apply(int comparison) => this == ascending ? comparison : -comparison;
}

enum AppSortKey() {
  name,
  playtime,
  lastPlayed,
  appId,
  remainingMarkedTime,
}

int compareLocalApps(LocalApp left, LocalApp right, {required AppSortKey key, required SortDirection direction}) {
  final int comparison = switch (key) {
    AppSortKey.name => direction.apply(_normalizedName(left.name).compareTo(_normalizedName(right.name))),
    AppSortKey.playtime => direction.apply((left.playtimeMinutes ?? 0).compareTo(right.playtimeMinutes ?? 0)),
    AppSortKey.lastPlayed => direction.apply(
      (left.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        right.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0),
      ),
    ),
    AppSortKey.appId => direction.apply(left.appId.compareTo(right.appId)),
    AppSortKey.remainingMarkedTime => _compareRemainingMarkedTime(left, right, direction),
  };
  return comparison != 0 ? comparison : left.appId.compareTo(right.appId);
}

int _compareRemainingMarkedTime(LocalApp left, LocalApp right, SortDirection direction) {
  final int? leftRemaining = _remainingMarkedMinutes(left);
  final int? rightRemaining = _remainingMarkedMinutes(right);

  if (leftRemaining != null && rightRemaining == null) {
    return -1;
  }
  if (leftRemaining == null && rightRemaining != null) {
    return 1;
  }
  if (leftRemaining != null && rightRemaining != null) {
    return direction.apply(leftRemaining.compareTo(rightRemaining));
  }
  return direction.apply((left.playtimeMinutes ?? 0).compareTo(right.playtimeMinutes ?? 0));
}

int? _remainingMarkedMinutes(LocalApp app) {
  final int currentMinutes = app.playtimeMinutes ?? 0;
  final int? stopAtMinutes = app.stopAtMinutes;
  if (stopAtMinutes == null || stopAtMinutes <= currentMinutes) {
    return null;
  }
  return stopAtMinutes - currentMinutes;
}

String _normalizedName(String name) => name.toLowerCase().trimLeft().replaceAll(_titleSymbolsPattern, '');
