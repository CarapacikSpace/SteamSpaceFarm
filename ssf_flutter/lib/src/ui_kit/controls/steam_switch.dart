import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamSwitch({
  required final bool value,
  required final ValueChanged<bool>? onChanged,
  final Widget? label,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamSwitch> createState() => _SteamSwitchState();
}

class _SteamSwitchState() extends State<SteamSwitch> {
  bool _hovered = false;
  bool _focused = false;

  void _toggle() => widget.onChanged?.call(!widget.value);

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final bool highlighted = _hovered || _focused;
    final Widget control = AnimatedContainer(
      duration: SteamUiDurations.regular,
      width: 38,
      height: 20,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: widget.value
            ? highlighted
                  ? SteamUiColors.searchButtonHover
                  : SteamUiColors.accent
            : highlighted
            ? SteamUiColors.raisedSurfaceHover
            : SteamUiColors.raisedSurface,
        borderRadius: BorderRadius.circular(10),
        border: _focused ? Border.all(color: Colors.white) : null,
      ),
      child: AnimatedAlign(
        duration: SteamUiDurations.regular,
        curve: Curves.easeOut,
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: SizedBox.square(dimension: 16),
        ),
      ),
    );

    return Semantics(
      toggled: widget.value,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : .35,
        child: FocusableActionDetector(
          enabled: enabled,
          mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _toggle();
                return null;
              },
            ),
          },
          onShowHoverHighlight: (value) => setState(() => _hovered = value),
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? _toggle : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                control,
                if (widget.label case final label?) ...[const SizedBox(width: 8), label],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
