import 'package:material_ui/material_ui.dart';

class const SteamSurfaceCard({required final Widget child, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF24262C), Color(0xFF17191D)],
      ),
    ),
    child: child,
  );
}
