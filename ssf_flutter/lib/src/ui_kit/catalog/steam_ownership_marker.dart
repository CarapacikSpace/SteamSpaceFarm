import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_marked_time_badge.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

enum SteamOwnershipVisual() {
  personal,
  family,
  unknown,
}

class const SteamOwnershipMarker({
  required final String label,
  required final SteamOwnershipVisual ownership,
  final bool favorite = false,
  final String? markedTime,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: ownership == SteamOwnershipVisual.unknown ? SteamUiColors.menuHover : null,
          gradient: switch (ownership) {
            SteamOwnershipVisual.personal => SteamUiGradients.ownershipPersonal,
            SteamOwnershipVisual.family => SteamUiGradients.ownershipFamily,
            SteamOwnershipVisual.unknown => null,
          },
          boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 5, offset: Offset(2, 1))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, height: 1),
          ),
        ),
      ),
      if (favorite || markedTime != null) ...[
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (favorite)
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: SteamUiColors.wishlist,
                  boxShadow: [BoxShadow(color: Color(0x59000000), blurRadius: 5, offset: Offset(2, 1))],
                ),
                child: SizedBox(width: 19, height: 17, child: Icon(Icons.star_rounded, size: 12, color: Colors.white)),
              ),
            if (favorite && markedTime != null) const SizedBox(width: 3),
            if (markedTime case final markedTime?) SteamMarkedTimeBadge(label: markedTime),
          ],
        ),
      ],
    ],
  );
}
