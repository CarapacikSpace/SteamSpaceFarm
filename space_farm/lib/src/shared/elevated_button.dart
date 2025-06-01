import 'package:flutter/material.dart';

class SteamElevatedButton extends StatelessWidget {
  const SteamElevatedButton({required this.onPressed, required this.child, super.key});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A9FFF),
        fixedSize: const Size.fromHeight(30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
      child: child,
    );
  }
}
