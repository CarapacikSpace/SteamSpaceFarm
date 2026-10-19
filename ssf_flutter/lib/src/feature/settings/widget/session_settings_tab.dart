import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_farming_mode.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

class const SessionSettingsTab({
  required final AppSettings settings,
  required final bool isSaving,
  required final Object? error,
  required final ValueChanged<AppSettings> onChanged,
  required final VoidCallback onRetry,
  required final bool gamesActive,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SteamPageHeader(
              eyebrow: 'Steam',
              title: context.l10n.sessionSettings,
              description: context.l10n.settingsImmediateSaveHint,
            ),
            const SizedBox(height: 24),
            if (isSaving) const LinearProgressIndicator(minHeight: 2),
            if (error != null) ...[
              Text(context.l10n.settingsSaveError),
              Align(
                alignment: Alignment.centerLeft,
                child: SteamButton(onPressed: onRetry, child: Text(context.l10n.retry)),
              ),
              const SizedBox(height: 16),
            ],
            SteamSwitchTile(
              value: settings.refreshOnStartup,
              onChanged: isSaving ? null : (value) => onChanged(settings.copyWith(refreshOnStartup: value)),
              title: Text(context.l10n.refreshOnStartup),
              subtitle: Text(context.l10n.refreshOnStartupHint),
            ),
            SteamSwitchTile(
              value: settings.invisibleWhilePlaying,
              onChanged: isSaving || gamesActive
                  ? null
                  : (value) => onChanged(settings.copyWith(invisibleWhilePlaying: value)),
              title: Text(context.l10n.invisibleWhilePlaying),
              subtitle: Text(context.l10n.invisibleWhilePlayingHint),
            ),
            SteamSwitchTile(
              value: settings.experimentalSteamKit,
              onChanged: isSaving || gamesActive
                  ? null
                  : (value) => onChanged(settings.copyWith(experimentalSteamKit: value)),
              title: Text(context.l10n.experimentalSteamKit),
              subtitle: Text(context.l10n.experimentalSteamKitHint),
            ),
            SteamSwitchTile(
              value: settings.refreshPlaytimeHourly,
              onChanged: isSaving ? null : (value) => onChanged(settings.copyWith(refreshPlaytimeHourly: value)),
              title: Text(context.l10n.refreshPlaytimeHourly),
              subtitle: Text(context.l10n.refreshPlaytimeHourlyHint),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.cardFarmingMode),
            const SizedBox(height: 8),
            for (final mode in CardFarmingMode.values) ...[
              SteamRadioOption(
                selected: settings.cardFarmingMode == mode,
                onPressed: isSaving ? null : () => onChanged(settings.copyWith(cardFarmingMode: mode)),
                title: switch (mode) {
                  CardFarmingMode.fast => context.l10n.cardModeFast,
                  CardFarmingMode.sequential => context.l10n.cardModeSequential,
                  CardFarmingMode.combined => context.l10n.cardModeCombined,
                },
                description: switch (mode) {
                  CardFarmingMode.fast => context.l10n.cardModeFastHint,
                  CardFarmingMode.sequential => context.l10n.cardModeSequentialHint,
                  CardFarmingMode.combined => context.l10n.cardModeCombinedHint,
                },
              ),
              if (mode != CardFarmingMode.values.last) const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            Text(context.l10n.cardsPriority, style: const TextStyle(color: SteamUiColors.textSubtitle)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
