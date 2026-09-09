import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_execution_controller.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_launcher.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

class const GameExecutionPanel({
  required final GameExecutionController controller,
  required final VoidCallback onTogglePause,
  required final VoidCallback onStopQueue,
  required final VoidCallback onStopManual,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (controller.runningCount == 0 && !controller.isQueueActive) {
      return const SizedBox.shrink();
    }

    final String queueLabel = switch ((controller.isSequentialActive, controller.batchMode)) {
      (true, _) => GeneratedLocalizations.of(context).sequentialQueue,
      (_, BatchLaunchMode.marked) => GeneratedLocalizations.of(context).marked,
      (_, BatchLaunchMode.favorites) => GeneratedLocalizations.of(context).favorites,
      _ => GeneratedLocalizations.of(context).manualLaunch,
    };
    final String? currentName = controller.currentSequentialApp?.name;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF172A3C),
        border: Border.all(color: const Color(0xFF2D526D)),
        borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Widget summary = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: controller.isQueuePaused ? const Color(0xFFE5A94D) : const Color(0xFF75B022),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.isQueuePaused
                          ? GeneratedLocalizations.of(context).queuePausedLabel(queueLabel)
                          : queueLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _details(controller, currentName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFA9B6C6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
          final Widget actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (controller.isQueueActive)
                SteamButton(
                  height: SteamUiMetrics.catalogControlHeight,
                  onPressed: controller.isBusy ? null : onTogglePause,
                  icon: Icon(controller.isQueuePaused ? Icons.play_arrow : Icons.pause),
                  child: Text(
                    controller.isQueuePaused
                        ? GeneratedLocalizations.of(context).resume
                        : GeneratedLocalizations.of(context).pause,
                  ),
                ),
              if (controller.isQueueActive)
                SteamButton(
                  height: SteamUiMetrics.catalogControlHeight,
                  onPressed: controller.isBusy ? null : onStopQueue,
                  icon: const Icon(Icons.stop),
                  child: Text(GeneratedLocalizations.of(context).stopQueue),
                ),
              if (controller.manualRunningCount > 0)
                SteamButton(
                  height: SteamUiMetrics.catalogControlHeight,
                  onPressed: controller.isBusy ? null : onStopManual,
                  icon: const Icon(Icons.stop),
                  child: Text(GeneratedLocalizations.of(context).stopManualAppsCount(controller.manualRunningCount)),
                ),
            ],
          );

          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [summary, const SizedBox(height: 12), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth * .75),
                child: actions,
              ),
            ],
          );
        },
      ),
    );
  }

  static String _details(GameExecutionController controller, String? currentName) {
    final parts = <String>[
      GeneratedLocalizations.current.runningAppsCount(controller.runningCount, controller.concurrentLimit),
      GeneratedLocalizations.current.automaticAppsCount(controller.automaticRunningCount),
      GeneratedLocalizations.current.manualAppsCount(controller.manualRunningCount),
    ];
    if (controller.isQueueActive) {
      parts.add(GeneratedLocalizations.current.queuedAppsCount(controller.queuedCount));
    }
    if (currentName != null) {
      parts.add(GeneratedLocalizations.current.currentAppLabel(currentName));
    }
    return parts.join(' · ');
  }
}
