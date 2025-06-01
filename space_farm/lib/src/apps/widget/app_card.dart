import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind, kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, FilteringTextInputFormatter;
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/apps/model/card_type.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/model/optional.dart';
import 'package:space_farm/src/apps/widget/header_app_card.dart';
import 'package:space_farm/src/apps/widget/icon_app_card_content.dart';
import 'package:space_farm/src/apps/widget/library_app_card.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/settings/widget/settings_scope.dart';
import 'package:space_farm/src/shared/elevated_button.dart';
import 'package:space_farm/src/shared/filled_button.dart';
import 'package:space_farm/src/shared/text_field.dart';
import 'package:space_farm/src/time_boost/logic/pop_up_menu_controller.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.app,
    required this.onTap,
    required this.timeFilterType,
    required this.onUpdateApp,
    this.isRunning = false,
    this.cardType,
    super.key,
  });

  final LocalApp app;
  final bool isRunning;
  final ValueChanged<LocalApp> onTap;
  final ValueChanged<LocalApp> onUpdateApp;
  final TimeFilterType timeFilterType;
  final SteamAppCardType? cardType;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with TickerProviderStateMixin {
  late final IAppsRepository _appsRepository = context.dependencies.appsRepository;

  @override
  Widget build(BuildContext context) {
    return switch (widget.cardType ?? SettingsScope.settingsOf(context).cardType) {
      SteamAppCardType.header => HeaderAppCardContent(
        app: widget.app,
        onTap: () => widget.onTap.call(widget.app),
        isRunning: widget.isRunning,
        onRightClick: (event) async => _handleRightClick(event),
        timeFilterType: widget.timeFilterType,
      ),
      SteamAppCardType.library => LibraryAppCardContent(
        app: widget.app,
        onTap: () => widget.onTap.call(widget.app),
        isRunning: widget.isRunning,
        onRightClick: (event) async => _handleRightClick(event),
        timeFilterType: widget.timeFilterType,
      ),
      SteamAppCardType.icon => IconAppCardContent(
        app: widget.app,
        onTap: () => widget.onTap.call(widget.app),
        isRunning: widget.isRunning,
        onRightClick: (event) async => _handleRightClick(event),
        timeFilterType: widget.timeFilterType,
      ),
    };
  }

  @override
  void dispose() {
    unawaited(PopUpMenuController.instance.hide());
    super.dispose();
  }

  Future<void> _handleRightClick(PointerDownEvent event) async {
    if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
      await PopUpMenuController.instance.show(
        context: context,
        vsync: this,
        position: event.position,
        items: [
          MenuItem(
            text: widget.app.isFavorite ? context.l10n.actionRemoveFromFavorites : context.l10n.actionAddToFavorites,
            onTap: () async => _toggleFavorite(),
          ),
          MenuItem(text: context.l10n.actionChangePlaytime, onTap: () => _showSetTimeDialog(widget.app)),
          MenuItem(text: context.l10n.actionChangeStopTime, onTap: () => _showAutoStopDialog(widget.app)),
          MenuItem(
            text: context.l10n.actionCopyId,
            onTap: () => Clipboard.setData(ClipboardData(text: widget.app.appId.toString())),
          ),
        ],
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final updated = widget.app.copyWith(isFavorite: !widget.app.isFavorite);
    widget.onUpdateApp.call(updated);
    await _appsRepository.updateApp(updated);
  }

  Future<void> _showSetTimeDialog(LocalApp app) async {
    final controller = TextEditingController(text: '${app.playtimeMinutes ?? 0}');
    final result = await showDialog<int?>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF171D25),
        surfaceTintColor: const Color(0xFF171D25),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.changeTimeForGame(app.name),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.timeInMinutes, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                SteamTextField(
                  controller: controller,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  hintText: context.l10n.timeInMinutes,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SteamElevatedButton(
                        onPressed: () {
                          final minutes = int.tryParse(controller.text.trim());
                          if (minutes != null && minutes >= 0) {
                            Navigator.of(context).pop(minutes);
                          }
                        },
                        child: Text(context.l10n.save, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SteamFilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancel, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();

    if (result != null) {
      final updated = app.copyWith(playtimeMinutes: result);
      widget.onUpdateApp.call(updated);
      await _appsRepository.updateApp(updated);
    }
  }

  Future<void> _showAutoStopDialog(LocalApp app) async {
    final controller = TextEditingController(text: app.stopAtMinutes?.toString() ?? '');

    final result = await showDialog<int?>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF171D25),
        surfaceTintColor: const Color(0xFF171D25),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.changeStopTimeForGame(app.name),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.timeInMinutes, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                SteamTextField(
                  controller: controller,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  hintText: context.l10n.timeInMinutes,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SteamElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) {
                            Navigator.of(context).pop();
                          } else {
                            final minutes = int.tryParse(text);
                            if (minutes != null && minutes > 0) {
                              Navigator.of(context).pop(minutes);
                            }
                          }
                        },
                        child: Text(context.l10n.save, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SteamFilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancel, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.dispose();

    if (result != null || controller.text.trim().isEmpty) {
      final currentMinutes = app.playtimeMinutes ?? 0;
      final stopAtMinutes = (result != null && result > currentMinutes) ? Optional.of(result) : const Optional.of(null);

      final updated = app.copyWith(stopAtMinutes: stopAtMinutes);
      widget.onUpdateApp.call(updated);
      await _appsRepository.updateApp(updated);
    }
  }
}

class MenuItem extends StatefulWidget {
  const MenuItem({required this.text, required this.onTap, super.key});

  final String text;
  final VoidCallback onTap;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isHovered = false;

  Future<void> _handleTap() async {
    await PopUpMenuController.instance.hide();
    widget.onTap.call();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isHovered ? const Color(0xFFDCDEDF) : Colors.transparent;
    final textColor = _isHovered ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(color: backgroundColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.text, style: TextStyle(color: textColor)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
