import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_filter_surface.dart';

class const SteamDialog({required final Widget child, final double maxWidth = 460, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.sizeOf(context).height - 40),
      child: SteamFilterSurface(borderRadius: BorderRadius.circular(6), child: child),
    ),
  );
}
