import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/session_work_queue.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

class const CardFarmingActions({required final SessionWorkQueue work, required final bool disabled, super.key})
    extends StatelessWidget {
  List<LocalApp> get candidates => work.drops.values
      .where((game) => (game.remaining ?? 0) > 0)
      .map((game) => work.appById(game.appId) ?? LocalApp(appId: game.appId, name: game.name, type: SteamAppType.game))
      .toList();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: work,
    builder: (context, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Tooltip(
            message: context.l10n.cardsRefresh,
            child: SteamButton(
              height: 36,
              onPressed: disabled || work.loading || work.active ? null : () => unawaited(_refresh(context)),
              icon: work.loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.style_outlined, size: 18),
              child: Text(
                work.checkedAt == null
                    ? context.l10n.cardsRefresh
                    : work.remaining == 0
                    ? context.l10n.cardsEmpty
                    : context.l10n.cardsCount(work.remaining),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: context.l10n.cardsStart,
          child: SteamButton(
            height: 36,
            variant: SteamButtonVariant.run,
            compact: true,
            iconOnly: true,
            onPressed: disabled || work.loading || candidates.isEmpty || work.active
                ? null
                : () => unawaited(work.start(candidates)),
            icon: const Icon(Icons.play_arrow),
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    ),
  );

  Future<void> _refresh(BuildContext context) async {
    try {
      await work.refresh();
    } on Object {
      if (context.mounted) {
        showSteamNotice(context, context.l10n.cardsFailed);
      }
    }
  }
}

String workPhaseLabel(BuildContext context, WorkPhase phase) => switch (phase) {
  WorkPhase.idle => context.l10n.cardsTitle,
  WorkPhase.preparing => context.l10n.workPreparing,
  WorkPhase.group => context.l10n.workGroup,
  WorkPhase.single => context.l10n.workSingle,
  WorkPhase.checking => context.l10n.workChecking,
  WorkPhase.waiting => context.l10n.workWaiting,
  WorkPhase.syncing => context.l10n.workSyncing,
};
