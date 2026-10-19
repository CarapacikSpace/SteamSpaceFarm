import 'package:material_ui/material_ui.dart';

/// A single-choice settings block, styled after Steam's recording mode options.
class const SteamRadioOption({
  required final String title,
  required final String description,
  required final bool selected,
  required final VoidCallback? onPressed,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamRadioOption> createState() => _SteamRadioOptionState();
}

class _SteamRadioOptionState() extends State<SteamRadioOption> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final bool highlighted = enabled && (_hovered || _focused);
    return Semantics(
      checked: widget.selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onTap: widget.onPressed,
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          borderRadius: BorderRadius.circular(3),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 24, 16),
            decoration: BoxDecoration(
              color: widget.selected
                  ? const Color(0xA03D4450)
                  : highlighted
                  ? const Color(0x503D4450)
                  : const Color(0xFF23262E),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: _focused && enabled ? const Color(0xFF8B929A) : Colors.transparent),
              boxShadow: [
                if (widget.selected || highlighted)
                  const BoxShadow(color: Color(0x29000000), blurRadius: 8, offset: Offset(0, 6)),
              ],
            ),
            child: Opacity(
              opacity: enabled ? 1 : .3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.fromLTRB(6, 2, 22, 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.selected ? const Color(0xFF1A9FFF) : const Color(0xFF67707B),
                      border: widget.selected ? Border.all(color: const Color(0xFFDCDEDF), width: 3) : null,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: widget.selected ? const Color(0xFFDCDEDF) : const Color(0xFFB8BCBF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 18 / 13,
                            color: widget.selected ? const Color(0xFFB8BCBF) : const Color(0xFF8B929A),
                          ),
                        ),
                      ],
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
