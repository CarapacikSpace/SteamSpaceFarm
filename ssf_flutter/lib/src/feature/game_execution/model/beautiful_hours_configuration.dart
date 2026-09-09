import 'package:flutter/foundation.dart';

@immutable
final class const BeautifulHoursConfiguration._({
  required final List<double> hours,
  required final int minimumHours,
  required final int maximumHours,
}) {
  factory fromInput({required String hoursText, required int minimumHours, required int maximumHours}) {
    final bool usesSemicolonSeparator = hoursText.contains(';');
    final separator = usesSemicolonSeparator ? ';' : ',';
    final List<String> values = hoursText.split(separator).map((value) => value.trim()).toList(growable: false);
    if (values.isEmpty || values.any((value) => value.isEmpty)) {
      throw const FormatException('Beautiful hours must be a comma-separated list.');
    }

    final parsedHours = <double>[];
    for (final value in values) {
      final String normalizedValue = usesSemicolonSeparator ? value.replaceAll(',', '.') : value;
      final double? hours = double.tryParse(normalizedValue);
      if (hours == null || hours <= 0) {
        throw const FormatException('Beautiful hours must contain only positive numbers.');
      }
      final int targetMinutes = (hours * Duration.minutesPerHour).round();
      if ((hours * Duration.minutesPerHour - targetMinutes).abs() > 0.000001) {
        throw const FormatException('Beautiful hours must resolve to whole minutes.');
      }
      parsedHours.add(targetMinutes / Duration.minutesPerHour);
    }

    return BeautifulHoursConfiguration.normalized(
      hours: parsedHours,
      minimumHours: minimumHours,
      maximumHours: maximumHours,
    );
  }

  factory normalized({required Iterable<num> hours, required int minimumHours, required int maximumHours}) {
    if (minimumHours <= 0 || maximumHours < minimumHours) {
      throw const FormatException('The beautiful-hours range is invalid.');
    }

    final normalizedHours = <double>{};
    for (final value in hours) {
      final double hours = value.toDouble();
      final int targetMinutes = (hours * Duration.minutesPerHour).round();
      if (hours <= 0 || (hours * Duration.minutesPerHour - targetMinutes).abs() > 0.000001) {
        throw const FormatException('Beautiful hours must resolve to positive whole minutes.');
      }
      normalizedHours.add(targetMinutes / Duration.minutesPerHour);
    }
    final List<double> sortedHours = normalizedHours.toList()..sort();
    if (sortedHours.isEmpty || !sortedHours.any((hours) => hours >= minimumHours && hours <= maximumHours)) {
      throw const FormatException('The range must contain at least one beautiful hour.');
    }

    return BeautifulHoursConfiguration._(
      hours: List<double>.unmodifiable(sortedHours),
      minimumHours: minimumHours,
      maximumHours: maximumHours,
    );
  }

  static const defaultHours = <double>[
    25.5,
    30,
    50,
    66,
    77,
    100,
    111,
    150,
    200,
    222,
    250,
    300,
    333,
    350,
    400,
    444,
    500,
  ];
  static const defaultMinimumHours = 24;
  static const defaultMaximumHours = 500;

  static const defaults = BeautifulHoursConfiguration._(
    hours: defaultHours,
    minimumHours: defaultMinimumHours,
    maximumHours: defaultMaximumHours,
  );

  List<double> get activeHours =>
      hours.where((hours) => hours >= minimumHours && hours <= maximumHours).toList(growable: false);

  String formatHoursText({String decimalSeparator = '.', String valueSeparator = ', '}) =>
      hours.map((hours) => _formatHours(hours).replaceAll('.', decimalSeparator)).join(valueSeparator);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeautifulHoursConfiguration &&
          listEquals(other.hours, hours) &&
          other.minimumHours == minimumHours &&
          other.maximumHours == maximumHours;

  @override
  int get hashCode => Object.hash(Object.hashAll(hours), minimumHours, maximumHours);

  @override
  String toString() =>
      'BeautifulHoursConfiguration(hours: $hours, minimumHours: $minimumHours, maximumHours: $maximumHours)';
}

String _formatHours(double hours) => hours == hours.truncateToDouble() ? hours.toInt().toString() : hours.toString();
