import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_card_hover.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_card_info_surface.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_hover_menu_button.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_playtime_badge.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_running_frame.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamStoreHeaderCard({
  required final Widget artwork,
  required final String title,
  required final String typeLabel,
  required final String? playtimeLabel,
  final double imageAspectRatio = 460 / 215,
  final Widget? marker,
  final VoidCallback? onActivate,
  final VoidCallback? onMenuPressed,
  final bool menuOpen = false,
  final bool isRunning = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SteamCardHover(
    onActivate: onActivate,
    menuOpen: menuOpen,
    hoverAction: onMenuPressed == null
        ? null
        : Padding(
            padding: EdgeInsets.only(top: marker == null ? 0 : SteamUiMetrics.ownershipOverlap),
            child: SteamHoverMenuButton(onPressed: onMenuPressed),
          ),
    child: Padding(
      padding: EdgeInsets.only(top: marker == null ? 0 : SteamUiMetrics.ownershipOverlap, bottom: 7),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SteamRunningFrame(
            isRunning: isRunning,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(aspectRatio: imageAspectRatio, child: artwork),
                  SteamCardInfoSurface(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 16 / 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: SteamUiColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (marker case final marker?) Positioned(top: -SteamUiMetrics.ownershipOverlap, left: 0, child: marker),
          if (playtimeLabel case final label?)
            Positioned(
              left: 0,
              right: 0,
              bottom: -2,
              child: Center(child: SteamPlaytimeBadge(label: label)),
            ),
        ],
      ),
    ),
  );
}
