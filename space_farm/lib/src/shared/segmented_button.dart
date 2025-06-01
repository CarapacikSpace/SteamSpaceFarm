import 'package:flutter/material.dart';

class SteamSegmentedButton<T> extends StatelessWidget {
  const SteamSegmentedButton({
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    required this.labelBuilder,
    this.expandedItems = true,
    super.key,
  });

  final bool expandedItems;
  final List<T> values;
  final T selectedValue;

  // ignore: unsafe_variance
  final String Function(T value, BuildContext context) labelBuilder;

  // ignore: unsafe_variance
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(color: const Color(0xFF26282D), borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(values.length, (index) {
            final value = values[index];
            final isSelected = value == selectedValue;

            final isFirst = index == 0;
            final isLast = index == values.length - 1;

            Widget button = _SegmentButton(
              text: labelBuilder(value, context),
              isSelected: isSelected,
              isFirst: isFirst,
              isLast: isLast,
              onTap: () => onSelected(value),
            );

            if (expandedItems) {
              button = Expanded(child: button);
            }
            return button;
          }),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatefulWidget {
  const _SegmentButton({
    required this.text,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_SegmentButton> createState() => _SegmentButtonState();
}

class _SegmentButtonState extends State<_SegmentButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFF1A9FFF)
                  : (_hovering ? const Color(0xFF2F3136) : Colors.transparent),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1,
                    color: widget.isSelected ? Colors.white : const Color(0xFFA3A3A3),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
