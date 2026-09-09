import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamCheckbox({
  required final bool value,
  required final ValueChanged<bool>? onChanged,
  required final Widget label,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamCheckbox> createState() => _SteamCheckboxState();
}

class _SteamCheckboxState() extends State<SteamCheckbox> {
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onChanged != null;

  void _toggle() => widget.onChanged?.call(!widget.value);

  @override
  Widget build(BuildContext context) => Semantics(
    checked: widget.value,
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
            _toggle();
            return null;
          },
        ),
      },
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _enabled ? _toggle : null,
        child: Opacity(
          opacity: _enabled ? 1 : .5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: SteamUiDurations.regular,
                width: SteamUiMetrics.checkboxSize,
                height: SteamUiMetrics.checkboxSize,
                decoration: BoxDecoration(
                  color: _hovered ? SteamUiColors.raisedSurfaceHover : SteamUiColors.raisedSurface,
                  border: _focused ? Border.all(color: Colors.white, width: 2) : null,
                  borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
                ),
                child: widget.value ? const Icon(Icons.check_rounded, size: 18, color: SteamUiColors.accent) : null,
              ),
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: const TextStyle(color: SteamUiColors.textSubtitle, fontSize: 13),
                child: widget.label,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
