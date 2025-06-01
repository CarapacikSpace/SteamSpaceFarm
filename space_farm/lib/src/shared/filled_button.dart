import 'package:flutter/material.dart';

class SteamFilledButton extends StatelessWidget {
  const SteamFilledButton({required this.onPressed, required this.child, super.key});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF3D4450),
        fixedSize: const Size.fromHeight(30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
      child: child,
    );
  }
}
