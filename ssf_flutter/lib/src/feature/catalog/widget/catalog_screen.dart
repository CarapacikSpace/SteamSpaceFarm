import 'dart:async';

import 'package:flutter/rendering.dart' show SliverConstraints, SliverGridLayout, SliverGridRegularTileLayout;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/logic/app_sorting.dart';
import 'package:ssf_flutter/src/feature/catalog/logic/catalog_controller.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/catalog/model/time_filter_type.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/bulk_action_dialogs.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_app_card.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_app_context_menu.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_app_edit_dialogs.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_filter_sheet.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/beautiful_hours.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_execution_controller.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/beautiful_hours_configuration.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/bulk_actions.dart';
import 'package:ssf_flutter/src/feature/game_execution/widget/game_execution_panel.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_screen.dart';
import 'package:ssf_flutter/src/feature/steam/data/steam_session_store.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';
import 'package:ssf_flutter/src/utils/optional.dart';

enum _CatalogSort() {
  playtime,
  name,
  lastPlayed,
  remaining,
}

class const CatalogScreen({
  required final IAppsRepository appsRepository,
  required final SteamGameService steamGameService,
  required final AppSettings settings,
  final Future<bool> Function()? sessionExists,
  super.key,
}) extends StatefulWidget {
  static const searchKey = Key('catalog-search');
  static const filtersKey = Key('catalog-filters');
  static const catalogKey = Key('catalog-grid');

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState() extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final CatalogController _catalogController;
  late final GameExecutionController _executionController;
  late final Listenable _screenListenable;
  CatalogFilterState _filters = CatalogFilterState.initial();
  CatalogStatus _status = CatalogStatus.all;
  _CatalogSort _sort = _CatalogSort.playtime;
  late SteamAppCardType _cardType;
  bool _useHours = true;
  int _concurrentLimit = 30;
  bool _ascending = false;
  bool _bulkActionBusy = false;
  BeautifulHoursConfiguration _beautifulHoursConfiguration = BeautifulHoursConfiguration.defaults;
  final Set<int> _savingAppIds = <int>{};

  @override
  void initState() {
    super.initState();
    _cardType = widget.settings.cardType;
    _catalogController = CatalogController(
      appsRepository: widget.appsRepository,
      sessionExists: widget.sessionExists ?? () => SteamSessionStore().exists(),
    );
    _executionController = GameExecutionController(
      appsRepository: widget.appsRepository,
      steamGameService: widget.steamGameService,
      catalogController: _catalogController,
      onUserError: _showMessage,
    );
    _screenListenable = Listenable.merge([_catalogController, _executionController]);
    _searchFocusNode.addListener(_handleSearchFocusChanged);
    unawaited(_catalogController.loadCache());
  }

  void _handleSearchFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant CatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.cardType != widget.settings.cardType) {
      _cardType = widget.settings.cardType;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode
      ..removeListener(_handleSearchFocusChanged)
      ..dispose();
    _executionController.dispose();
    _catalogController.dispose();
    super.dispose();
  }

  List<LocalApp> get _visibleApps {
    final String query = _searchController.text.trim().toLowerCase();
    final List<LocalApp> result = _catalogController.apps.where((app) {
      final bool matchesQuery = _matchesQuery(app, query);
      final bool matchesStatus = switch (_status) {
        CatalogStatus.all => true,
        CatalogStatus.running => _executionController.isRunning(app.appId),
        CatalogStatus.marked => app.stopAtMinutes != null && (app.playtimeMinutes ?? 0) < app.stopAtMinutes!,
        CatalogStatus.hidden => app.isHidden,
        CatalogStatus.favorite => app.isFavorite,
      };
      final bool matchesOwnership = _filters.ownership.contains(app.libraryOwnership);
      final int? playtime = app.playtimeMinutes;
      final bool matchesMinimum =
          _filters.minimumMinutes == null || (playtime != null && playtime >= _filters.minimumMinutes!);
      final bool matchesMaximum =
          _filters.maximumMinutes == null || (playtime != null && playtime < _filters.maximumMinutes!);
      return matchesQuery &&
          matchesStatus &&
          matchesOwnership &&
          matchesMinimum &&
          matchesMaximum &&
          _filters.selectedTypes.contains(app.type);
    }).toList();

    return result..sort(
      (left, right) => compareLocalApps(
        left,
        right,
        key: _sort.sortKey,
        direction: _ascending ? SortDirection.ascending : SortDirection.descending,
      ),
    );
  }

  static bool _matchesQuery(LocalApp app, String query) {
    if (query.isEmpty || app.name.toLowerCase().contains(query) || '${app.appId}'.contains(query)) {
      return true;
    }

    final RegExpMatch? steamUrlMatch = RegExp(r'/app/(\d+)', caseSensitive: false).firstMatch(query);
    return steamUrlMatch?.group(1) == '${app.appId}';
  }

  Future<void> _showFilters() async {
    await showSteamFilterSurface<void>(
      context: context,
      builder: (surfaceContext) => CatalogFilterSheet(
        initialState: _filters,
        status: _status,
        useHours: _useHours,
        onChanged: (value) => setState(() => _filters = value),
        onStatusChanged: (value) => setState(() => _status = value),
        onUseHoursChanged: (value) => setState(() => _useHours = value),
        onClose: () => Navigator.pop(surfaceContext),
      ),
    );
  }

  bool get _hasCatalogFilterOverrides =>
      _searchController.text.trim().isNotEmpty || _status != CatalogStatus.all || _filters.activeGroupCount > 0;

  void _resetCatalogFilters() {
    _searchController.clear();
    setState(() {
      _filters = CatalogFilterState.initial();
      _status = CatalogStatus.all;
      _useHours = true;
    });
  }

  Future<void> _showBulkLaunch() async {
    if (_executionController.isQueueActive) {
      await _confirmStopQueue();
      return;
    }
    final visibleApps = List<LocalApp>.of(_visibleApps);
    final BulkLaunchRequest? request = await showBulkLaunchDialog(
      context: context,
      visibleApps: visibleApps,
      initialOrder: switch (_sort) {
        _CatalogSort.playtime => BulkLaunchOrder.playtime,
        _CatalogSort.name => BulkLaunchOrder.name,
        _CatalogSort.lastPlayed => BulkLaunchOrder.lastPlayed,
        _CatalogSort.remaining => BulkLaunchOrder.remainingMarkedTime,
      },
      initialDirection: _ascending ? SortDirection.ascending : SortDirection.descending,
      concurrentLimit: _concurrentLimit,
    );
    if (request == null || !mounted) {
      return;
    }
    setState(() => _concurrentLimit = request.concurrentLimit);
    _executionController.updateConcurrentLimit(request.concurrentLimit);
    final List<LocalApp> candidates = selectBulkLaunchCandidates(request: request, filteredCatalogApps: visibleApps);
    final String? rejection = await _executionController.startBulk(request, candidates);
    if (rejection != null && mounted) {
      _showMessage(rejection);
    }
  }

  Future<void> _toggleAppExecution(LocalApp app) async {
    final String? rejection = await _executionController.toggleApp(app);
    if (rejection != null && mounted) {
      _showMessage(rejection);
    }
  }

  Future<void> _confirmStopQueue() async {
    final bool confirmed = await _showConfirmation(
      title: GeneratedLocalizations.of(context).stopQueueTitle,
      message: _executionController.isSequentialActive
          ? GeneratedLocalizations.of(context).stopSequentialQueueDescription(_executionController.queueRemaining)
          : GeneratedLocalizations.of(context).stopBatchQueueDescription,
      confirmText: GeneratedLocalizations.of(context).stopQueue,
    );
    if (confirmed && mounted) {
      await _executionController.stopQueue();
    }
  }

  Future<void> _confirmStopManualApps() async {
    final int count = _executionController.manualRunningCount;
    if (count == 0) {
      return;
    }
    final bool confirmed = await _showConfirmation(
      title: GeneratedLocalizations.of(context).stopManualAppsTitle,
      message: GeneratedLocalizations.of(context).stopManualAppsDescription(count),
      confirmText: GeneratedLocalizations.of(context).stopManualApps,
    );
    if (confirmed && mounted) {
      await _executionController.stopManualApps();
    }
  }

  Future<void> _confirmHardStop() async {
    final bool confirmed = await _showConfirmation(
      title: GeneratedLocalizations.of(context).stopAllProcessesTitle,
      message: GeneratedLocalizations.of(context).stopAllProcessesDescription,
      confirmText: GeneratedLocalizations.of(context).stopAll,
    );
    if (!confirmed || !mounted) {
      return;
    }
    try {
      await _executionController.hardStop();
      if (mounted) {
        _showMessage(GeneratedLocalizations.of(context).allProcessesStopped);
      }
    } on Object {
      if (mounted) {
        _showMessage(GeneratedLocalizations.of(context).stopAllProcessesFailed);
      }
    }
  }

  Future<bool> _showConfirmation({required String title, required String message, required String confirmText}) =>
      showSteamConfirmationDialog(context: context, title: title, message: message, confirmText: confirmText);

  void _showMessage(String message) {
    showSteamNotice(context, message);
  }

  Future<void> _showBulkMark() async {
    final visibleApps = List<LocalApp>.of(_visibleApps);
    final BulkMarkRequest? request = await showBulkMarkDialog(
      context: context,
      visibleApps: visibleApps,
      allApps: List<LocalApp>.of(_catalogController.apps),
      initialUnit: _useHours ? TimeFilterType.hours : TimeFilterType.minutes,
      initialBeautifulHours: _beautifulHoursConfiguration,
    );
    if (request == null || !mounted) {
      return;
    }

    final List<LocalApp> updatedApps = switch (request) {
      RangeBulkMarkRequest() =>
        visibleApps
            .where((app) {
              final int? minutes = app.playtimeMinutes;
              return minutes != null && minutes >= request.minimumMinutes && minutes < request.maximumMinutes;
            })
            .map((app) {
              final int target = request.targetMinutes ?? request.maximumMinutes;
              return app.copyWith(stopAtMinutes: Optional.of((app.playtimeMinutes ?? 0) >= target ? null : target));
            })
            .toList(),
      BeautifulHoursBulkMarkRequest() =>
        visibleApps
            .map((app) {
              final int? target = BeautifulHours.nextTargetMinutes(app.playtimeMinutes ?? 0, request.configuration);
              return target == null ? null : app.copyWith(stopAtMinutes: Optional.of(target));
            })
            .whereType<LocalApp>()
            .toList(),
      ClearMarksBulkRequest() =>
        _catalogController.apps
            .where((app) => app.stopAtMinutes != null)
            .map((app) => app.copyWith(stopAtMinutes: const Optional.of(null)))
            .toList(),
    };

    setState(() => _bulkActionBusy = true);
    try {
      await _catalogController.updateApps(updatedApps);
      if (mounted) {
        if (request case BeautifulHoursBulkMarkRequest(:final configuration)) {
          setState(() => _beautifulHoursConfiguration = configuration);
        }
      }
    } on Object {
      if (mounted) {
        showSteamNotice(context, GeneratedLocalizations.of(context).bulkChangesSaveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _bulkActionBusy = false);
      }
    }
  }

  bool _canChangeLibrary() {
    if (_executionController.runningCount > 0 || _executionController.isQueueActive || _executionController.isBusy) {
      showSteamNotice(context, GeneratedLocalizations.of(context).editingRequiresStoppedGames);
      return false;
    }
    return true;
  }

  Future<void> _openSettings({bool steam = false, bool refreshLibrary = false}) async {
    if (!_canChangeLibrary()) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          processManager: widget.steamGameService.processManager,
          appsRepository: widget.appsRepository,
          onLibraryUpdated: _catalogController.loadCache,
          openSteam: steam,
          refreshSteamLibrary: refreshLibrary,
        ),
      ),
    );
  }

  Future<void> _showTouchAppActions(LocalApp app) async {
    await showDialog<void>(
      context: context,
      builder: (sheetContext) => SteamDialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(app.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('AppID ${app.appId}'),
                trailing: IconButton(
                  tooltip: GeneratedLocalizations.of(context).close,
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  _executionController.isRunning(app.appId) ? Icons.stop : Icons.play_arrow,
                  color: _executionController.isRunning(app.appId) ? const Color(0xFF66C0F4) : const Color(0xFF8AC329),
                ),
                title: Text(
                  _executionController.isRunning(app.appId)
                      ? GeneratedLocalizations.of(context).stopAction
                      : GeneratedLocalizations.of(context).launchAction,
                ),
                onTap: () => _closeTouchMenu(sheetContext, app, CatalogAppMenuAction.run),
              ),
              ListTile(
                leading: Icon(app.isFavorite ? Icons.star : Icons.star_outline),
                title: Text(
                  app.isFavorite
                      ? GeneratedLocalizations.of(context).removeFromFavorites
                      : GeneratedLocalizations.of(context).addToFavorites,
                ),
                onTap: () => _closeTouchMenu(sheetContext, app, CatalogAppMenuAction.favorite),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(GeneratedLocalizations.of(context).editCurrentPlaytime),
                onTap: () => _closeTouchMenu(sheetContext, app, CatalogAppMenuAction.currentTime),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(GeneratedLocalizations.of(context).editAutoStopTarget),
                onTap: () => _closeTouchMenu(sheetContext, app, CatalogAppMenuAction.stopTime),
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(GeneratedLocalizations.of(context).setOwnership),
                onTap: () => _closeTouchMenu(sheetContext, app, CatalogAppMenuAction.ownership),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(GeneratedLocalizations.of(context).copyAppId),
                onTap: () => _closeTouchMenu(sheetContext, app, CatalogAppMenuAction.copyAppId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _closeTouchMenu(BuildContext sheetContext, LocalApp app, CatalogAppMenuAction action) {
    Navigator.pop(sheetContext);
    unawaited(_performAppAction(app, action));
  }

  Future<void> _performAppAction(LocalApp app, CatalogAppMenuAction action) async {
    if (_savingAppIds.contains(app.appId)) {
      return;
    }
    switch (action) {
      case CatalogAppMenuAction.run:
        await _toggleAppExecution(app);
        return;
      case CatalogAppMenuAction.favorite:
        await _saveApp(app.copyWith(isFavorite: !app.isFavorite));
        return;
      case CatalogAppMenuAction.currentTime:
        final int? minutes = await showCurrentTimeDialog(context, app);
        if (minutes != null && mounted) {
          final bool goalReached = app.stopAtMinutes != null && minutes >= app.stopAtMinutes!;
          await _saveApp(
            app.copyWith(
              playtimeMinutes: minutes,
              stopAtMinutes: goalReached ? const Optional.of(null) : const Optional.absent(),
            ),
          );
        }
        return;
      case CatalogAppMenuAction.stopTime:
        final AutoStopDraft? draft = await showAutoStopDialog(context, app);
        if (draft != null && mounted) {
          await _saveApp(app.copyWith(stopAtMinutes: Optional.of(draft.minutes)));
        }
        return;
      case CatalogAppMenuAction.ownership:
        final OwnershipSelection? ownership = await showOwnershipDialog(context, app);
        if (ownership != null && mounted) {
          final LocalApp updatedApp = switch (ownership) {
            OwnershipSelection.automatic => app.copyWith(isLibraryOwnershipManual: false),
            OwnershipSelection.personal => app.copyWith(
              libraryOwnership: LibraryOwnership.personal,
              isLibraryOwnershipManual: true,
            ),
            OwnershipSelection.family => app.copyWith(
              libraryOwnership: LibraryOwnership.family,
              isLibraryOwnershipManual: true,
            ),
            OwnershipSelection.unknown => app.copyWith(
              libraryOwnership: LibraryOwnership.unknown,
              isLibraryOwnershipManual: true,
            ),
          };
          await _saveApp(updatedApp);
        }
        return;
      case CatalogAppMenuAction.copyAppId:
        await Clipboard.setData(ClipboardData(text: '${app.appId}'));
        if (mounted) {
          showSteamNotice(context, GeneratedLocalizations.of(context).appIdCopied);
        }
        return;
    }
  }

  Future<void> _saveApp(LocalApp updatedApp) async {
    if (!_savingAppIds.add(updatedApp.appId)) {
      return;
    }
    setState(() {});
    try {
      await _catalogController.updateApp(updatedApp);
    } on Object {
      if (mounted) {
        showSteamNotice(context, GeneratedLocalizations.of(context).appChangesSaveFailed(updatedApp.name));
      }
    } finally {
      _savingAppIds.remove(updatedApp.appId);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildAppCard(LocalApp app) {
    final bool isRunning = _executionController.isRunning(app.appId);
    final bool isBusy =
        _savingAppIds.contains(app.appId) || _executionController.isAppBusy(app.appId) || _executionController.isBusy;
    return CatalogAppContextMenu(
      app: app,
      isRunning: isRunning,
      isBusy: isBusy,
      onActionSelected: (action) => unawaited(_performAppAction(app, action)),
      childBuilder: (openMenu) {
        final bool touchLayout = MediaQuery.sizeOf(context).width < 600;
        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              ignoring: isBusy,
              child: CatalogAppCard(
                app: app,
                cardType: _cardType,
                useHours: _useHours,
                isRunning: isRunning,
                onTap: () => unawaited(_toggleAppExecution(app)),
                onMenuRequested: touchLayout ? () => _showTouchAppActions(app) : openMenu,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: LayoutBuilder(
        builder: (context, constraints) {
          const title = 'STEAM SPACE FARM';
          final double titleWidth = TextPainter.computeWidth(
            text: TextSpan(text: title, style: DefaultTextStyle.of(context).style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.localeOf(context),
            maxLines: 1,
          );
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/app_logo_transparent.png', width: 32, height: 32, semanticLabel: title),
              if (constraints.maxWidth >= 32 + 4 + titleWidth) ...[
                const SizedBox(width: 4),
                const ExcludeSemantics(child: Text(title, maxLines: 1)),
              ],
            ],
          );
        },
      ),
      actions: [
        _HeaderActionButton(
          tooltip: GeneratedLocalizations.of(context).refreshLibrary,
          onPressed: () => unawaited(_openSettings(steam: true, refreshLibrary: true)),
          icon: const Icon(Icons.sync),
        ),
        const SizedBox(width: 4),
        _HeaderActionButton(
          tooltip: GeneratedLocalizations.of(context).settings,
          onPressed: () => unawaited(_openSettings()),
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 4),
        _HeaderActionButton(
          tooltip: GeneratedLocalizations.of(context).stopAll,
          onPressed: () => unawaited(_confirmHardStop()),
          icon: const Icon(Icons.power_settings_new),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: SteamLibraryBackground(
      child: ListenableBuilder(
        listenable: _screenListenable,
        builder: (context, _) => Column(
          children: [
            GameExecutionPanel(
              controller: _executionController,
              onTogglePause: _executionController.toggleQueuePause,
              onStopQueue: () => unawaited(_confirmStopQueue()),
              onStopManual: () => unawaited(_confirmStopManualApps()),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool compact = constraints.maxWidth < 600;
                  final double horizontalPadding = compact ? 12 : 20;
                  final List<LocalApp> apps = _visibleApps;
                  final Widget cards = CustomScrollView(
                    key: CatalogScreen.catalogKey,
                    slivers: [
                      if (_catalogController.isLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_catalogController.error case final Object error)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _CatalogError(error: error, onRetry: _catalogController.loadCache),
                        )
                      else if (_catalogController.apps.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyLibrary(
                            hasSession: _catalogController.hasSession,
                            onOpenSteam: () =>
                                unawaited(_openSettings(steam: true, refreshLibrary: _catalogController.hasSession)),
                          ),
                        )
                      else if (apps.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyCatalog(onEditFilters: _showFilters, onResetFilters: _resetCatalogFilters),
                        )
                      else if (_cardType == SteamAppCardType.appIcon)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: compact ? 8 : 10),
                                child: SizedBox(height: 60, child: _buildAppCard(apps[index])),
                              );
                            }, childCount: apps.length),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 24),
                          sliver: SliverGrid(
                            gridDelegate: _FixedCardGridDelegate(
                              cardWidth: switch (_cardType) {
                                SteamAppCardType.libraryCapsule => 170,
                                SteamAppCardType.mainCapsule || SteamAppCardType.storeHeader => 170,
                                SteamAppCardType.appIcon => 170,
                              },
                              cardHeight: switch (_cardType) {
                                SteamAppCardType.libraryCapsule => 275,
                                SteamAppCardType.mainCapsule => 173,
                                SteamAppCardType.storeHeader => 155,
                                SteamAppCardType.appIcon => 60,
                              },
                              minimumSpacing: compact ? 10 : 14,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildAppCard(apps[index]),
                              childCount: apps.length,
                            ),
                          ),
                        ),
                    ],
                  );
                  final Widget catalog = Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 10),
                        child: _buildControls(compact: compact, resultCount: apps.length),
                      ),
                      Expanded(child: cards),
                    ],
                  );
                  return catalog;
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildControls({required bool compact, required int resultCount}) {
    final int activeFilterCount = _filters.activeGroupCount + (_status == CatalogStatus.all ? 0 : 1);
    final Widget search = Row(
      children: [
        Expanded(
          child: SteamSearchField(
            height: SteamUiMetrics.catalogControlHeight,
            key: CatalogScreen.searchKey,
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: compact
                ? GeneratedLocalizations.of(context).catalogSearchHint
                : GeneratedLocalizations.of(context).appLookupHint,
            onChanged: (_) => setState(() {}),
            onSearchPressed: _searchFocusNode.unfocus,
          ),
        ),
        const SizedBox(width: 6),
        Badge.count(
          count: activeFilterCount,
          isLabelVisible: activeFilterCount > 0,
          backgroundColor: SteamUiColors.accent,
          textColor: Colors.white,
          child: Tooltip(
            message: GeneratedLocalizations.of(context).filters,
            child: SteamButton(
              key: CatalogScreen.filtersKey,
              compact: true,
              iconOnly: true,
              height: SteamUiMetrics.catalogControlHeight,
              onPressed: _showFilters,
              icon: const Icon(Icons.filter_list, size: 18),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );

    final Widget controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SteamDropdown<_CatalogSort>(
          height: SteamUiMetrics.catalogControlHeight,
          width: compact ? 190 : 220,
          items: _CatalogSort.values,
          value: _sort,
          labelBuilder: _sortLabel,
          onChanged: (value) => setState(() => _sort = value),
        ),
        Tooltip(
          message: _ascending
              ? GeneratedLocalizations.of(context).ascending
              : GeneratedLocalizations.of(context).descending,
          child: SteamButton(
            compact: true,
            iconOnly: true,
            height: SteamUiMetrics.catalogControlHeight,
            onPressed: () => setState(() => _ascending = !_ascending),
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 17),
            child: const SizedBox.shrink(),
          ),
        ),
        SteamButton(
          onPressed: _bulkActionBusy || _executionController.isBusy ? null : _showBulkMark,
          height: SteamUiMetrics.catalogControlHeight,
          icon: const Icon(Icons.flag_outlined),
          child: Text(GeneratedLocalizations.of(context).setTargets),
        ),
        SteamButton(
          variant: _executionController.isQueueActive ? SteamButtonVariant.primary : SteamButtonVariant.run,
          height: SteamUiMetrics.catalogControlHeight,
          onPressed: _bulkActionBusy || _executionController.isBusy ? null : _showBulkLaunch,
          icon: Icon(_executionController.isQueueActive ? Icons.tune : Icons.play_arrow),
          child: Text(
            _executionController.isQueueActive
                ? GeneratedLocalizations.of(context).manage
                : GeneratedLocalizations.of(context).launchOptionsAction,
          ),
        ),
        Text(
          GeneratedLocalizations.of(context).catalogResultsCount(resultCount),
          maxLines: 1,
          style: const TextStyle(color: SteamThemeColors.textSecondary, fontSize: 12),
        ),
        if (_hasCatalogFilterOverrides)
          SizedBox(
            height: SteamUiMetrics.catalogControlHeight,
            child: SteamTextButton(
              onPressed: _resetCatalogFilters,
              leading: const Icon(Icons.restart_alt, size: 16),
              child: Text(GeneratedLocalizations.of(context).reset),
            ),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [search, const SizedBox(height: 8), controls],
    );
  }

  static String _sortLabel(_CatalogSort sort) => switch (sort) {
    _CatalogSort.playtime => GeneratedLocalizations.current.byPlaytime,
    _CatalogSort.name => GeneratedLocalizations.current.alphabetical,
    _CatalogSort.lastPlayed => GeneratedLocalizations.current.byLastPlayed,
    _CatalogSort.remaining => GeneratedLocalizations.current.byTimeUntilTarget,
  };
}

extension on _CatalogSort {
  AppSortKey get sortKey => switch (this) {
    _CatalogSort.playtime => AppSortKey.playtime,
    _CatalogSort.name => AppSortKey.name,
    _CatalogSort.lastPlayed => AppSortKey.lastPlayed,
    _CatalogSort.remaining => AppSortKey.remainingMarkedTime,
  };
}

class const _HeaderActionButton({
  required final String tooltip,
  required final VoidCallback onPressed,
  required final Widget icon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SteamButton(
      compact: true,
      iconOnly: true,
      height: 36,
      onPressed: onPressed,
      icon: icon,
      child: const SizedBox.shrink(),
    ),
  );
}

class const _FixedCardGridDelegate({
  required final double cardWidth,
  required final double cardHeight,
  required final double minimumSpacing,
}) extends SliverGridDelegate {
  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double effectiveCardWidth = cardWidth > constraints.crossAxisExtent ? constraints.crossAxisExtent : cardWidth;
    final int count = ((constraints.crossAxisExtent + minimumSpacing) / (effectiveCardWidth + minimumSpacing)).floor();
    final crossAxisCount = count < 1 ? 1 : count;
    final double availableForSpacing = constraints.crossAxisExtent - (effectiveCardWidth * crossAxisCount);
    final double crossAxisSpacing = crossAxisCount == 1 ? 0 : availableForSpacing / (crossAxisCount - 1);
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: cardHeight + minimumSpacing,
      crossAxisStride: effectiveCardWidth + crossAxisSpacing,
      childMainAxisExtent: cardHeight,
      childCrossAxisExtent: effectiveCardWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(covariant _FixedCardGridDelegate oldDelegate) =>
      cardWidth != oldDelegate.cardWidth ||
      cardHeight != oldDelegate.cardHeight ||
      minimumSpacing != oldDelegate.minimumSpacing;
}

class const _EmptyCatalog({required final VoidCallback onEditFilters, required final VoidCallback onResetFilters})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 54, color: Color(0xFF8D9BAB)),
          const SizedBox(height: 16),
          Text(GeneratedLocalizations.of(context).nothingFound, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            GeneratedLocalizations.of(context).catalogNoResultsHint,
            style: const TextStyle(color: Color(0xFF8D9BAB)),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              SteamButton(
                onPressed: onEditFilters,
                icon: const Icon(Icons.tune),
                child: Text(GeneratedLocalizations.of(context).editFilters),
              ),
              SteamButton(
                variant: SteamButtonVariant.primary,
                onPressed: onResetFilters,
                icon: const Icon(Icons.restart_alt),
                child: Text(GeneratedLocalizations.of(context).resetAll),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class const _EmptyLibrary({required final VoidCallback onOpenSteam, required final bool hasSession})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.video_library_outlined, size: 54, color: Color(0xFF8D9BAB)),
          const SizedBox(height: 16),
          Text(GeneratedLocalizations.of(context).catalogEmptyTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            hasSession
                ? GeneratedLocalizations.of(context).catalogEmptyWithSession
                : GeneratedLocalizations.of(context).catalogEmptyDescription,
            style: const TextStyle(color: Color(0xFF8D9BAB)),
          ),
          const SizedBox(height: 20),
          SteamButton(
            variant: SteamButtonVariant.primary,
            onPressed: onOpenSteam,
            icon: Icon(hasSession ? Icons.sync : Icons.link),
            child: Text(
              hasSession
                  ? GeneratedLocalizations.of(context).refreshLibrary
                  : GeneratedLocalizations.of(context).connectSteam,
            ),
          ),
        ],
      ),
    ),
  );
}

class const _CatalogError({required final Object error, required final Future<void> Function() onRetry})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 54, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(GeneratedLocalizations.of(context).catalogReadFailed, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8D9BAB)),
          ),
          const SizedBox(height: 20),
          SteamButton(
            variant: SteamButtonVariant.primary,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            child: Text(GeneratedLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}
