import 'package:ssf_flutter/src/feature/game_execution/model/beautiful_hours_configuration.dart';

abstract final class BeautifulHours() {
  static const minimumCurrentHours = 24;
  static const graceMinutesAfterMilestone = 5;

  static bool isEligible(int currentMinutes, BeautifulHoursConfiguration configuration) =>
      currentMinutes >= minimumCurrentHours * Duration.minutesPerHour &&
      nextTargetMinutes(currentMinutes, configuration) != null;

  static double? nextTargetHours(int currentMinutes, BeautifulHoursConfiguration configuration) {
    if (_isAtMilestone(currentMinutes, configuration)) {
      return null;
    }

    for (final double hours in configuration.activeHours) {
      if ((hours * Duration.minutesPerHour).round() > currentMinutes) {
        return hours;
      }
    }
    return null;
  }

  static int? nextTargetMinutes(int currentMinutes, BeautifulHoursConfiguration configuration) {
    final double? targetHours = nextTargetHours(currentMinutes, configuration);
    return targetHours == null ? null : (targetHours * Duration.minutesPerHour).round();
  }

  static bool _isAtMilestone(int currentMinutes, BeautifulHoursConfiguration configuration) {
    for (final double hours in configuration.activeHours) {
      final int milestoneMinutes = (hours * Duration.minutesPerHour).round();
      if (currentMinutes >= milestoneMinutes && currentMinutes <= milestoneMinutes + graceMinutesAfterMilestone) {
        return true;
      }
    }
    return false;
  }
}
