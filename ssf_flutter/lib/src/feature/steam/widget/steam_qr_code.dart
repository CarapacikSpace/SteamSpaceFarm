import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

class const SteamQrPanel({
  required final String? data,
  required final bool active,
  final VoidCallback? onRefresh,
  final double size = 208,
  super.key,
}) extends StatelessWidget {
  static final _placeholder = QrImage(
    QrCode(payload: QrPayload.fromString('SteamSpaceFarm inactive QR placeholder. Refresh to get a new sign-in code.')),
  );

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: ColoredBox(
      color: Colors.white,
      child: SizedBox.square(
        dimension: size,
        child: active && data != null
            ? SteamQrCode(data: data!, size: size)
            : Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(
                    child: IgnorePointer(
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CustomPaint(painter: SteamQrPainter(_placeholder)),
                        ),
                      ),
                    ),
                  ),
                  const ColoredBox(color: Color(0x33FFFFFF)),
                  Center(
                    child: onRefresh != null
                        ? IconButton(
                            key: const ValueKey('steam-refresh-qr'),
                            onPressed: onRefresh,
                            tooltip: GeneratedLocalizations.of(context).refreshQrCode,
                            style: IconButton.styleFrom(
                              minimumSize: const Size.square(72),
                              maximumSize: const Size.square(72),
                              fixedSize: const Size.square(72),
                              padding: EdgeInsets.zero,
                              iconSize: 44,
                              backgroundColor: const Color(0xB3000000),
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 44, color: Colors.white),
                          )
                        : const DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xB3000000),
                              borderRadius: BorderRadius.all(Radius.circular(3)),
                            ),
                            child: SizedBox.square(
                              dimension: 72,
                              child: Icon(Icons.qr_code_2, size: 44, color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    ),
  );
}

class const SteamQrCode({required final String data, final double size = 208, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final image = QrImage(QrCode(payload: QrPayload.fromString(data)));
    return Semantics(
      label: GeneratedLocalizations.of(context).steamQrAccessibilityLabel,
      image: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.all(Radius.circular(12))),
        child: SizedBox.square(
          dimension: size,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(painter: SteamQrPainter(image)),
          ),
        ),
      ),
    );
  }
}

class SteamQrPainter(final QrImage image) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const quiet = 4;
    final double cell = size.shortestSide / (image.moduleCount + quiet * 2);
    final double left = (size.width - cell * (image.moduleCount + quiet * 2)) / 2;
    final double top = (size.height - cell * (image.moduleCount + quiet * 2)) / 2;
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..isAntiAlias = false;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var column = 0; column < image.moduleCount; column++) {
        if (image.isDark(row, column)) {
          canvas.drawRect(Rect.fromLTWH(left + (column + quiet) * cell, top + (row + quiet) * cell, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SteamQrPainter oldDelegate) => !identical(image, oldDelegate.image);
}
