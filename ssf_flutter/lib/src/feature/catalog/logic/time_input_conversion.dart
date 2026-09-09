import 'package:ssf_flutter/src/feature/catalog/model/time_filter_type.dart';

abstract final class TimeInputConversion() {
  static int? toMinutes(String text, TimeFilterType unit) {
    final double? value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < 0) {
      return null;
    }
    return unit == TimeFilterType.hours ? (value * 60).round() : value.round();
  }

  static String fromMinutes(int minutes, TimeFilterType unit) => switch (unit) {
    TimeFilterType.hours => _formatHours(minutes),
    TimeFilterType.minutes => minutes.toString(),
  };

  static String? oppositeValue(String text, TimeFilterType unit) {
    final int? minutes = toMinutes(text, unit);
    if (minutes == null) {
      return null;
    }
    return switch (unit) {
      TimeFilterType.hours => minutes.toString(),
      TimeFilterType.minutes => _formatHours(minutes),
    };
  }

  static String _formatHours(int minutes) => (minutes / Duration.minutesPerHour)
      .toStringAsFixed(4)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
