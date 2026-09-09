import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_button.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_text_button.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_dialog.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

Future<bool> showSteamConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => SteamDialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(color: SteamUiColors.textMuted, height: 1.4)),
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  SteamTextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(GeneratedLocalizations.of(context).cancel),
                  ),
                  SteamButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(confirmText)),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ??
    false;
