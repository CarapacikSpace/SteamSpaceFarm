import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Matches the desktop Steam settings toggle's geometry and interaction states.
class const SteamSwitch({required final bool value, required final ValueChanged<bool>? onChanged, super.key})
    extends StatefulWidget {
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
    return Semantics(
      toggled: widget.value,
      enabled: enabled,
      onTap: enabled ? _toggle : null,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _toggle();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: enabled ? _toggle : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AnimatedContainer(
              duration: Duration(milliseconds: _hovered ? 100 : 50),
              width: 38,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (enabled && (_hovered || _focused))
                    BoxShadow(color: _focused ? const Color(0xFF8B929A) : const Color(0x4DFFFFFF), spreadRadius: 4),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: ColoredBox(
                        color: enabled ? const Color(0x26FFFFFF) : const Color(0xFF67707B),
                        child: Stack(
                          children: [
                            if (enabled)
                              AnimatedPositionedDirectional(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                start: widget.value ? -11 : -27,
                                top: 0,
                                bottom: 0,
                                width: 38,
                                child: const ColoredBox(color: Color(0xFF1A9FFF)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositionedDirectional(
                    duration: const Duration(milliseconds: 200),
                    curve: const Cubic(.1, .12, .53, 1.72),
                    start: widget.value ? 16 : 0,
                    top: 0,
                    width: 22,
                    height: 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: enabled ? Colors.white : const Color(0xFF8B929A),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 5)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class const SteamSwitchTile({
  required final bool value,
  required final ValueChanged<bool>? onChanged,
  required final Widget title,
  required final Widget subtitle,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: const Color(0xFF23262E),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: onChanged == null ? .3 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(style: const TextStyle(fontSize: 14), child: title),
                  const SizedBox(height: 8),
                  DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 13, height: 19 / 13, color: Color(0xFFBBBDC0)),
                    child: subtitle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          SteamSwitch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}
