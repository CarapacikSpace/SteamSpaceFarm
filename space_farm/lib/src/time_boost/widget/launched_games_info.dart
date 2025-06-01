import 'package:flutter/material.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';

class LaunchedGamesInfo extends StatelessWidget {
  const LaunchedGamesInfo({
    required this.total,
    required this.batch,
    required this.onStopBatch,
    required this.onStopManual,
    super.key,
  });

  final int total;
  final int batch;
  final VoidCallback onStopBatch;
  final VoidCallback onStopManual;

  @override
  Widget build(BuildContext context) {
    final manual = total - batch;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            height: 32,
            child: Material(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFF7CB719),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('$total ${context.l10n.totalGamesCount}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 6),
                      Text(
                        '($batch ${context.l10n.autoStart}, $manual ${context.l10n.manualStart})',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: context.l10n.autoStop,
            onPressed: onStopBatch,
            icon: const Icon(Icons.power_settings_new, color: Color(0xFF1A9FFF)),
          ),
          IconButton(
            tooltip: context.l10n.manualStop,
            onPressed: onStopManual,
            icon: const Icon(Icons.power_settings_new, color: Color(0xFF7CB719)),
          ),
        ],
      ),
    );
  }
}
