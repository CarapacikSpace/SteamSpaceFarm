import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_flyout.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamDropdown<T>({
  required final List<T> items,
  required final T? value,
  required final String Function(T value) labelBuilder,
  required final ValueChanged<T>? onChanged,
  final String? placeholder,
  final double width = SteamUiMetrics.dropdownWidth,
  final double height = SteamUiMetrics.controlHeight,
  final double maxMenuHeight = 320,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamDropdown<T>> createState() => _SteamDropdownState<T>();
}

class _SteamDropdownState<T>() extends State<SteamDropdown<T>> {
  bool _open = false;

  bool get _enabled => widget.onChanged != null && widget.items.isNotEmpty;

  void _toggle() {
    if (!_enabled) {
      return;
    }
    setState(() => _open = !_open);
  }

  @override
  Widget build(BuildContext context) {
    final T? selectedValue = widget.value;
    final String label = selectedValue == null
        ? widget.placeholder ?? GeneratedLocalizations.of(context).selectAValue
        : widget.labelBuilder(selectedValue);
    final double availableMenuHeight = MediaQuery.sizeOf(context).height - 16;
    final double menuHeight = widget.maxMenuHeight < availableMenuHeight ? widget.maxMenuHeight : availableMenuHeight;
    return SteamFlyout(
      isOpen: _open,
      fillWidth: true,
      onClose: () => setState(() => _open = false),
      builder: (context) => Material(
        color: SteamUiColors.raisedSurface,
        borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: menuHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final T item in widget.items)
                  MenuItemButton(
                    onPressed: widget.onChanged == null
                        ? null
                        : () {
                            setState(() => _open = false);
                            widget.onChanged?.call(item);
                          },
                    style: ButtonStyle(
                      mouseCursor: WidgetStateProperty.resolveWith(
                        (states) =>
                            states.contains(WidgetState.disabled) ? SystemMouseCursors.basic : SystemMouseCursors.click,
                      ),
                      minimumSize: const WidgetStatePropertyAll(Size.zero),
                      fixedSize: WidgetStatePropertyAll(Size(widget.width, 36)),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.standard,
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)
                            ? SteamUiColors.textStrong
                            : SteamUiColors.textSubtitle,
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) =>
                            item == widget.value ||
                                states.contains(WidgetState.hovered) ||
                                states.contains(WidgetState.focused)
                            ? SteamUiColors.raisedSurfaceHover
                            : Colors.transparent,
                      ),
                      shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
                      textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                    ),
                    child: Align(alignment: Alignment.centerLeft, child: Text(widget.labelBuilder(item))),
                  ),
              ],
            ),
          ),
        ),
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Material(
          color: _enabled ? SteamUiColors.raisedSurface : SteamUiColors.disabledSurface,
          borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
          child: InkWell(
            onTap: _enabled ? _toggle : null,
            mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            hoverColor: SteamUiColors.raisedSurfaceHover,
            focusColor: SteamUiColors.raisedSurfaceHover,
            borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _enabled ? const Color(0xFFF1F2F3) : SteamUiColors.disabledText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 13,
                    color: SteamUiColors.textMuted,
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
