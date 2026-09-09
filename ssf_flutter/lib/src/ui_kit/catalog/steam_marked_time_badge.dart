import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamMarkedTimeBadge({required final String label, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: SteamUiColors.wishlist,
      boxShadow: [BoxShadow(color: Color(0x59000000), blurRadius: 5, offset: Offset(2, 1))],
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 68, minHeight: 17),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
        ),
      ),
    ),
  );
}
