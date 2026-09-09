import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/settings/logic/library_cache_controller.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_button.dart';
import 'package:ssf_flutter/src/ui_kit/layout/steam_page_header.dart';
import 'package:ssf_flutter/src/ui_kit/layout/steam_surface_card.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_notice.dart';

class const LibraryCacheTab({required final LibraryCacheController controller, super.key}) extends StatefulWidget {
  @override
  State<LibraryCacheTab> createState() => _LibraryCacheTabState();
}

class _LibraryCacheTabState() extends State<LibraryCacheTab> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.loadCount());
  }

  Future<void> _clear() async {
    final LibraryCacheClearResult? result = await widget.controller.clear();
    if (!mounted || result == null) {
      return;
    }
    final GeneratedLocalizations l10n = GeneratedLocalizations.of(context);
    showSteamNotice(context, switch (result) {
      LibraryCacheClearResult.cleared => l10n.libraryCacheCleared,
      LibraryCacheClearResult.failed => l10n.libraryCacheClearFailed,
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final LibraryCacheController cache = widget.controller;
      final GeneratedLocalizations l10n = GeneratedLocalizations.of(context);
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SteamSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SteamPageHeader(
                    eyebrow: l10n.storage,
                    title: l10n.libraryCache,
                    description: l10n.libraryCacheClearDescription,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    cache.loading
                        ? l10n.libraryCacheCounting
                        : cache.countFailed
                        ? l10n.libraryCacheCountUnavailable
                        : l10n.libraryCacheAppCount(cache.appCount ?? 0),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SteamButton(
                      variant: SteamButtonVariant.primary,
                      height: 32,
                      onPressed: cache.clearing ? null : () => unawaited(_clear()),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      child: Text(l10n.clearLibraryCache),
                    ),
                  ),
                  if (cache.clearing) ...[const SizedBox(height: 16), const LinearProgressIndicator(minHeight: 2)],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
