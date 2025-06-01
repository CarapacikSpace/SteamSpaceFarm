import 'package:flutter/material.dart';

class SteamTextButton extends StatelessWidget {
  const SteamTextButton({required this.onPressed, required this.child, super.key});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        surfaceTintColor: Colors.transparent,
        overlayColor: Colors.transparent,
        fixedSize: const Size.fromHeight(30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
      child: child,
    );
  }
}
