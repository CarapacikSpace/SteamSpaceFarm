import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamPageHeader({
  required final String eyebrow,
  required final String title,
  required final String description,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: SteamUiColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 24, height: 29 / 24, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 7),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Text(
          description,
          style: const TextStyle(color: SteamUiColors.textMuted, fontSize: 13, height: 19 / 13),
        ),
      ),
    ],
  );
}
