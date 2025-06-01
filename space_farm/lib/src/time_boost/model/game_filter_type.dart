import 'package:flutter/widgets.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';

enum GameFilterType {
  all,
  running,
  marked,
  hidden,
  favorite;

  String localizedText(BuildContext context) => switch (this) {
    all => context.l10n.all,
    running => context.l10n.filterRunning,
    marked => context.l10n.filterMarked,
    hidden => context.l10n.filterHidden,
    favorite => context.l10n.filterFavorites,
  };
}
