import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class LibraryAppCardContent extends StatelessWidget {
  const LibraryAppCardContent({
    required this.app,
    required this.onTap,
    required this.isRunning,
    required this.onRightClick,
    required this.timeFilterType,
    super.key,
  });

  final LocalApp app;
  final TimeFilterType timeFilterType;
  final bool isRunning;
  final VoidCallback onTap;
  final void Function(PointerDownEvent event) onRightClick;

  @override
  Widget build(BuildContext context) {
    final time = app.playtimeMinutes == null
        ? null
        : timeFilterType == TimeFilterType.hours
        ? '${app.hours.toStringAsFixed(1)} ${context.l10n.hoursShort}'
        : '${app.playtimeMinutes} ${context.l10n.minutesShort}';

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: isRunning ? const Color(0xFF7CB719) : Colors.transparent),
              borderRadius: BorderRadius.circular(2),
            ),
            shadowColor: isRunning ? const Color(0xFF7CB719) : Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: onRightClick,
              child: InkWell(
                onTap: onTap,
                child: AspectRatio(
                  aspectRatio: 6 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Image.network(
                          app.headerUrl,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (_, _, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                app.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Image.network(
                        app.libraryUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(app.headerUrl, fit: BoxFit.fill),
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 30),
                                child: const ColoredBox(color: Colors.black12),
                              ),
                              Center(
                                child: Image.network(
                                  app.headerUrl,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        app.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black45,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                app.type.localizedText(context),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (time != null)
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Material(
                  color: const Color(0xFF3D4450),
                  elevation: 16,
                  shadowColor: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ),
            ),
          ),
        if (app.stopAtMinutes != null)
          Positioned(
            right: 4,
            top: 4,
            child: IgnorePointer(
              child: Material(
                color: const Color(0xFF1A9FFF),
                elevation: 16,
                shadowColor: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Text(
                    timeFilterType == TimeFilterType.hours
                        ? '${(app.stopAtMinutes! / 60).toStringAsFixed(1)} ${context.l10n.hoursShort}'
                        : '${app.stopAtMinutes} ${context.l10n.minutesShort}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
