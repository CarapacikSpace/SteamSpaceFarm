import 'package:material_ui/material_ui.dart';

class const SteamCardInfoSurface({required final Widget child, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF111A24),
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x731F314A), Color(0xA621364D), Color(0x801C3246), Color(0x73284662), Color(0x8C2B5376)],
                stops: [.05, .2, .65, .95, 1],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-.8, -1),
                radius: 1.25,
                colors: [Color(0x335EAEFF), Color(0x0D22354D), Colors.transparent],
                stops: [0, .5, .9],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(.6, 1),
                radius: 1.2,
                colors: [Color(0x1A5EAEFF), Color(0x0D5EAEFF), Colors.transparent],
                stops: [0, .5, .9],
              ),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}
