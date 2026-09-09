import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamSegmentedControl<T>({
  required final List<T> values,
  required final T selected,
  required final String Function(T value) labelBuilder,
  required final ValueChanged<T>? onChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    assert(values.isNotEmpty, 'SteamSegmentedControl requires at least one value.');
    final int rawSelectedIndex = values.indexOf(selected);
    final selectedIndex = rawSelectedIndex < 0 ? 0 : rawSelectedIndex;
    final enabled = onChanged != null;

    return Semantics(
      container: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : .35,
        child: SizedBox(
          height: SteamUiMetrics.controlHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: SteamUiColors.raisedSurface,
              borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.hasBoundedWidth ? constraints.maxWidth : values.length * 80;
                  final double itemWidth = width / values.length;
                  return SizedBox(
                    width: width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          bottom: 4,
                          left: itemWidth * selectedIndex,
                          width: itemWidth,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: SteamUiColors.accent,
                              borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (final T value in values)
                              Expanded(
                                child: _Segment<T>(
                                  value: value,
                                  label: labelBuilder(value),
                                  selected: value == selected,
                                  onPressed: enabled ? () => onChanged?.call(value) : null,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class const _Segment<T>({
  required final T value,
  required final String label,
  required final bool selected,
  required final VoidCallback? onPressed,
}) extends StatefulWidget {
  @override
  State<_Segment<T>> createState() => _SegmentState<T>();
}

class _SegmentState<T>() extends State<_Segment<T>> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: widget.selected,
    button: true,
    enabled: widget.onPressed != null,
    label: widget.label,
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: !widget.selected && (_hovered || _focused) ? SteamUiColors.raisedSurfaceHover : Colors.transparent,
            borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Center(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.selected ? SteamUiColors.textStrong : SteamUiColors.textMuted,
                  fontSize: 13,
                  height: 17 / 13,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
