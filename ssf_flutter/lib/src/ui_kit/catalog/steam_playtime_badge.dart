import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamPlaytimeBadge({required final String label, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: SteamUiColors.playtimeSurface,
      borderRadius: BorderRadius.circular(2),
      boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1))],
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 68, minHeight: 18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(color: Color(0xFFE5E7E9), fontSize: 10, height: 1.2),
        ),
      ),
    ),
  );
}
