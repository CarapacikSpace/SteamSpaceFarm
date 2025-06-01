import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SteamTextField extends StatelessWidget {
  const SteamTextField({
    required this.controller,
    this.hintText,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 12, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: const Color(0xFF19212D),
          isDense: true,
          filled: true,
          suffixIcon:
              suffixIcon ??
              ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  if (controller.text.isNotEmpty) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: controller.clear,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: const Icon(Icons.clear, size: 16),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
        ),
      ),
    );
  }
}
