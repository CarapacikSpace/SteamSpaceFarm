import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamCardHover({
  required final Widget child,
  final VoidCallback? onActivate,
  final Widget? hoverAction,
  final bool menuOpen = false,
  final bool enabled = true,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamCardHover> createState() => _SteamCardHoverState();
}

class _SteamCardHoverState() extends State<SteamCardHover> {
  bool _hovered = false;
  bool _focused = false;

  bool get _active => widget.enabled && !widget.menuOpen && (_hovered || _focused);

  @override
  Widget build(BuildContext context) {
    final double scale = _active ? SteamUiMetrics.cardHoverScale : 1;
    return FocusableActionDetector(
      enabled: widget.enabled,
      mouseCursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onActivate?.call();
            return null;
          },
        ),
      },
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: GestureDetector(
        onTap: widget.onActivate,
        child: AnimatedScale(
          scale: scale,
          duration: SteamUiDurations.fast,
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: SteamUiDurations.fast,
            foregroundDecoration: _focused ? BoxDecoration(border: Border.all(color: Colors.white, width: 2)) : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child,
                if (widget.hoverAction case final hoverAction?)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IgnorePointer(
                      ignoring: !_active,
                      child: AnimatedOpacity(
                        opacity: _active ? 1 : 0,
                        duration: SteamUiDurations.regular,
                        child: hoverAction,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
