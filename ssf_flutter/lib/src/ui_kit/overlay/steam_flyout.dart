import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class const SteamFlyout({
  required final bool isOpen,
  required final VoidCallback onClose,
  required final WidgetBuilder builder,
  required final Widget child,
  final Offset? position,
  final bool fillWidth = false,
  final bool submenu = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<SteamFlyout> createState() => _SteamFlyoutState();
}

class _SteamFlyoutState() extends State<SteamFlyout> {
  final _portal = OverlayPortalController();
  final _group = Object();
  ScrollNotificationObserverState? _scrollObserver;

  @override
  void initState() {
    super.initState();
    _syncVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollObserver?.removeListener(_onScroll);
    _scrollObserver = ScrollNotificationObserver.maybeOf(context);
    _scrollObserver?.addListener(_onScroll);
  }

  void _onScroll(ScrollNotification notification) {
    if (widget.isOpen && notification is ScrollUpdateNotification) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(SteamFlyout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      _syncVisibility();
    }
  }

  void _syncVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.isOpen ? _portal.show() : _portal.hide();
      }
    });
  }

  @override
  void dispose() {
    _scrollObserver?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _FlyoutGroup? parent = context.getInheritedWidgetOfExactType<_FlyoutGroup>();
    final Object group = parent?.group ?? _group;
    final VoidCallback dismiss = parent?.dismiss ?? widget.onClose;
    return _FlyoutGroup(
      group: group,
      dismiss: dismiss,
      child: OverlayPortal(
        overlayLocation: OverlayChildLocation.rootOverlay,
        controller: _portal,
        overlayChildBuilder: (overlayContext) {
          final target = context.findRenderObject()! as RenderBox;
          final overlay = Overlay.of(context, rootOverlay: true).context.findRenderObject()! as RenderBox;
          final Offset origin = target.localToGlobal(Offset.zero, ancestor: overlay);
          final Rect anchor = widget.position == null ? origin & target.size : (origin + widget.position!) & Size.zero;
          return CustomSingleChildLayout(
            delegate: _FlyoutLayout(anchor, fillWidth: widget.fillWidth, submenu: widget.submenu),
            child: TapRegion(
              groupId: group,
              consumeOutsideTaps: true,
              onTapOutside: (_) => dismiss(),
              child: FocusScope(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.escape ||
                      (widget.submenu && event.logicalKey == LogicalKeyboardKey.arrowLeft)) {
                    widget.onClose();
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    node.nextFocus();
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    node.previousFocus();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: SteamFlyoutReveal(child: widget.builder(overlayContext)),
              ),
            ),
          );
        },
        child: TapRegion(groupId: group, child: widget.child),
      ),
    );
  }
}

class const _FlyoutGroup({required final Object group, required final VoidCallback dismiss, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_FlyoutGroup oldWidget) => group != oldWidget.group || dismiss != oldWidget.dismiss;
}

class const SteamFlyoutReveal({required final Widget child, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 140),
    curve: Curves.easeOutCubic,
    builder: (_, value, child) => Opacity(
      opacity: value,
      child: Transform.scale(scale: .96 + .04 * value, alignment: Alignment.topLeft, child: child),
    ),
    child: child,
  );
}

class _FlyoutLayout(final Rect anchor, {required final bool fillWidth, required final bool submenu})
    extends SingleChildLayoutDelegate {
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double width = math.min(anchor.width, constraints.maxWidth);
    return BoxConstraints(
      minWidth: fillWidth ? width : 0,
      maxWidth: fillWidth ? width : constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = submenu ? anchor.right : anchor.left;
    double y = submenu ? anchor.top : anchor.bottom + 4;
    if (x + childSize.width > size.width) {
      final double flipped = submenu ? anchor.left - childSize.width : anchor.right - childSize.width;
      if (flipped >= 0) {
        x = flipped;
      }
    }
    if (y + childSize.height > size.height) {
      final double flipped = submenu ? anchor.bottom - childSize.height : anchor.top - childSize.height - 4;
      if (flipped >= 0) {
        y = flipped;
      }
    }
    return Offset(
      x.clamp(0, math.max(0, size.width - childSize.width)),
      y.clamp(0, math.max(0, size.height - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_FlyoutLayout oldDelegate) =>
      anchor != oldDelegate.anchor || fillWidth != oldDelegate.fillWidth || submenu != oldDelegate.submenu;
}
