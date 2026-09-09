import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_card_hover.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_hover_menu_button.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_marked_time_badge.dart';
import 'package:ssf_flutter/src/ui_kit/catalog/steam_playtime_badge.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamIconContentCard({
  required final Widget icon,
  required final Widget content,
  required final String? playtimeLabel,
  final String? markedTimeLabel,
  final Widget? trailing,
  final Widget? marker,
  final VoidCallback? onPressed,
  final VoidCallback? onMenuPressed,
  final bool menuOpen = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamIconContentCard> createState() => _SteamIconContentCardState();
}

class _SteamIconContentCardState() extends State<SteamIconContentCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: SteamCardHover(
      onActivate: widget.onPressed,
      menuOpen: widget.menuOpen,
      hoverAction: widget.onMenuPressed == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 75),
              child: SteamHoverMenuButton(onPressed: widget.onMenuPressed),
            ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: SteamUiDurations.regular,
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(gradient: _hovered ? SteamUiGradients.iconCardHover : SteamUiGradients.iconCard),
            child: Row(
              children: [
                SizedBox.square(dimension: 32, child: widget.icon),
                const SizedBox(width: 8),
                if (widget.marker case final marker?) ...[marker, const SizedBox(width: 8)],
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: widget.playtimeLabel != null || widget.markedTimeLabel != null ? 78 : 0,
                    ),
                    child: widget.content,
                  ),
                ),
                if (widget.trailing case final trailing?) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
          if (widget.markedTimeLabel case final markedTimeLabel?)
            Positioned(top: 6, right: 6, child: SteamMarkedTimeBadge(label: markedTimeLabel)),
          if (widget.playtimeLabel case final label?)
            Positioned(right: 6, bottom: 6, child: SteamPlaytimeBadge(label: label)),
        ],
      ),
    ),
  );
}
