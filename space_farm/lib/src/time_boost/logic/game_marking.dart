import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/model/optional.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/shared/elevated_button.dart';
import 'package:space_farm/src/shared/filled_button.dart';
import 'package:space_farm/src/shared/snackbar.dart';
import 'package:space_farm/src/shared/text_field.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class GameMarking {
  const GameMarking({required this.appsRepository});

  final IAppsRepository appsRepository;

  Future<void> markBatchCandidates({
    required BuildContext context,
    required List<LocalApp> apps,
    required int min,
    required int max,
    required void Function(LocalApp) onUpdateApp,
    required TimeFilterType timeFilterType,
    int? target,
  }) async {
    final minInUnits = timeFilterType == TimeFilterType.hours ? min * 60 : min;
    final maxInUnits = timeFilterType == TimeFilterType.hours ? max * 60 : max;
    final eligibleApps = apps.where((app) {
      final minutes = app.playtimeMinutes ?? 0;
      return minutes >= minInUnits && minutes < maxInUnits;
    }).toList();

    final updatedApps = <LocalApp>[];
    for (final app in eligibleApps) {
      final current = app.playtimeMinutes ?? 0;
      final targetInUnits = target != null && timeFilterType == TimeFilterType.hours ? target * 60 : target;
      final targetCorrect = targetInUnits ?? maxInUnits;
      final stopAtMinutes = current >= targetCorrect ? null : targetCorrect;
      updatedApps.add(app.copyWith(stopAtMinutes: Optional.of(stopAtMinutes)));
    }

    await appsRepository.updateApps(updatedApps);
    for (final app in updatedApps) {
      onUpdateApp.call(app);
    }
    if (context.mounted) {
      showSnack(context, '${context.l10n.prepared} ${updatedApps.length} ${context.l10n.autoRunningGamesCount}');
    }
  }

  Future<void> showMarkDialog({
    required BuildContext context,
    required void Function(int min, int max, int? target) onSubmit,
    required TimeFilterType timeFilterType,
  }) async {
    final minController = TextEditingController(text: timeFilterType == TimeFilterType.hours ? '12' : '720');
    final maxController = TextEditingController(text: timeFilterType == TimeFilterType.hours ? '25' : '1501');
    final targetController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF171D25),
        surfaceTintColor: const Color(0xFF171D25),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.markGamesToAutoStart,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.filterMin, style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          SteamTextField(
                            controller: minController,
                            keyboardType: TextInputType.number,
                            hintText: '${context.l10n.filterMin} ${timeFilterType.localizedText(context)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.filterMax, style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          SteamTextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            hintText: '${context.l10n.filterMax} ${timeFilterType.localizedText(context)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(context.l10n.autoStopTime, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                SteamTextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  hintText: '${context.l10n.autoStopped} ${timeFilterType.localizedText(context).toLowerCase()}',
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SteamElevatedButton(
                        onPressed: () {
                          final min = int.tryParse(minController.text.trim());
                          final max = int.tryParse(maxController.text.trim());
                          final target = int.tryParse(targetController.text.trim());
                          if (min == null || max == null) {
                            return;
                          }
                          onSubmit(min, max, target);
                          Navigator.of(context).pop();
                        },
                        child: Text(context.l10n.markGame, style: const TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: SteamFilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancel, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    minController.dispose();
    maxController.dispose();
    targetController.dispose();
  }
}
