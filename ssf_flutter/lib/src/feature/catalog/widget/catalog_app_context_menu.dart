import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_flyout.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

enum CatalogAppMenuAction() {
  run,
  favorite,
  currentTime,
  stopTime,
  ownership,
  copyAppId,
}

class const CatalogAppContextMenu({
  required final LocalApp app,
  required final ValueChanged<CatalogAppMenuAction> onActionSelected,
  required final Widget Function(VoidCallback openMenu) childBuilder,
  final bool isRunning = false,
  final bool isBusy = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<CatalogAppContextMenu> createState() => _CatalogAppContextMenuState();
}

class _CatalogAppContextMenuState() extends State<CatalogAppContextMenu> {
  bool _open = false;
  bool _editing = false;
  Offset _position = Offset.zero;

  void _close() => setState(() {
    _open = false;
    _editing = false;
  });

  void _select(CatalogAppMenuAction action) {
    _close();
    widget.onActionSelected(action);
  }

  void _show(Offset position) => setState(() {
    _position = position;
    _open = true;
    _editing = false;
  });

  static bool _highlighted(Set<WidgetState> states) =>
      states.contains(WidgetState.hovered) ||
      states.contains(WidgetState.focused) ||
      states.contains(WidgetState.pressed);

  static final ButtonStyle _itemStyle = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
    maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 32)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
    alignment: Alignment.centerLeft,
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => _highlighted(states) ? const Color(0xFFDCDEDF) : Colors.transparent,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? const Color(0xFF7B8491)
          : _highlighted(states)
          ? SteamUiColors.raisedSurface
          : SteamUiColors.textMuted,
    ),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    mouseCursor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? SystemMouseCursors.basic : SystemMouseCursors.click,
    ),
    textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14, height: 17 / 14)),
  );

  Widget _item(String label, CatalogAppMenuAction action) => MouseRegion(
    onEnter: (_) {
      if (_editing) {
        setState(() => _editing = false);
      }
    },
    child: TextButton(style: _itemStyle, onPressed: widget.isBusy ? null : () => _select(action), child: Text(label)),
  );

  Widget _panel(List<Widget> children) => Material(
    color: SteamUiColors.raisedSurface,
    elevation: 12,
    shadowColor: const Color(0xCC000000),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final GeneratedLocalizations l10n = GeneratedLocalizations.of(context);
    return SteamFlyout(
      isOpen: _open,
      position: _position,
      onClose: _close,
      builder: (_) => _panel([
        MouseRegion(
          onEnter: (_) {
            if (_editing) {
              setState(() => _editing = false);
            }
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: widget.isRunning
                    ? const [Color(0xFF1A9FFF), Color(0xFF1673A8)]
                    : const [Color(0xFF70D61D), Color(0xFF01A75C)],
              ),
            ),
            child: TextButton(
              style: _itemStyle.copyWith(
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                overlayColor: const WidgetStatePropertyAll(Color(0x1AFFFFFF)),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                ),
              ),
              onPressed: widget.isBusy ? null : () => _select(CatalogAppMenuAction.run),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.isRunning ? Icons.stop : Icons.play_arrow, size: 19),
                  const SizedBox(width: 5),
                  Text(widget.isRunning ? l10n.stopMenuLabel : l10n.launchMenuLabel),
                ],
              ),
            ),
          ),
        ),
        _item(widget.app.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites, CatalogAppMenuAction.favorite),
        SteamFlyout(
          isOpen: _editing,
          submenu: true,
          onClose: () => setState(() => _editing = false),
          builder: (_) => _panel([
            TextButton(
              style: _itemStyle,
              onPressed: widget.isBusy ? null : () => _select(CatalogAppMenuAction.currentTime),
              child: Text(l10n.currentPlaytime),
            ),
            TextButton(
              style: _itemStyle,
              onPressed: widget.isBusy ? null : () => _select(CatalogAppMenuAction.stopTime),
              child: Text(l10n.autoStop),
            ),
          ]),
          child: MouseRegion(
            onEnter: widget.isBusy ? null : (_) => setState(() => _editing = true),
            child: Focus(
              onKeyEvent: (_, event) {
                if (!widget.isBusy && event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  setState(() => _editing = true);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextButton(
                style: _itemStyle,
                onPressed: widget.isBusy ? null : () => setState(() => _editing = !_editing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(l10n.edit), const Icon(Icons.chevron_right, size: 18)],
                ),
              ),
            ),
          ),
        ),
        _item(l10n.setOwnership, CatalogAppMenuAction.ownership),
        const Divider(height: 1, thickness: 1, color: Color(0xFF696969)),
        _item(l10n.copyAppId, CatalogAppMenuAction.copyAppId),
      ]),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (event.buttons & kSecondaryMouseButton != 0) {
            _show(event.localPosition);
          }
        },
        child: widget.childBuilder(() {
          final box = context.findRenderObject()! as RenderBox;
          _show(Offset(box.size.width - 20, 12));
        }),
      ),
    );
  }
}
