import 'package:flutter/widgets.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';

enum SortType {
  playtime,
  name,
  lastPlayed;

  String localizedText(BuildContext context) => switch (this) {
    playtime => context.l10n.sortByTime,
    name => context.l10n.sortAlphabetically,
    lastPlayed => context.l10n.sortByLaunchDate,
  };
}
