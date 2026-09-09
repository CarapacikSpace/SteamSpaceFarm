import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'intl/messages_all.dart';

class GeneratedLocalizations {
  GeneratedLocalizations();

  static GeneratedLocalizations? _current;

  static GeneratedLocalizations get current {
    assert(
      _current != null,
      'No instance of GeneratedLocalizations was loaded. Try to initialize the GeneratedLocalizations delegate before accessing GeneratedLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<GeneratedLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = GeneratedLocalizations();
      GeneratedLocalizations._current = instance;

      return instance;
    });
  }

  static GeneratedLocalizations of(BuildContext context) {
    final instance = GeneratedLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of GeneratedLocalizations present in the widget tree. Did you add GeneratedLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static GeneratedLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<GeneratedLocalizations>(context, GeneratedLocalizations);
  }

  String get activeQueueMustStop {
    return Intl.message('Stop the active queue first.', name: 'activeQueueMustStop', desc: '', args: []);
  }

  String get addToFavorites {
    return Intl.message('Add to favorites', name: 'addToFavorites', desc: '', args: []);
  }

  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  String get allProcessesStopped {
    return Intl.message(
      'All games and Steam helper processes stopped.',
      name: 'allProcessesStopped',
      desc: '',
      args: [],
    );
  }

  String get allSequentially {
    return Intl.message('All sequentially', name: 'allSequentially', desc: '', args: []);
  }

  String get alphabetical {
    return Intl.message('Alphabetical', name: 'alphabetical', desc: '', args: []);
  }

  String appChangesSaveFailed(Object arg0) {
    return Intl.message('Could not save changes for $arg0', name: 'appChangesSaveFailed', desc: '', args: [arg0]);
  }

  String get appIdCopied {
    return Intl.message('AppID copied', name: 'appIdCopied', desc: '', args: []);
  }

  String get appIdInvalid {
    return Intl.message('Enter a valid AppID.', name: 'appIdInvalid', desc: '', args: []);
  }

  String get appLanguage {
    return Intl.message('App language', name: 'appLanguage', desc: '', args: []);
  }

  String get application {
    return Intl.message('Application', name: 'application', desc: '', args: []);
  }

  String get appLookupHint {
    return Intl.message('Name, AppID or Steam link', name: 'appLookupHint', desc: '', args: []);
  }

  String get applyTargets {
    return Intl.message('Apply targets', name: 'applyTargets', desc: '', args: []);
  }

  String get appType {
    return Intl.message('App type', name: 'appType', desc: '', args: []);
  }

  String appTypeRunningLabel(Object arg0) {
    return Intl.message('$arg0 · Running', name: 'appTypeRunningLabel', desc: '', args: [arg0]);
  }

  String get ascending {
    return Intl.message('Ascending', name: 'ascending', desc: '', args: []);
  }

  String get automatic {
    return Intl.message('automatic', name: 'automatic', desc: '', args: []);
  }

  String automaticAppsCount(Object arg0) {
    return Intl.message('auto $arg0', name: 'automaticAppsCount', desc: '', args: [arg0]);
  }

  String get autoStop {
    return Intl.message('Auto-stop', name: 'autoStop', desc: '', args: []);
  }

  String get bulkChangesSaveFailed {
    return Intl.message(
      'Could not save bulk changes. Please try again.',
      name: 'bulkChangesSaveFailed',
      desc: '',
      args: [],
    );
  }

  String get bulkTargets {
    return Intl.message('Bulk targets', name: 'bulkTargets', desc: '', args: []);
  }

  String get bulkTargetsDescription {
    return Intl.message(
      'Set auto-stop targets for the selected part of the catalog.',
      name: 'bulkTargetsDescription',
      desc: '',
      args: [],
    );
  }

  String get bulkTargetsInvalidRange {
    return Intl.message(
      'Check the values: the range must be valid and targets must be positive.',
      name: 'bulkTargetsInvalidRange',
      desc: '',
      args: [],
    );
  }

  String get bulkTargetsNoChanges {
    return Intl.message(
      'No apps would be changed by this operation.',
      name: 'bulkTargetsNoChanges',
      desc: '',
      args: [],
    );
  }

  String get byLastPlayed {
    return Intl.message('By last played', name: 'byLastPlayed', desc: '', args: []);
  }

  String get byPlaytime {
    return Intl.message('By playtime', name: 'byPlaytime', desc: '', args: []);
  }

  String get byTimeUntilTarget {
    return Intl.message('By time until target', name: 'byTimeUntilTarget', desc: '', args: []);
  }

  String get cache {
    return Intl.message('Cache', name: 'cache', desc: '', args: []);
  }

  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  String get cancelAction {
    return Intl.message('Cancel', name: 'cancelAction', desc: '', args: []);
  }

  String get cardType {
    return Intl.message('Card type', name: 'cardType', desc: '', args: []);
  }

  String get cardTypeAppIcon {
    return Intl.message('App icon 32×32', name: 'cardTypeAppIcon', desc: '', args: []);
  }

  String get cardTypeLibraryCapsule {
    return Intl.message('Library capsule', name: 'cardTypeLibraryCapsule', desc: '', args: []);
  }

  String get cardTypeMainCapsule {
    return Intl.message('Main capsule', name: 'cardTypeMainCapsule', desc: '', args: []);
  }

  String get cardTypeStoreHeader {
    return Intl.message('Store header', name: 'cardTypeStoreHeader', desc: '', args: []);
  }

  String get catalogEmptyDescription {
    return Intl.message(
      'Connect Steam to get your games and playtime.',
      name: 'catalogEmptyDescription',
      desc: '',
      args: [],
    );
  }

  String get catalogEmptyTitle {
    return Intl.message('Your local library is empty', name: 'catalogEmptyTitle', desc: '', args: []);
  }

  String get catalogEmptyWithSession {
    return Intl.message(
      'You are already signed in to Steam. Refresh your library to load your games and playtime.',
      name: 'catalogEmptyWithSession',
      desc: '',
      args: [],
    );
  }

  String get catalogNoResultsHint {
    return Intl.message('Change your search or filter settings.', name: 'catalogNoResultsHint', desc: '', args: []);
  }

  String get catalogReadFailed {
    return Intl.message('Could not read the local catalog', name: 'catalogReadFailed', desc: '', args: []);
  }

  String catalogResultsCount(Object arg0) {
    return Intl.message('$arg0 found', name: 'catalogResultsCount', desc: '', args: [arg0]);
  }

  String get catalogSearchHint {
    return Intl.message('Name or AppID', name: 'catalogSearchHint', desc: '', args: []);
  }

  String get clearAll {
    return Intl.message('Clear all', name: 'clearAll', desc: '', args: []);
  }

  String get clearAllTargetsAction {
    return Intl.message('Clear all targets', name: 'clearAllTargetsAction', desc: '', args: []);
  }

  String clearAllTargetsDescription(Object arg0) {
    return Intl.message(
      'Auto-stop targets will be removed from $arg0 apps across the entire library.',
      name: 'clearAllTargetsDescription',
      desc: '',
      args: [arg0],
    );
  }

  String get clearAllTargetsTitle {
    return Intl.message('Clear all targets?', name: 'clearAllTargetsTitle', desc: '', args: []);
  }

  String get clearLibraryCache {
    return Intl.message('Clear library cache', name: 'clearLibraryCache', desc: '', args: []);
  }

  String get clearTargets {
    return Intl.message('Clear targets', name: 'clearTargets', desc: '', args: []);
  }

  String get clearTargetsIgnoresFiltersHint {
    return Intl.message(
      'The current search and filters do not apply. You will be asked to confirm before targets are removed.',
      name: 'clearTargetsIgnoresFiltersHint',
      desc: '',
      args: [],
    );
  }

  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  String get concurrentApps {
    return Intl.message('Concurrent apps', name: 'concurrentApps', desc: '', args: []);
  }

  String concurrentLimitReached(Object arg0) {
    return Intl.message(
      'The concurrent app limit has been reached: $arg0.',
      name: 'concurrentLimitReached',
      desc: '',
      args: [arg0],
    );
  }

  String get confirmLaunch {
    return Intl.message('Confirm launch', name: 'confirmLaunch', desc: '', args: []);
  }

  String get connectSteam {
    return Intl.message('Connect Steam', name: 'connectSteam', desc: '', args: []);
  }

  String get copyAppId {
    return Intl.message('Copy AppID', name: 'copyAppId', desc: '', args: []);
  }

  String currentAppLabel(Object arg0) {
    return Intl.message('current: $arg0', name: 'currentAppLabel', desc: '', args: [arg0]);
  }

  String get currentPlaytime {
    return Intl.message('Current playtime', name: 'currentPlaytime', desc: '', args: []);
  }

  String get currentSelection {
    return Intl.message('Current selection', name: 'currentSelection', desc: '', args: []);
  }

  String get defaultDuration {
    return Intl.message('Default duration', name: 'defaultDuration', desc: '', args: []);
  }

  String get delayBetweenGames {
    return Intl.message('Delay between games', name: 'delayBetweenGames', desc: '', args: []);
  }

  String get demo {
    return Intl.message('Demo', name: 'demo', desc: '', args: []);
  }

  String get descending {
    return Intl.message('Descending', name: 'descending', desc: '', args: []);
  }

  String get detectAutomatically {
    return Intl.message('Detect automatically', name: 'detectAutomatically', desc: '', args: []);
  }

  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  String get edit {
    return Intl.message('Edit…', name: 'edit', desc: '', args: []);
  }

  String get editAutoStopTarget {
    return Intl.message('Edit auto-stop target', name: 'editAutoStopTarget', desc: '', args: []);
  }

  String get editCurrentPlaytime {
    return Intl.message('Edit current playtime', name: 'editCurrentPlaytime', desc: '', args: []);
  }

  String get editFilters {
    return Intl.message('Edit filters', name: 'editFilters', desc: '', args: []);
  }

  String get editingRequiresStoppedGames {
    return Intl.message(
      'Stop the running games and queue first.',
      name: 'editingRequiresStoppedGames',
      desc: '',
      args: [],
    );
  }

  String get eligibleApps {
    return Intl.message('Eligible apps', name: 'eligibleApps', desc: '', args: []);
  }

  String get emptyTargetClearsHint {
    return Intl.message('Leave empty to clear the target', name: 'emptyTargetClearsHint', desc: '', args: []);
  }

  String get enterCode {
    return Intl.message('Enter code', name: 'enterCode', desc: '', args: []);
  }

  String get entireLibrary {
    return Intl.message('Entire library', name: 'entireLibrary', desc: '', args: []);
  }

  String get entireLibraryOperationTitle {
    return Intl.message('Operation for the entire library', name: 'entireLibraryOperationTitle', desc: '', args: []);
  }

  String get favorites {
    return Intl.message('Favorites', name: 'favorites', desc: '', args: []);
  }

  String favoritesLaunchDescription(Object arg0) {
    return Intl.message(
      'All favorites in the current selection run in parallel, up to $arg0 at a time.',
      name: 'favoritesLaunchDescription',
      desc: '',
      args: [arg0],
    );
  }

  String get filters {
    return Intl.message('Filters', name: 'filters', desc: '', args: []);
  }

  String get game {
    return Intl.message('Game', name: 'game', desc: '', args: []);
  }

  String gameDeadlineUpdateFailed(Object arg0) {
    return Intl.message(
      'Could not update the stop time for $arg0.',
      name: 'gameDeadlineUpdateFailed',
      desc: '',
      args: [arg0],
    );
  }

  String gameLaunchFailed(Object arg0, Object arg1, Object arg2) {
    return Intl.message(
      'Could not launch $arg0 (AppID $arg1). $arg2',
      name: 'gameLaunchFailed',
      desc: '',
      args: [arg0, arg1, arg2],
    );
  }

  String gamePlaytimeSaveFailed(Object arg0, Object arg1) {
    return Intl.message(
      'Could not save playtime for $arg0 (AppID $arg1).',
      name: 'gamePlaytimeSaveFailed',
      desc: '',
      args: [arg0, arg1],
    );
  }

  String gameStopFailed(Object arg0, Object arg1) {
    return Intl.message(
      'Could not stop $arg0 (AppID $arg1). The process is still being monitored.',
      name: 'gameStopFailed',
      desc: '',
      args: [arg0, arg1],
    );
  }

  String get hidden {
    return Intl.message('Hidden', name: 'hidden', desc: '', args: []);
  }

  String get hours {
    return Intl.message('Hours', name: 'hours', desc: '', args: []);
  }

  String get hoursAbbreviation {
    return Intl.message('h', name: 'hoursAbbreviation', desc: '', args: []);
  }

  String get initializationFailed {
    return Intl.message('Initialization failed', name: 'initializationFailed', desc: '', args: []);
  }

  String get initializationFailureHint {
    return Intl.message(
      'Application components could not be prepared. Library data was not changed.',
      name: 'initializationFailureHint',
      desc: '',
      args: [],
    );
  }

  String get interface {
    return Intl.message('INTERFACE', name: 'interface', desc: '', args: []);
  }

  String get languageEnglish {
    return Intl.message('English', name: 'languageEnglish', desc: '', args: []);
  }

  String get languageRussian {
    return Intl.message('Russian', name: 'languageRussian', desc: '', args: []);
  }

  String get lastPlayed {
    return Intl.message('Last played', name: 'lastPlayed', desc: '', args: []);
  }

  String get launchAction {
    return Intl.message('Launch', name: 'launchAction', desc: '', args: []);
  }

  String get launchApps {
    return Intl.message('Launch apps', name: 'launchApps', desc: '', args: []);
  }

  String get launchConfirmationHint {
    return Intl.message(
      'Launch starts immediately after confirmation.',
      name: 'launchConfirmationHint',
      desc: '',
      args: [],
    );
  }

  String get launchMenuLabel {
    return Intl.message('LAUNCH', name: 'launchMenuLabel', desc: '', args: []);
  }

  String get launchOptionsAction {
    return Intl.message('Launch…', name: 'launchOptionsAction', desc: '', args: []);
  }

  String get launchOrder {
    return Intl.message('Launch order', name: 'launchOrder', desc: '', args: []);
  }

  String get launchUsesFiltersHint {
    return Intl.message(
      'Launch respects the search query and all active catalog filters.',
      name: 'launchUsesFiltersHint',
      desc: '',
      args: [],
    );
  }

  String get libraryCache {
    return Intl.message('Library cache', name: 'libraryCache', desc: '', args: []);
  }

  String libraryCacheAppCount(int count) {
    return Intl.plural(
      count,
      zero: 'No apps cached',
      one: '$count app cached',
      other: '$count apps cached',
      name: 'libraryCacheAppCount',
      desc: '',
      args: [count],
    );
  }

  String get libraryCacheClearDescription {
    return Intl.message(
      'Remove the downloaded game list, playtime, favorites and targets from SSF. Your Steam session will remain available for the next refresh.',
      name: 'libraryCacheClearDescription',
      desc: '',
      args: [],
    );
  }

  String get libraryCacheCleared {
    return Intl.message(
      'Library cache cleared. Your Steam session is saved.',
      name: 'libraryCacheCleared',
      desc: '',
      args: [],
    );
  }

  String get libraryCacheClearFailed {
    return Intl.message(
      'Could not clear the library cache. Please try again.',
      name: 'libraryCacheClearFailed',
      desc: '',
      args: [],
    );
  }

  String get libraryCacheCounting {
    return Intl.message('Counting cached apps…', name: 'libraryCacheCounting', desc: '', args: []);
  }

  String get libraryCacheCountUnavailable {
    return Intl.message(
      'Could not read the number of cached apps.',
      name: 'libraryCacheCountUnavailable',
      desc: '',
      args: [],
    );
  }

  String get librarySaveFailed {
    return Intl.message(
      'Could not save the library. Please refresh again.',
      name: 'librarySaveFailed',
      desc: '',
      args: [],
    );
  }

  String get librarySaving {
    return Intl.message('Saving the library to the catalog…', name: 'librarySaving', desc: '', args: []);
  }

  String libraryUpdated(Object arg0) {
    return Intl.message('Library updated: $arg0 apps.', name: 'libraryUpdated', desc: '', args: [arg0]);
  }

  String libraryUpdatedPartially(Object arg0) {
    return Intl.message(
      'Library updated: $arg0 apps. Some Steam data is unavailable.',
      name: 'libraryUpdatedPartially',
      desc: '',
      args: [arg0],
    );
  }

  String get lowPlaytimeDurationLabel {
    return Intl.message('If below 30 minutes', name: 'lowPlaytimeDurationLabel', desc: '', args: []);
  }

  String get manage {
    return Intl.message('Manage…', name: 'manage', desc: '', args: []);
  }

  String manualAppsCount(Object arg0) {
    return Intl.message('manual $arg0', name: 'manualAppsCount', desc: '', args: [arg0]);
  }

  String get manualLaunch {
    return Intl.message('Manual launch', name: 'manualLaunch', desc: '', args: []);
  }

  String get marked {
    return Intl.message('Marked', name: 'marked', desc: '', args: []);
  }

  String markedLaunchDescription(Object arg0) {
    return Intl.message(
      'Games with an unmet target run in parallel, up to $arg0 at a time.',
      name: 'markedLaunchDescription',
      desc: '',
      args: [arg0],
    );
  }

  String get maximum {
    return Intl.message('Maximum', name: 'maximum', desc: '', args: []);
  }

  String get maximumExclusive {
    return Intl.message('Maximum <', name: 'maximumExclusive', desc: '', args: []);
  }

  String get maximumTarget {
    return Intl.message('Maximum target', name: 'maximumTarget', desc: '', args: []);
  }

  String get milestoneTargetRulesHint {
    return Intl.message(
      'The next eligible target is set to an exact milestone minute. Games at the target or up to 5 minutes past it are not marked again.',
      name: 'milestoneTargetRulesHint',
      desc: '',
      args: [],
    );
  }

  String get minimum {
    return Intl.message('Minimum', name: 'minimum', desc: '', args: []);
  }

  String get minimumInclusive {
    return Intl.message('Minimum ≥', name: 'minimumInclusive', desc: '', args: []);
  }

  String get minimumTarget {
    return Intl.message('Minimum target', name: 'minimumTarget', desc: '', args: []);
  }

  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  String get minutesAbbreviation {
    return Intl.message('min', name: 'minutesAbbreviation', desc: '', args: []);
  }

  String get mode {
    return Intl.message('Mode', name: 'mode', desc: '', args: []);
  }

  String get moreActions {
    return Intl.message('More actions', name: 'moreActions', desc: '', args: []);
  }

  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  String get nonNegativeIntegerRequired {
    return Intl.message('Enter an integer of 0 or more', name: 'nonNegativeIntegerRequired', desc: '', args: []);
  }

  String get nothingFound {
    return Intl.message('Nothing found', name: 'nothingFound', desc: '', args: []);
  }

  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  String get optionalMaximumHint {
    return Intl.message('Optional — defaults to the maximum', name: 'optionalMaximumHint', desc: '', args: []);
  }

  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  String get ownership {
    return Intl.message('Ownership', name: 'ownership', desc: '', args: []);
  }

  String get ownershipFromSteamOnRefresh {
    return Intl.message('Use Steam data on the next refresh', name: 'ownershipFromSteamOnRefresh', desc: '', args: []);
  }

  String get ownershipNonPersonal {
    return Intl.message('Not mine / unknown', name: 'ownershipNonPersonal', desc: '', args: []);
  }

  String get ownershipPersonal {
    return Intl.message('Mine', name: 'ownershipPersonal', desc: '', args: []);
  }

  String get ownershipPersonalFilter {
    return Intl.message('Mine', name: 'ownershipPersonalFilter', desc: '', args: []);
  }

  String get ownershipUnknown {
    return Intl.message('Unknown', name: 'ownershipUnknown', desc: '', args: []);
  }

  String get ownershipUnknownFilter {
    return Intl.message('Unknown', name: 'ownershipUnknownFilter', desc: '', args: []);
  }

  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  String get playtime {
    return Intl.message('Playtime', name: 'playtime', desc: '', args: []);
  }

  String get playtimeClearsReachedTargetHint {
    return Intl.message(
      'The new playtime reaches the current auto-stop target, so the target will be cleared.',
      name: 'playtimeClearsReachedTargetHint',
      desc: '',
      args: [],
    );
  }

  String playtimeHours(Object arg0) {
    return Intl.message('$arg0 h', name: 'playtimeHours', desc: '', args: [arg0]);
  }

  String playtimeHoursApproximate(Object arg0) {
    return Intl.message('≈ $arg0 h', name: 'playtimeHoursApproximate', desc: '', args: [arg0]);
  }

  String get playtimeInMinutes {
    return Intl.message('Playtime in minutes', name: 'playtimeInMinutes', desc: '', args: []);
  }

  String get playtimeMilestones {
    return Intl.message('Playtime milestones', name: 'playtimeMilestones', desc: '', args: []);
  }

  String playtimeMinutes(Object arg0) {
    return Intl.message('$arg0 min', name: 'playtimeMinutes', desc: '', args: [arg0]);
  }

  String get playtimeMinutesExample {
    return Intl.message('For example, 120', name: 'playtimeMinutesExample', desc: '', args: []);
  }

  String get positiveIntegerRequired {
    return Intl.message('Enter a positive integer', name: 'positiveIntegerRequired', desc: '', args: []);
  }

  String queuedAppsCount(Object arg0) {
    return Intl.message('queued $arg0', name: 'queuedAppsCount', desc: '', args: [arg0]);
  }

  String queuePausedLabel(Object arg0) {
    return Intl.message('$arg0 · paused', name: 'queuePausedLabel', desc: '', args: [arg0]);
  }

  String get range {
    return Intl.message('Range', name: 'range', desc: '', args: []);
  }

  String get refreshLibrary {
    return Intl.message('Refresh library', name: 'refreshLibrary', desc: '', args: []);
  }

  String get refreshQrCode {
    return Intl.message('Refresh QR code', name: 'refreshQrCode', desc: '', args: []);
  }

  String get removeFromFavorites {
    return Intl.message('Remove from favorites', name: 'removeFromFavorites', desc: '', args: []);
  }

  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  String get resetAll {
    return Intl.message('Reset all', name: 'resetAll', desc: '', args: []);
  }

  String get resume {
    return Intl.message('Resume', name: 'resume', desc: '', args: []);
  }

  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  String get runnerAccountMismatch {
    return Intl.message(
      'Make sure the SSF library and Steam client use the same account.',
      name: 'runnerAccountMismatch',
      desc: '',
      args: [],
    );
  }

  String get runnerCleanupFailed {
    return Intl.message(
      'Could not enable automatic cleanup of game processes. Restart SSF and try again.',
      name: 'runnerCleanupFailed',
      desc: '',
      args: [],
    );
  }

  String get runnerLaunchUnconfirmed {
    return Intl.message('SteamAPI did not confirm the launch.', name: 'runnerLaunchUnconfirmed', desc: '', args: []);
  }

  String get runnerLibraryRequired {
    return Intl.message('Load your Steam account library first.', name: 'runnerLibraryRequired', desc: '', args: []);
  }

  String get runnerUpdateRequired {
    return Intl.message('Rebuild or update ssf_game alongside SSF.', name: 'runnerUpdateRequired', desc: '', args: []);
  }

  String runningAppsCount(Object arg0, Object arg1) {
    return Intl.message('Running $arg0/$arg1', name: 'runningAppsCount', desc: '', args: [arg0, arg1]);
  }

  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  String get searchByName {
    return Intl.message('Search by name', name: 'searchByName', desc: '', args: []);
  }

  String get secondsAbbreviation {
    return Intl.message('sec', name: 'secondsAbbreviation', desc: '', args: []);
  }

  String get selectAValue {
    return Intl.message('Select a value', name: 'selectAValue', desc: '', args: []);
  }

  String get selectionHasNoEligibleApps {
    return Intl.message(
      'No eligible apps in the current selection.',
      name: 'selectionHasNoEligibleApps',
      desc: '',
      args: [],
    );
  }

  String get sequentialLaunchDescription {
    return Intl.message(
      'The entire current selection runs one app at a time.',
      name: 'sequentialLaunchDescription',
      desc: '',
      args: [],
    );
  }

  String get sequentialQueue {
    return Intl.message('Sequential queue', name: 'sequentialQueue', desc: '', args: []);
  }

  String get sequentialQueueBlocksManualLaunch {
    return Intl.message(
      'Manual launch is unavailable while a sequential queue is active.',
      name: 'sequentialQueueBlocksManualLaunch',
      desc: '',
      args: [],
    );
  }

  String get sequentialQueueRequiresStoppedGames {
    return Intl.message(
      'Stop the running apps before starting a sequential queue.',
      name: 'sequentialQueueRequiresStoppedGames',
      desc: '',
      args: [],
    );
  }

  String get sequentialStartAppId {
    return Intl.message('Start from AppID', name: 'sequentialStartAppId', desc: '', args: []);
  }

  String get sequentialTimingInvalid {
    return Intl.message(
      'Duration must be at least 1 second and the delay must be 0 or more.',
      name: 'sequentialTimingInvalid',
      desc: '',
      args: [],
    );
  }

  String get setOwnership {
    return Intl.message('Set ownership', name: 'setOwnership', desc: '', args: []);
  }

  String get setTargets {
    return Intl.message('Set targets…', name: 'setTargets', desc: '', args: []);
  }

  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  String get settingsAppearance {
    return Intl.message('Appearance', name: 'settingsAppearance', desc: '', args: []);
  }

  String get settingsCardPreviewHint {
    return Intl.message(
      'Select a tile to apply that card format to the catalog immediately.',
      name: 'settingsCardPreviewHint',
      desc: '',
      args: [],
    );
  }

  String get settingsImmediateSaveHint {
    return Intl.message(
      'Changes are saved immediately and do not require an Apply button.',
      name: 'settingsImmediateSaveHint',
      desc: '',
      args: [],
    );
  }

  String get settingsIntegrationsSteam {
    return Intl.message('Integrations · Steam', name: 'settingsIntegrationsSteam', desc: '', args: []);
  }

  String get settingsLanguage {
    return Intl.message('Language', name: 'settingsLanguage', desc: '', args: []);
  }

  String get settingsSaved {
    return Intl.message('Settings saved', name: 'settingsSaved', desc: '', args: []);
  }

  String get settingsSaveError {
    return Intl.message('The setting could not be saved.', name: 'settingsSaveError', desc: '', args: []);
  }

  String get settingsSaving {
    return Intl.message('Saving…', name: 'settingsSaving', desc: '', args: []);
  }

  String get signIn {
    return Intl.message('Sign in', name: 'signIn', desc: '', args: []);
  }

  String get signOut {
    return Intl.message('Sign out', name: 'signOut', desc: '', args: []);
  }

  String get sortBy {
    return Intl.message('Sort by', name: 'sortBy', desc: '', args: []);
  }

  String get soundtrack {
    return Intl.message('Soundtrack', name: 'soundtrack', desc: '', args: []);
  }

  String get startAppNotInSelection {
    return Intl.message(
      'The specified AppID was not found in the current sorted selection.',
      name: 'startAppNotInSelection',
      desc: '',
      args: [],
    );
  }

  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  String get statusRunning {
    return Intl.message('Running', name: 'statusRunning', desc: '', args: []);
  }

  String get steamAccountName {
    return Intl.message('Steam account name', name: 'steamAccountName', desc: '', args: []);
  }

  String get steamAuthInputFailed {
    return Intl.message('Could not send the response to Steam', name: 'steamAuthInputFailed', desc: '', args: []);
  }

  String get steamConnecting {
    return Intl.message('Connecting to Steam…', name: 'steamConnecting', desc: '', args: []);
  }

  String get steamConnection {
    return Intl.message('Steam connection', name: 'steamConnection', desc: '', args: []);
  }

  String get steamCredentialsChecking {
    return Intl.message('Checking Steam credentials…', name: 'steamCredentialsChecking', desc: '', args: []);
  }

  String get steamCredentialsRequired {
    return Intl.message(
      'Enter your Steam account name and password',
      name: 'steamCredentialsRequired',
      desc: '',
      args: [],
    );
  }

  String get steamCredentialsTitle {
    return Intl.message('Sign in with your account name', name: 'steamCredentialsTitle', desc: '', args: []);
  }

  String get steamFamilyLibraryLoading {
    return Intl.message('Loading the Steam Family library…', name: 'steamFamilyLibraryLoading', desc: '', args: []);
  }

  String get steamGuardAppPrompt {
    return Intl.message(
      'Enter the Steam Guard code from the Steam app',
      name: 'steamGuardAppPrompt',
      desc: '',
      args: [],
    );
  }

  String get steamGuardChecking {
    return Intl.message('Checking Steam Guard code…', name: 'steamGuardChecking', desc: '', args: []);
  }

  String get steamGuardCode {
    return Intl.message('Steam Guard code', name: 'steamGuardCode', desc: '', args: []);
  }

  String get steamGuardEmailLabel {
    return Intl.message('Code from your Steam email', name: 'steamGuardEmailLabel', desc: '', args: []);
  }

  String get steamGuardEmailPrompt {
    return Intl.message(
      'Enter the Steam Guard code from your email',
      name: 'steamGuardEmailPrompt',
      desc: '',
      args: [],
    );
  }

  String get steamGuardSubmit {
    return Intl.message('Confirm code', name: 'steamGuardSubmit', desc: '', args: []);
  }

  String get steamHelperProtocolError {
    return Intl.message(
      'Invalid response from the library helper',
      name: 'steamHelperProtocolError',
      desc: '',
      args: [],
    );
  }

  String get steamHelperReadFailed {
    return Intl.message(
      'Could not read the library helper response',
      name: 'steamHelperReadFailed',
      desc: '',
      args: [],
    );
  }

  String get steamHelperStartFailed {
    return Intl.message(
      'Could not start the library helper. Make sure ssf_steam_helper.exe is installed alongside SSF.',
      name: 'steamHelperStartFailed',
      desc: '',
      args: [],
    );
  }

  String get steamHelperStopUnconfirmed {
    return Intl.message(
      'Could not confirm that the process stopped. Try cancelling again.',
      name: 'steamHelperStopUnconfirmed',
      desc: '',
      args: [],
    );
  }

  String get steamId {
    return Intl.message('SteamID', name: 'steamId', desc: '', args: []);
  }

  String steamLibraryFailedWithCode(Object arg0) {
    return Intl.message(
      'Signed in. Could not get the library (code $arg0).',
      name: 'steamLibraryFailedWithCode',
      desc: '',
      args: [arg0],
    );
  }

  String get steamLibraryLoading {
    return Intl.message('Signed in. Loading the library…', name: 'steamLibraryLoading', desc: '', args: []);
  }

  String get steamLibraryMerging {
    return Intl.message('Combining library data…', name: 'steamLibraryMerging', desc: '', args: []);
  }

  String get steamLibraryPartialStatus {
    return Intl.message(
      'Signed in. Library data is partially available.',
      name: 'steamLibraryPartialStatus',
      desc: '',
      args: [],
    );
  }

  String get steamLibraryReceived {
    return Intl.message('Signed in. Library received.', name: 'steamLibraryReceived', desc: '', args: []);
  }

  String get steamLibraryTimeout {
    return Intl.message(
      'Signed in, but the library request timed out.',
      name: 'steamLibraryTimeout',
      desc: '',
      args: [],
    );
  }

  String get steamMetadataLoading {
    return Intl.message('Loading app names and types…', name: 'steamMetadataLoading', desc: '', args: []);
  }

  String get steamMobileConfirmationPrompt {
    return Intl.message(
      'Approve the sign-in in the Steam app on your phone',
      name: 'steamMobileConfirmationPrompt',
      desc: '',
      args: [],
    );
  }

  String get steamPersonalLibraryLoading {
    return Intl.message('Loading licenses and your apps…', name: 'steamPersonalLibraryLoading', desc: '', args: []);
  }

  String get steamPlaytimeUpdating {
    return Intl.message('Updating playtime…', name: 'steamPlaytimeUpdating', desc: '', args: []);
  }

  String get steamPrivateAppsChecking {
    return Intl.message('Checking private apps…', name: 'steamPrivateAppsChecking', desc: '', args: []);
  }

  String get steamQrAccessibilityLabel {
    return Intl.message(
      'QR code for signing in with Steam Mobile',
      name: 'steamQrAccessibilityLabel',
      desc: '',
      args: [],
    );
  }

  String get steamQrInstructions {
    return Intl.message(
      'Use the Steam mobile app to sign in with a QR code',
      name: 'steamQrInstructions',
      desc: '',
      args: [],
    );
  }

  String get steamQrScanPrompt {
    return Intl.message(
      'Scan the QR code in Steam Mobile and approve the sign-in',
      name: 'steamQrScanPrompt',
      desc: '',
      args: [],
    );
  }

  String get steamQrTitle {
    return Intl.message('Or use a QR code', name: 'steamQrTitle', desc: '', args: []);
  }

  String get steamSessionActive {
    return Intl.message('You already have an active session', name: 'steamSessionActive', desc: '', args: []);
  }

  String get steamSessionChecking {
    return Intl.message('Checking the saved session…', name: 'steamSessionChecking', desc: '', args: []);
  }

  String get steamSessionPrivacyHint {
    return Intl.message(
      'Your password is not saved. The protected session is used for future refreshes without signing in again.',
      name: 'steamSessionPrivacyHint',
      desc: '',
      args: [],
    );
  }

  String get steamSessionReadFailed {
    return Intl.message('Could not read the saved session', name: 'steamSessionReadFailed', desc: '', args: []);
  }

  String get steamSignedOutCacheCleared {
    return Intl.message('Signed out. Library cache cleared.', name: 'steamSignedOutCacheCleared', desc: '', args: []);
  }

  String get steamSignedOutStatus {
    return Intl.message(
      'Signed out of Steam. Choose a sign-in method.',
      name: 'steamSignedOutStatus',
      desc: '',
      args: [],
    );
  }

  String get steamSignInCancelled {
    return Intl.message('Sign-in cancelled', name: 'steamSignInCancelled', desc: '', args: []);
  }

  String get steamSignInCancelling {
    return Intl.message('Cancelling sign-in…', name: 'steamSignInCancelling', desc: '', args: []);
  }

  String steamSignInFailedWithCode(Object arg0) {
    return Intl.message(
      'Could not sign in (code $arg0). Please try again.',
      name: 'steamSignInFailedWithCode',
      desc: '',
      args: [arg0],
    );
  }

  String get steamSigningOut {
    return Intl.message('Signing out and clearing the cache…', name: 'steamSigningOut', desc: '', args: []);
  }

  String get steamSignInMethodPrompt {
    return Intl.message('Choose a sign-in method', name: 'steamSignInMethodPrompt', desc: '', args: []);
  }

  String get steamSignInTimeout {
    return Intl.message('Sign-in timed out', name: 'steamSignInTimeout', desc: '', args: []);
  }

  String get steamSignOutFailed {
    return Intl.message(
      'Could not finish signing out. Please try again.',
      name: 'steamSignOutFailed',
      desc: '',
      args: [],
    );
  }

  String steamSyncFailed(Object arg0) {
    return Intl.message('Sign-in or library request failed: $arg0', name: 'steamSyncFailed', desc: '', args: [arg0]);
  }

  String get stopAction {
    return Intl.message('Stop', name: 'stopAction', desc: '', args: []);
  }

  String get stopAll {
    return Intl.message('Stop all', name: 'stopAll', desc: '', args: []);
  }

  String get stopAllProcessesDescription {
    return Intl.message(
      'All games and Steam helper processes started by this SteamSpaceFarm instance will be stopped. Queued launches and library refresh will be cancelled.',
      name: 'stopAllProcessesDescription',
      desc: '',
      args: [],
    );
  }

  String get stopAllProcessesFailed {
    return Intl.message('Could not force stop the processes.', name: 'stopAllProcessesFailed', desc: '', args: []);
  }

  String get stopAllProcessesTitle {
    return Intl.message('Force stop everything?', name: 'stopAllProcessesTitle', desc: '', args: []);
  }

  String get stopBatchQueueDescription {
    return Intl.message(
      'The queue will be cleared and the apps it launched will be stopped.',
      name: 'stopBatchQueueDescription',
      desc: '',
      args: [],
    );
  }

  String get stopManualApps {
    return Intl.message('Stop manual apps', name: 'stopManualApps', desc: '', args: []);
  }

  String stopManualAppsCount(Object arg0) {
    return Intl.message('Stop manual apps · $arg0', name: 'stopManualAppsCount', desc: '', args: [arg0]);
  }

  String stopManualAppsDescription(Object arg0) {
    return Intl.message(
      'Apps launched manually in this session will be stopped: $arg0.',
      name: 'stopManualAppsDescription',
      desc: '',
      args: [arg0],
    );
  }

  String get stopManualAppsTitle {
    return Intl.message('Stop manually launched apps?', name: 'stopManualAppsTitle', desc: '', args: []);
  }

  String get stopMenuLabel {
    return Intl.message('STOP', name: 'stopMenuLabel', desc: '', args: []);
  }

  String get stopQueue {
    return Intl.message('Stop queue', name: 'stopQueue', desc: '', args: []);
  }

  String get stopQueueTitle {
    return Intl.message('Stop the active queue?', name: 'stopQueueTitle', desc: '', args: []);
  }

  String stopSequentialQueueDescription(Object arg0) {
    return Intl.message(
      'The current app will stop and the remaining $arg0 entries will be removed.',
      name: 'stopSequentialQueueDescription',
      desc: '',
      args: [arg0],
    );
  }

  String get storage {
    return Intl.message('STORAGE', name: 'storage', desc: '', args: []);
  }

  String targetAlreadyReachedHint(Object arg0) {
    return Intl.message(
      'Current playtime is $arg0 min. This target will be cleared because it has already been reached.',
      name: 'targetAlreadyReachedHint',
      desc: '',
      args: [arg0],
    );
  }

  String get targetPlaytime {
    return Intl.message('Target playtime', name: 'targetPlaytime', desc: '', args: []);
  }

  String get targetPlaytimeInMinutes {
    return Intl.message('Target playtime in minutes', name: 'targetPlaytimeInMinutes', desc: '', args: []);
  }

  String get targetRangeBoundsHint {
    return Intl.message(
      'Targets apply to apps from the minimum playtime inclusive to the maximum exclusive.',
      name: 'targetRangeBoundsHint',
      desc: '',
      args: [],
    );
  }

  String get technicalDetails {
    return Intl.message('Technical details', name: 'technicalDetails', desc: '', args: []);
  }

  String get timeUntilTarget {
    return Intl.message('Time until target', name: 'timeUntilTarget', desc: '', args: []);
  }

  String get tool {
    return Intl.message('Tool', name: 'tool', desc: '', args: []);
  }

  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<GeneratedLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en'), Locale.fromSubtags(languageCode: 'ru')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<GeneratedLocalizations> load(Locale locale) => GeneratedLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
