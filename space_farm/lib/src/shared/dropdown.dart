import 'package:flutter/material.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/common/widget/popup/popup.dart';
import 'package:space_farm/src/shared/checkbox.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';

class SteamDropdown extends StatefulWidget {
  const SteamDropdown({required this.selectedTypes, required this.types, required this.onChanged, super.key});

  final Set<SteamAppType> selectedTypes;
  final Set<SteamAppType> types;
  final ValueChanged<SteamAppType> onChanged;

  @override
  State<SteamDropdown> createState() => _SteamDropdownState();
}

class _SteamDropdownState extends State<SteamDropdown> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) => PopupBuilder(
    followerAnchor: Alignment.bottomCenter,
    followerBuilder: (context, controller) => PopupFollower(
      constraints: const BoxConstraints(maxWidth: 190),
      onDismiss: () => controller.hide(),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black,
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF3D4450),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.types
                .map(
                  (e) => DropdownCheckboxItem(
                    title: e.localizedText(context),
                    value: widget.selectedTypes.contains(e),
                    onChanged: (v) => widget.onChanged.call(e),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    ),
    targetBuilder: (context, controller) => SizedBox(
      width: 190,
      height: 32,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.show(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: _hovering ? const Color(0xFF3E4047) : const Color(0xFF26282D),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.selectedTypes.length == widget.types.length
                            ? context.l10n.all
                            : widget.selectedTypes.map((e) => e.localizedText(context)).join(', '),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: _hovering ? const Color(0xFFF5F5F6) : const Color(0xFFA3A3A3),
                          fontSize: 12,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: _hovering ? const Color(0xFFF5F5F6) : const Color(0xFFA3A3A3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SteamDropdownSingle<T> extends StatefulWidget {
  const SteamDropdownSingle({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    this.width = 150,
    super.key,
  });

  final Set<T> options;
  final T selected;

  // ignore: unsafe_variance
  final ValueChanged<T> onChanged;

  // ignore: unsafe_variance
  final String Function(T) labelBuilder;
  final double width;

  @override
  State<SteamDropdownSingle<T>> createState() => _SteamDropdownSingleState<T>();
}

class _SteamDropdownSingleState<T> extends State<SteamDropdownSingle<T>> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return PopupBuilder(
      followerAnchor: Alignment.bottomCenter,
      targetAnchor: Alignment.topCenter,
      followerBuilder: (context, controller) => PopupFollower(
        onDismiss: () => controller.hide(),
        constraints: BoxConstraints(maxWidth: widget.width),
        child: Material(
          elevation: 8,
          color: const Color(0xFF373C44),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options.map((option) {
                final hovering = ValueNotifier(false);

                return ValueListenableBuilder(
                  valueListenable: hovering,
                  builder: (context, isHovering, _) {
                    final bg = isHovering ? const Color(0xFF3E444D) : const Color(0xFF373C44);

                    return MouseRegion(
                      onEnter: (_) => hovering.value = true,
                      onExit: (_) => hovering.value = false,
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.onChanged(option);
                          controller.hide();
                        },
                        child: Material(
                          color: bg,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              height: 32,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.labelBuilder(option),
                                  style: const TextStyle(color: Color(0xFFDFE3E6), fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
      targetBuilder: (context, controller) => SizedBox(
        width: widget.width,
        height: 32,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: controller.show,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: _hovering ? const Color(0xFF3E4047) : const Color(0xFF26282D),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.labelBuilder(widget.selected),
                      style: TextStyle(
                        color: _hovering ? const Color(0xFFF5F5F6) : const Color(0xFFA3A3A3),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A9EFE)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownCheckboxItem extends StatelessWidget {
  const DropdownCheckboxItem({required this.title, required this.value, required this.onChanged, super.key});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: GestureDetector(
        onTap: () => onChanged.call(!value),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                SteamCheckbox(value: value),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(color: Color(0xFFC8CBCE), fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
