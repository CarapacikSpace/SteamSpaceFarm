import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

Future<T?> showSteamFilterSurface<T>({required BuildContext context, required WidgetBuilder builder}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: SteamUiColors.filterBarrier,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final Animation<double> curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(.1, 0), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 380,
          height: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: SteamFilterSurface(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
              child: builder(context),
            ),
          ),
        ),
      ),
    ),
  );
}

class const SteamFilterSurface({
  required final Widget child,
  final BorderRadius borderRadius = BorderRadius.zero,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 1.08,
            colors: [Color(0x33182535), Color(0x85182535), Color(0xD9182535), Color(0xFF182535), Color(0xFF192330)],
            stops: [0, .05, .2, .6, 1],
          ),
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 2))],
        ),
        child: child,
      ),
    ),
  );
}

class const SteamFilterSection({required final String title, required final List<Widget> children, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 28,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xA6ABABAB), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      ...children,
    ],
  );
}

class const SteamFilterItem({
  required final Widget child,
  required final VoidCallback? onPressed,
  final bool selected = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamFilterItem> createState() => _SteamFilterItemState();
}

class _SteamFilterItemState() extends State<SteamFilterItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: widget.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        mouseCursor: widget.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: SteamUiDurations.regular,
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: _hovered || widget.selected
                ? const LinearGradient(
                    colors: [Color(0x26A3BAD3), Color(0x0DA3BAD3), Color(0x00A3BAD3)],
                    stops: [0, .35, 1],
                  )
                : null,
            border: const Border(bottom: BorderSide(color: Color(0x0D7EABFF))),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: _hovered ? Colors.white : SteamUiColors.searchPlaceholder,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
