import 'package:material_ui/material_ui.dart';

void showSteamNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(steamNotice(message));
}

SnackBar steamNotice(String message) => SnackBar(
  behavior: SnackBarBehavior.floating,
  backgroundColor: Colors.transparent,
  elevation: 0,
  padding: EdgeInsets.zero,
  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
  content: Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      key: const ValueKey('steam-notice'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(color: Color(0xFF1A9FFF), borderRadius: BorderRadius.all(Radius.circular(2))),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),
    ),
  ),
);
