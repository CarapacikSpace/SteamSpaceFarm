import 'package:flutter/material.dart';

class SteamCheckbox extends StatefulWidget {
  const SteamCheckbox({required this.value, super.key});

  final bool value;

  @override
  State<SteamCheckbox> createState() => _SteamCheckboxState();
}

class _SteamCheckboxState extends State<SteamCheckbox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: CustomPaint(
        painter: _InsetCheckboxPainter(
          isChecked: widget.value,
          backgroundColor: _hovering ? const Color(0xFF090909) : const Color(0xFF2B2E34),
        ),
        size: const Size(16, 16),
      ),
    );
  }
}

class _InsetCheckboxPainter extends CustomPainter {
  _InsetCheckboxPainter({required this.isChecked, required this.backgroundColor});

  final bool isChecked;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, backgroundPaint);

    final shadowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.black45, Colors.transparent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect.deflate(0.75), shadowPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF55585D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    if (isChecked) {
      final checkPaint = Paint()
        ..color = const Color(0xFF1C96FF)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(size.width * 0.25, size.height * 0.5)
        ..lineTo(size.width * 0.45, size.height * 0.7)
        ..lineTo(size.width * 0.75, size.height * 0.3);
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InsetCheckboxPainter oldDelegate) =>
      isChecked != oldDelegate.isChecked || backgroundColor != oldDelegate.backgroundColor;
}
