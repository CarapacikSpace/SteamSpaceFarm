import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

enum SteamButtonVariant() {
  primary,
  run,
  secondary,
  seeMore,
  shopping,
}

class const SteamButton({
  required final Widget child,
  required final VoidCallback? onPressed,
  final SteamButtonVariant variant = SteamButtonVariant.secondary,
  final Widget? icon,
  final bool expand = false,
  final bool compact = false,
  final bool iconOnly = false,
  final double? height,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamButton> createState() => _SteamButtonState();
}

class _SteamButtonState() extends State<SteamButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool touchLayout = MediaQuery.sizeOf(context).width < 600;
    final double height =
        widget.height ??
        (widget.variant == SteamButtonVariant.seeMore
            ? SteamUiMetrics.seeMoreButtonHeight
            : touchLayout
            ? SteamUiMetrics.touchButtonHeight
            : SteamUiMetrics.buttonHeight);
    final Duration duration = _pressed ? SteamUiDurations.pressed : SteamUiDurations.regular;
    final BoxDecoration decoration = _decoration();
    final Widget content = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      height: height,
      width: widget.iconOnly ? height : null,
      padding: EdgeInsets.symmetric(
        horizontal: widget.iconOnly
            ? 0
            : widget.variant == SteamButtonVariant.seeMore
            ? 16
            : widget.variant == SteamButtonVariant.shopping
            ? 15
            : widget.compact
            ? 9
            : 24,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: widget.expand && !widget.iconOnly ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ?widget.icon,
          if (!widget.iconOnly) ...[
            if (widget.icon != null) const SizedBox(width: 7),
            Flexible(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: !_enabled
                      ? SteamUiColors.disabledText
                      : widget.variant == SteamButtonVariant.seeMore
                      ? SteamUiColors.seeMoreText
                      : widget.variant == SteamButtonVariant.shopping
                      ? (_hovered || _focused ? Colors.white : const Color(0xFFDFE3E6))
                      : SteamUiColors.text,
                  fontSize: widget.variant == SteamButtonVariant.seeMore
                      ? 13
                      : widget.variant == SteamButtonVariant.shopping
                      ? 15
                      : 14,
                  fontWeight: widget.variant == SteamButtonVariant.seeMore ? FontWeight.w500 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: widget.child,
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          child: widget.expand && !widget.iconOnly ? SizedBox(width: double.infinity, child: content) : content,
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    if (!_enabled) {
      return BoxDecoration(
        color: SteamUiColors.disabledSurface,
        borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
      );
    }

    final bool highlighted = _hovered || _focused;
    if (widget.variant == SteamButtonVariant.shopping) {
      return BoxDecoration(
        color: highlighted ? const Color(0xFF464D58) : const Color(0xFF32363F),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: highlighted ? const Color(0x80000000) : const Color(0x33000000),
            blurRadius: highlighted ? 15 : 5,
            offset: const Offset(2, 2),
          ),
        ],
      );
    }
    if (widget.variant == SteamButtonVariant.seeMore) {
      return BoxDecoration(
        color: highlighted ? SteamUiColors.seeMoreSurfaceHover : SteamUiColors.seeMoreSurface,
        borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
      );
    }

    final BoxBorder? border = _focused ? Border.all(color: Colors.white, width: 2) : null;
    final List<BoxShadow> shadows = highlighted && !_pressed
        ? const [BoxShadow(color: Color(0x4D000000), blurRadius: 16, offset: Offset(0, 8))]
        : _pressed
        ? const [BoxShadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1))]
        : const [];

    if (widget.variant == SteamButtonVariant.primary || widget.variant == SteamButtonVariant.run) {
      final LinearGradient gradient = _pressed
          ? widget.variant == SteamButtonVariant.run
                ? SteamUiGradients.runPressed
                : SteamUiGradients.primaryPressed
          : highlighted
          ? widget.variant == SteamButtonVariant.run
                ? SteamUiGradients.runHover
                : SteamUiGradients.primaryHover
          : widget.variant == SteamButtonVariant.run
          ? SteamUiGradients.run
          : SteamUiGradients.primary;
      return BoxDecoration(
        gradient: gradient,
        border: border,
        borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
        boxShadow: shadows,
      );
    }

    return BoxDecoration(
      color: _pressed
          ? SteamUiColors.pressed
          : highlighted
          ? SteamUiColors.raisedSurfaceHover
          : SteamUiColors.raisedSurface,
      border: border,
      borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
      boxShadow: shadows,
    );
  }
}
