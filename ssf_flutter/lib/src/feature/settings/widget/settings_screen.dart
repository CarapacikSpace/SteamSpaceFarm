import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/settings/logic/library_cache_controller.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/appearance_settings_tab.dart';
import 'package:ssf_flutter/src/feature/settings/widget/library_cache_tab.dart';
import 'package:ssf_flutter/src/feature/settings/widget/session_settings_tab.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_navigation.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_controller.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/widget/steam_integration_view.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/layout/steam_layout_breakpoints.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_notice.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

class const SettingsScreen({
  required final SteamProcessManager processManager,
  required final IAppsRepository appsRepository,
  required final Future<void> Function() onLibraryUpdated,
  final bool openSteam = false,
  final bool refreshSteamLibrary = false,
  final SteamLibraryController? backgroundLibrary,
  final SteamLibrarySyncController? steamController,
  super.key,
}) extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState() extends State<SettingsScreen> {
  final _steamKey = GlobalKey<SteamIntegrationViewState>();
  bool _selecting = false;
  late SettingsSection _section;
  late bool _refreshSteamLibrary;
  late bool _steamVisited;

  bool get _libraryUpdating =>
      (widget.backgroundLibrary?.sync.busy ?? false) ||
      (widget.backgroundLibrary?.saving ?? false) ||
      (_steamKey.currentState?.updatingLibrary ?? false);
  late final _cache = LibraryCacheController(
    repository: widget.appsRepository,
    onLibraryUpdated: widget.onLibraryUpdated,
  );

  @override
  void initState() {
    super.initState();
    _refreshSteamLibrary = widget.refreshSteamLibrary;
    _section = widget.openSteam ? SettingsSection.steam : SettingsSection.appearance;
    _steamVisited = widget.openSteam;
  }

  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }

  Future<void> _selectSection(SettingsSection section) async {
    if (_selecting || section == _section || (_libraryUpdating && section != SettingsSection.appearance)) {
      return;
    }
    _selecting = true;
    final bool leave =
        (_libraryUpdating && section == SettingsSection.appearance) ||
        await (_steamKey.currentState?.confirmLeave() ?? Future.value(true));
    _selecting = false;
    if (!leave || !mounted) {
      return;
    }
    setState(() {
      _section = section;
      _steamVisited = _steamVisited || section == SettingsSection.steam;
      _refreshSteamLibrary = false;
    });
  }

  Future<void> _save(AppSettings settings) async {
    final bool saved = await SettingsScope.of(context, listen: false).update((_) => settings);

    await WidgetsBinding.instance.endOfFrame;
    if (mounted && saved) {
      showSteamNotice(context, context.l10n.settingsSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsScopeState state = SettingsScope.of(context);
    final AppSettings settings = state.settings;
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.processManager,
        if (widget.backgroundLibrary != null) widget.backgroundLibrary!,
      ]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.settings)),
        body: SteamLibraryBackground(
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool expanded = constraints.maxWidth >= SteamLayoutBreakpoints.expanded;
                final Widget selectedContent = switch (_section) {
                  SettingsSection.appearance => AppearanceSettingsTab(
                    settings: settings,
                    isSaving: state.isSaving,
                    error: state.error,
                    onChanged: (value) => unawaited(_save(value)),
                    onRetry: () => unawaited(_save(state.failedSettings ?? settings)),
                  ),
                  SettingsSection.sessions => SessionSettingsTab(
                    settings: settings,
                    isSaving: state.isSaving,
                    error: state.error,
                    onChanged: (value) => unawaited(_save(value)),
                    onRetry: () => unawaited(_save(state.failedSettings ?? settings)),
                    gamesActive: widget.processManager.hasActiveGames,
                  ),
                  SettingsSection.steam => const SizedBox.shrink(),
                  SettingsSection.cache => LibraryCacheTab(controller: _cache),
                };
                // Keep an active Steam update mounted when Appearance is selected.
                final content = Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_steamVisited)
                      Offstage(
                        offstage: _section != SettingsSection.steam,
                        child: SteamIntegrationView(
                          key: _steamKey,
                          controller: widget.steamController,
                          processManager: widget.processManager,
                          appsRepository: widget.appsRepository,
                          onLibraryUpdated: widget.onLibraryUpdated,
                          onLibraryActivityChanged: () {
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          restoreSession: true,
                          embedded: true,
                          refreshExistingSession: _refreshSteamLibrary,
                        ),
                      ),
                    if (_section != SettingsSection.steam) selectedContent,
                  ],
                );
                if (!expanded) {
                  return content;
                }
                return Row(
                  children: [
                    SettingsSideNavigation(
                      selected: _section,
                      extended: constraints.maxWidth >= SteamLayoutBreakpoints.large,
                      onSelected: _selectSection,
                      appearanceOnly: _libraryUpdating,
                    ),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: MediaQuery.sizeOf(context).width < SteamLayoutBreakpoints.expanded
            ? SettingsBottomNavigation(selected: _section, onSelected: _selectSection, appearanceOnly: _libraryUpdating)
            : null,
      ),
    );
  }
}
