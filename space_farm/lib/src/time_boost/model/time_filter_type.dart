import 'package:flutter/widgets.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';

enum TimeFilterType {
  hours,
  minutes;

  String localizedText(BuildContext context) => switch (this) {
    hours => context.l10n.filterByHours,
    minutes => context.l10n.filterByMinutes,
  };
}
