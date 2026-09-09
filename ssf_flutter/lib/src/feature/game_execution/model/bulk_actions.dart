import 'package:ssf_flutter/src/feature/catalog/logic/app_sorting.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/beautiful_hours_configuration.dart';

enum BulkLaunchMode() {
  marked,
  favorites,
  allSequential,
}

enum BulkLaunchOrder() {
  name,
  playtime,
  lastPlayed,
  appId,
  remainingMarkedTime,
}

enum BulkMarkMode() {
  range,
  beautifulHours,
  clearMarks,
}

const int lowPlaytimeThresholdMinutes = 30;

Duration sequentialRunDurationFor({
  required LocalApp app,
  required Duration configuredDuration,
  required Duration lowPlaytimeDuration,
}) => (app.playtimeMinutes ?? 0) < lowPlaytimeThresholdMinutes ? lowPlaytimeDuration : configuredDuration;

final class const BulkLaunchRequest({
  required final BulkLaunchMode mode,
  required final BulkLaunchOrder order,
  required final SortDirection direction,
  final int concurrentLimit = 30,
  final int runSeconds = 60,
  final int lowPlaytimeRunSeconds = 60,
  final int delaySeconds = 10,
  final int? startAppId,
});

sealed class const BulkMarkRequest();

final class const RangeBulkMarkRequest({
  required final int minimumMinutes,
  required final int maximumMinutes,
  required final int? targetMinutes,
}) extends BulkMarkRequest;

final class const BeautifulHoursBulkMarkRequest({required final BeautifulHoursConfiguration configuration})
    extends BulkMarkRequest;

final class const ClearMarksBulkRequest() extends BulkMarkRequest;

List<LocalApp> selectBulkLaunchCandidates({
  required BulkLaunchRequest request,
  required List<LocalApp> filteredCatalogApps,
}) {
  final List<LocalApp> candidates = filteredCatalogApps.where((app) {
    return switch (request.mode) {
      BulkLaunchMode.marked => app.stopAtMinutes != null && (app.playtimeMinutes ?? 0) < app.stopAtMinutes!,
      BulkLaunchMode.favorites => app.isFavorite,
      BulkLaunchMode.allSequential => true,
    };
  }).toList()..sort((a, b) => compareLocalApps(a, b, key: request.order.sortKey, direction: request.direction));
  final int? startAppId = request.mode == BulkLaunchMode.allSequential ? request.startAppId : null;
  if (startAppId == null) {
    return candidates;
  }

  final int startIndex = candidates.indexWhere((app) => app.appId == startAppId);
  return startIndex == -1 ? const [] : candidates.sublist(startIndex);
}

extension on BulkLaunchOrder {
  AppSortKey get sortKey => switch (this) {
    BulkLaunchOrder.name => AppSortKey.name,
    BulkLaunchOrder.playtime => AppSortKey.playtime,
    BulkLaunchOrder.lastPlayed => AppSortKey.lastPlayed,
    BulkLaunchOrder.appId => AppSortKey.appId,
    BulkLaunchOrder.remainingMarkedTime => AppSortKey.remainingMarkedTime,
  };
}
