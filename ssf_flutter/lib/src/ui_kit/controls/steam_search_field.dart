import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamSearchField({
  required final TextEditingController controller,
  required final FocusNode focusNode,
  required final ValueChanged<String> onChanged,
  required final VoidCallback onSearchPressed,
  final String? hintText,
  final double? height,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamSearchField> createState() => _SteamSearchFieldState();
}

class _SteamSearchFieldState() extends State<SteamSearchField> {
  bool _fieldHovered = false;
  bool _buttonHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool touchLayout = MediaQuery.sizeOf(context).width < 600;
    final double height = widget.height ?? (touchLayout ? SteamUiMetrics.touchInputHeight : SteamUiMetrics.inputHeight);
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, widget.focusNode]),
      builder: (context, child) => SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                onEnter: (_) => setState(() => _fieldHovered = true),
                onExit: (_) => setState(() => _fieldHovered = false),
                child: AnimatedContainer(
                  duration: SteamUiDurations.regular,
                  decoration: BoxDecoration(
                    color: widget.focusNode.hasFocus ? SteamUiColors.searchSurfaceFocused : SteamUiColors.searchSurface,
                    border: Border.all(
                      color: widget.focusNode.hasFocus
                          ? SteamUiColors.accent
                          : _fieldHovered
                          ? SteamUiColors.searchBorderHover
                          : SteamUiColors.searchBorder,
                    ),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(SteamUiMetrics.controlRadius)),
                    boxShadow: widget.focusNode.hasFocus
                        ? const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 2,
                              offset: Offset(0, 2),
                              blurStyle: BlurStyle.inner,
                            ),
                          ]
                        : const [],
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    onSubmitted: (_) => widget.onSearchPressed(),
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(color: SteamUiColors.searchText, fontSize: 13),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      constraints: BoxConstraints(maxHeight: height),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      hintText: widget.hintText ?? GeneratedLocalizations.of(context).searchByName,
                      hintStyle: const TextStyle(
                        color: SteamUiColors.searchPlaceholder,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _buttonHovered = true),
              onExit: (_) => setState(() => _buttonHovered = false),
              child: Material(
                color: _buttonHovered ? SteamUiColors.searchButtonHover : SteamUiColors.accent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(1)),
                child: InkWell(
                  onTap: widget.onSearchPressed,
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(1)),
                  child: SizedBox(
                    width: height,
                    child: Center(
                      child: AnimatedScale(
                        scale: _buttonHovered ? 1.2 : 1,
                        duration: SteamUiDurations.regular,
                        curve: Curves.easeOut,
                        child: const Icon(Icons.search, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
