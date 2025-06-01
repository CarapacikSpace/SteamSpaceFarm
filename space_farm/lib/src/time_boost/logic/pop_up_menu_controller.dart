import 'dart:async';

import 'package:flutter/material.dart';

class PopUpMenuController {
  PopUpMenuController._internal();

  static final PopUpMenuController instance = PopUpMenuController._internal();

  OverlayEntry? _menuEntry;
  OverlayEntry? _barrierEntry;
  AnimationController? _animationController;
  bool _isShown = false;

  Future<void> show({
    required BuildContext context,
    required TickerProvider vsync,
    required Offset position,
    required List<Widget> items,
    double width = 220,
  }) async {
    await hide();
    if (!context.mounted) {
      return;
    }
    final screenSize = MediaQuery.sizeOf(context);

    if (!_isTickerProviderAlive(vsync)) {
      return;
    }

    final estimatedHeight = items.length * 48.0;
    final showAbove = position.dy + estimatedHeight > screenSize.height;
    final top = showAbove
        ? (position.dy - estimatedHeight < 16 ? 16 : position.dy - estimatedHeight).toDouble()
        : position.dy;
    final left = position.dx + width > screenSize.width ? screenSize.width - width - 16 : position.dx;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: vsync);

    final animation = CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);

    _barrierEntry = OverlayEntry(
      builder: (_) =>
          GestureDetector(onTap: hide, behavior: HitTestBehavior.translucent, child: const SizedBox.expand()),
    );

    _menuEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: top,
        left: left,
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            alignment: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
            child: Material(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFF3D4450),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: width,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenSize.height - 32),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: items),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay
      ..insert(_barrierEntry!)
      ..insert(_menuEntry!);
    _isShown = true;

    if (_isTickerProviderAlive(vsync)) {
      await _animationController!.forward();
    }
  }

  Future<void> hide() async {
    if (!_isShown) {
      return;
    }

    try {
      if (_animationController?.isCompleted ?? false) {
        await _animationController?.reverse();
      }
    } on Object catch (_) {
      // AnimationController might already be disposed
    }

    _menuEntry?.remove();
    _barrierEntry?.remove();

    _animationController?.dispose();

    _menuEntry = null;
    _barrierEntry = null;
    _animationController = null;
    _isShown = false;
  }

  bool _isTickerProviderAlive(TickerProvider vsync) {
    if (vsync is State) {
      return (vsync as State).mounted;
    }
    return true;
  }
}
