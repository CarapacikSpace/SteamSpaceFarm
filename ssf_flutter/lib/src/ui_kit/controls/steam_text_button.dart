import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamTextButton({
  required final Widget child,
  required final VoidCallback? onPressed,
  final Widget? leading,
  final Widget? trailing,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamTextButton> createState() => _SteamTextButtonState();
}

class _SteamTextButtonState() extends State<SteamTextButton> {
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final Color foreground = !_enabled
        ? SteamUiColors.disabledText
        : _focused
        ? Colors.black
        : Colors.white;
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
          child: AnimatedContainer(
            duration: SteamUiDurations.regular,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: _focused ? Colors.white : Colors.transparent,
            child: IconTheme(
              data: IconThemeData(color: foreground, size: 14),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  shadows: _hovered || _focused
                      ? const []
                      : const [Shadow(color: Color(0x80000000), offset: Offset(1, 1))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.leading case final leading?) ...[leading, const SizedBox(width: 5)],
                    widget.child,
                    if (widget.trailing case final trailing?) ...[const SizedBox(width: 5), trailing],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
