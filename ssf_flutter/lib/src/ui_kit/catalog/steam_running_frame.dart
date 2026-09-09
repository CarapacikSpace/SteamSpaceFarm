import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

class const SteamRunningFrame({required final bool isRunning, required final Widget child, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: SteamUiDurations.fast,
    decoration: BoxDecoration(
      border: Border.all(color: isRunning ? SteamUiColors.running : Colors.transparent),
      boxShadow: isRunning ? const [BoxShadow(color: Color(0x66A1CD44), blurRadius: 5)] : const [],
    ),
    child: child,
  );
}
