import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_card_hover.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_hover_menu_button.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_playtime_badge.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_running_frame.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamPortraitCard({
  required final Widget artwork,
  required final Widget details,
  required final String? playtimeLabel,
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
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0x0FC9C9C9)),
                  bottom: BorderSide(color: Color(0x80000000)),
                ),
                boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRect(
                    key: const ValueKey('portrait-artwork'),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        artwork,
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xF2111822)],
                              stops: [.52, 1],
                            ),
                          ),
                        ),
                        Positioned(left: 12, right: 12, bottom: 12, child: details),
                      ],
                    ),
                  ),
                ),
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
