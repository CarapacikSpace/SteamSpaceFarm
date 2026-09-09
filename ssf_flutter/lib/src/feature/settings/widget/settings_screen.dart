import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/settings/logic/library_cache_controller.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/appearance_settings_tab.dart';
import 'package:ssf_flutter/src/feature/settings/widget/library_cache_tab.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_navigation.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';
import 'package:ssf_flutter/src/feature/steam/widget/steam_integration_view.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_notice.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

class const SettingsScreen({
  required final SteamProcessManager processManager,
  required final IAppsRepository appsRepository,
  required final Future<void> Function() onLibraryUpdated,
  final bool openSteam = false,
  final bool refreshSteamLibrary = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState() extends State<SettingsScreen> {
  late SettingsSection _section;
  late bool _refreshSteamLibrary;
  late final _cache = LibraryCacheController(
    repository: widget.appsRepository,
    onLibraryUpdated: widget.onLibraryUpdated,
  );

  @override
  void initState() {
    super.initState();
    _refreshSteamLibrary = widget.refreshSteamLibrary;
    _section = widget.openSteam ? SettingsSection.steam : SettingsSection.appearance;
  }

  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }

  void _selectSection(SettingsSection section) {
    setState(() {
      _section = section;
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: SteamLibraryBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool expanded = constraints.maxWidth >= 840;
              final Widget content = switch (_section) {
                SettingsSection.appearance => AppearanceSettingsTab(
                  settings: settings,
                  isSaving: state.isSaving,
                  error: state.error,
                  onChanged: (value) => unawaited(_save(value)),
                  onRetry: () => unawaited(_save(state.failedSettings ?? settings)),
                ),
                SettingsSection.steam => SteamIntegrationView(
                  processManager: widget.processManager,
                  appsRepository: widget.appsRepository,
                  onLibraryUpdated: widget.onLibraryUpdated,
                  restoreSession: true,
                  embedded: true,
                  refreshExistingSession: _refreshSteamLibrary,
                ),
                SettingsSection.cache => LibraryCacheTab(controller: _cache),
              };
              if (!expanded) {
                return content;
              }
              return Row(
                children: [
                  SettingsSideNavigation(
                    selected: _section,
                    extended: constraints.maxWidth >= 1080,
                    onSelected: _selectSection,
                  ),
                  Expanded(child: content),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 840
          ? SettingsBottomNavigation(selected: _section, onSelected: _selectSection)
          : null,
    );
  }
}
