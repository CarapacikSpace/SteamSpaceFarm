import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamHoverMenuButton({required final VoidCallback? onPressed, super.key}) extends StatefulWidget {
  @override
  State<SteamHoverMenuButton> createState() => _SteamHoverMenuButtonState();
}

class _SteamHoverMenuButtonState() extends State<SteamHoverMenuButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _hovered || _focused;
    return Semantics(
      button: true,
      label: GeneratedLocalizations.of(context).moreActions,
      child: FocusableActionDetector(
        enabled: widget.onPressed != null,
        mouseCursor: widget.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
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
            width: 30,
            height: 15,
            decoration: BoxDecoration(
              color: highlighted ? SteamUiColors.overflowSurfaceHover : SteamUiColors.overflowSurface,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [BoxShadow(blurRadius: 3)],
            ),
            child: Icon(Icons.more_horiz, size: 18, color: highlighted ? Colors.white : const Color(0xFF18212B)),
          ),
        ),
      ),
    );
  }
}
