// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GeneratedLocalizationsEn extends GeneratedLocalizations {
  GeneratedLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activeQueueMustStop => 'Stop the active queue first.';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get all => 'All';

  @override
  String get allProcessesStopped => 'All games and Steam helper processes stopped.';

  @override
  String get allSequentially => 'All sequentially';

  @override
  String get alphabetical => 'Alphabetical';

  @override
  String appChangesSaveFailed(Object arg0) {
    return 'Could not save changes for $arg0';
  }

  @override
  String get appIdCopied => 'AppID copied';

  @override
  String get appIdInvalid => 'Enter a valid AppID.';

  @override
  String get appLanguage => 'App language';

  @override
  String get application => 'Application';

  @override
  String get appLookupHint => 'Name, AppID or Steam link';

  @override
  String get applyTargets => 'Apply targets';

  @override
  String get appType => 'App type';

  @override
  String appTypeRunningLabel(Object arg0) {
    return '$arg0 · Running';
  }

  @override
  String get ascending => 'Ascending';

  @override
  String get automatic => 'automatic';

  @override
  String automaticAppsCount(Object arg0) {
    return 'auto $arg0';
  }

  @override
  String get autoStop => 'Auto-stop';

  @override
  String get bulkChangesSaveFailed => 'Could not save bulk changes. Please try again.';

  @override
  String get bulkTargets => 'Bulk targets';

  @override
  String get bulkTargetsDescription => 'Set auto-stop targets for the selected part of the catalog.';

  @override
  String get bulkTargetsInvalidRange => 'Check the values: the range must be valid and targets must be positive.';

  @override
  String get bulkTargetsNoChanges => 'No apps would be changed by this operation.';

  @override
  String get byLastPlayed => 'By last played';

  @override
  String get byPlaytime => 'By playtime';

  @override
  String get byTimeUntilTarget => 'By time until target';

  @override
  String get cache => 'Cache';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get cardType => 'Card type';

  @override
  String get cardTypeAppIcon => 'App icon 32×32';

  @override
  String get cardTypeLibraryCapsule => 'Library capsule';

  @override
  String get cardTypeMainCapsule => 'Main capsule';

  @override
  String get cardTypeStoreHeader => 'Store header';

  @override
  String get catalogEmptyDescription => 'Connect Steam to get your games and playtime.';

  @override
  String get catalogEmptyTitle => 'Your local library is empty';

  @override
  String get catalogEmptyWithSession =>
      'You are already signed in to Steam. Refresh your library to load your games and playtime.';

  @override
  String get catalogNoResultsHint => 'Change your search or filter settings.';

  @override
  String get catalogReadFailed => 'Could not read the local catalog';

  @override
  String catalogResultsCount(Object arg0) {
    return '$arg0 found';
  }

  @override
  String get catalogSearchHint => 'Name or AppID';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearAllTargetsAction => 'Clear all targets';

  @override
  String clearAllTargetsDescription(Object arg0) {
    return 'Auto-stop targets will be removed from $arg0 apps across the entire library.';
  }

  @override
  String get clearAllTargetsTitle => 'Clear all targets?';

  @override
  String get clearLibraryCache => 'Clear library cache';

  @override
  String get clearTargets => 'Clear targets';

  @override
  String get clearTargetsIgnoresFiltersHint =>
      'The current search and filters do not apply. You will be asked to confirm before targets are removed.';

  @override
  String get close => 'Close';

  @override
  String get concurrentApps => 'Concurrent apps';

  @override
  String concurrentLimitReached(Object arg0) {
    return 'The concurrent app limit has been reached: $arg0.';
  }

  @override
  String get confirmLaunch => 'Confirm launch';

  @override
  String get connectSteam => 'Connect Steam';

  @override
  String get copyAppId => 'Copy AppID';

  @override
  String currentAppLabel(Object arg0) {
    return 'current: $arg0';
  }

  @override
  String get currentPlaytime => 'Current playtime';

  @override
  String get currentSelection => 'Current selection';

  @override
  String get defaultDuration => 'Default duration';

  @override
  String get delayBetweenGames => 'Delay between games';

  @override
  String get demo => 'Demo';

  @override
  String get descending => 'Descending';

  @override
  String get detectAutomatically => 'Detect automatically';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit…';

  @override
  String get editAutoStopTarget => 'Edit auto-stop target';

  @override
  String get editCurrentPlaytime => 'Edit current playtime';

  @override
  String get editFilters => 'Edit filters';

  @override
  String get editingRequiresStoppedGames => 'Stop the running games and queue first.';

  @override
  String get eligibleApps => 'Eligible apps';

  @override
  String get emptyTargetClearsHint => 'Leave empty to clear the target';

  @override
  String get enterCode => 'Enter code';

  @override
  String get entireLibrary => 'Entire library';

  @override
  String get entireLibraryOperationTitle => 'Operation for the entire library';

  @override
  String get favorites => 'Favorites';

  @override
  String favoritesLaunchDescription(Object arg0) {
    return 'All favorites in the current selection run in parallel, up to $arg0 at a time.';
  }

  @override
  String get filters => 'Filters';

  @override
  String get game => 'Game';

  @override
  String gameDeadlineUpdateFailed(Object arg0) {
    return 'Could not update the stop time for $arg0.';
  }

  @override
  String gameLaunchFailed(Object arg0, Object arg1, Object arg2) {
    return 'Could not launch $arg0 (AppID $arg1). $arg2';
  }

  @override
  String gamePlaytimeSaveFailed(Object arg0, Object arg1) {
    return 'Could not save playtime for $arg0 (AppID $arg1).';
  }

  @override
  String gameStopFailed(Object arg0, Object arg1) {
    return 'Could not stop $arg0 (AppID $arg1). The process is still being monitored.';
  }

  @override
  String get hidden => 'Hidden';

  @override
  String get hours => 'Hours';

  @override
  String get hoursAbbreviation => 'h';

  @override
  String get initializationFailed => 'Initialization failed';

  @override
  String get initializationFailureHint => 'Application components could not be prepared. Library data was not changed.';

  @override
  String get interface => 'INTERFACE';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get lastPlayed => 'Last played';

  @override
  String get launchAction => 'Launch';

  @override
  String get launchApps => 'Launch apps';

  @override
  String get launchConfirmationHint => 'Launch starts immediately after confirmation.';

  @override
  String get launchMenuLabel => 'LAUNCH';

  @override
  String get launchOptionsAction => 'Launch…';

  @override
  String get launchOrder => 'Launch order';

  @override
  String get launchUsesFiltersHint => 'Launch respects the search query and all active catalog filters.';

  @override
  String get libraryCache => 'Library cache';

  @override
  String libraryCacheAppCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apps cached',
      one: '$count app cached',
      zero: 'No apps cached',
    );
    return '$_temp0';
  }

  @override
  String get libraryCacheClearDescription =>
      'Remove the downloaded game list, playtime, favorites and targets from SSF. Your Steam session will remain available for the next refresh.';

  @override
  String get libraryCacheCleared => 'Library cache cleared. Your Steam session is saved.';

  @override
  String get libraryCacheClearFailed => 'Could not clear the library cache. Please try again.';

  @override
  String get libraryCacheCounting => 'Counting cached apps…';

  @override
  String get libraryCacheCountUnavailable => 'Could not read the number of cached apps.';

  @override
  String get librarySaveFailed => 'Could not save the library. Please refresh again.';

  @override
  String get librarySaving => 'Saving the library to the catalog…';

  @override
  String libraryUpdated(Object arg0) {
    return 'Library updated: $arg0 apps.';
  }

  @override
  String libraryUpdatedPartially(Object arg0) {
    return 'Library updated: $arg0 apps. Some Steam data is unavailable.';
  }

  @override
  String get lowPlaytimeDurationLabel => 'If below 30 minutes';

  @override
  String get manage => 'Manage…';

  @override
  String manualAppsCount(Object arg0) {
    return 'manual $arg0';
  }

  @override
  String get manualLaunch => 'Manual launch';

  @override
  String get marked => 'Marked';

  @override
  String markedLaunchDescription(Object arg0) {
    return 'Games with an unmet target run in parallel, up to $arg0 at a time.';
  }

  @override
  String get maximum => 'Maximum';

  @override
  String get maximumExclusive => 'Maximum <';

  @override
  String get maximumTarget => 'Maximum target';

  @override
  String get milestoneTargetRulesHint =>
      'The next eligible target is set to an exact milestone minute. Games at the target or up to 5 minutes past it are not marked again.';

  @override
  String get minimum => 'Minimum';

  @override
  String get minimumInclusive => 'Minimum ≥';

  @override
  String get minimumTarget => 'Minimum target';

  @override
  String get minutes => 'Minutes';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get mode => 'Mode';

  @override
  String get moreActions => 'More actions';

  @override
  String get name => 'Name';

  @override
  String get nonNegativeIntegerRequired => 'Enter an integer of 0 or more';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get optional => 'Optional';

  @override
  String get optionalMaximumHint => 'Optional — defaults to the maximum';

  @override
  String get other => 'Other';

  @override
  String get ownership => 'Ownership';

  @override
  String get ownershipFromSteamOnRefresh => 'Use Steam data on the next refresh';

  @override
  String get ownershipNonPersonal => 'Not mine / unknown';

  @override
  String get ownershipPersonal => 'Mine';

  @override
  String get ownershipPersonalFilter => 'Mine';

  @override
  String get ownershipUnknown => 'Unknown';

  @override
  String get ownershipUnknownFilter => 'Unknown';

  @override
  String get password => 'Password';

  @override
  String get pause => 'Pause';

  @override
  String get playtime => 'Playtime';

  @override
  String get playtimeClearsReachedTargetHint =>
      'The new playtime reaches the current auto-stop target, so the target will be cleared.';

  @override
  String playtimeHours(Object arg0) {
    return '$arg0 h';
  }

  @override
  String playtimeHoursApproximate(Object arg0) {
    return '≈ $arg0 h';
  }

  @override
  String get playtimeInMinutes => 'Playtime in minutes';

  @override
  String get playtimeMilestones => 'Playtime milestones';

  @override
  String playtimeMinutes(Object arg0) {
    return '$arg0 min';
  }

  @override
  String get playtimeMinutesExample => 'For example, 120';

  @override
  String get positiveIntegerRequired => 'Enter a positive integer';

  @override
  String queuedAppsCount(Object arg0) {
    return 'queued $arg0';
  }

  @override
  String queuePausedLabel(Object arg0) {
    return '$arg0 · paused';
  }

  @override
  String get range => 'Range';

  @override
  String get refreshLibrary => 'Refresh library';

  @override
  String get refreshQrCode => 'Refresh QR code';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get reset => 'Reset';

  @override
  String get resetAll => 'Reset all';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get runnerAccountMismatch => 'Make sure the SSF library and Steam client use the same account.';

  @override
  String get runnerCleanupFailed => 'Could not enable automatic cleanup of game processes. Restart SSF and try again.';

  @override
  String get runnerLaunchUnconfirmed => 'SteamAPI did not confirm the launch.';

  @override
  String get runnerLibraryRequired => 'Load your Steam account library first.';

  @override
  String get runnerUpdateRequired => 'Rebuild or update ssf_game alongside SSF.';

  @override
  String runningAppsCount(Object arg0, Object arg1) {
    return 'Running $arg0/$arg1';
  }

  @override
  String get save => 'Save';

  @override
  String get searchByName => 'Search by name';

  @override
  String get secondsAbbreviation => 'sec';

  @override
  String get selectAValue => 'Select a value';

  @override
  String get selectionHasNoEligibleApps => 'No eligible apps in the current selection.';

  @override
  String get sequentialLaunchDescription => 'The entire current selection runs one app at a time.';

  @override
  String get sequentialQueue => 'Sequential queue';

  @override
  String get sequentialQueueBlocksManualLaunch => 'Manual launch is unavailable while a sequential queue is active.';

  @override
  String get sequentialQueueRequiresStoppedGames => 'Stop the running apps before starting a sequential queue.';

  @override
  String get sequentialStartAppId => 'Start from AppID';

  @override
  String get sequentialTimingInvalid => 'Duration must be at least 1 second and the delay must be 0 or more.';

  @override
  String get setOwnership => 'Set ownership';

  @override
  String get setTargets => 'Set targets…';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsCardPreviewHint => 'Select a tile to apply that card format to the catalog immediately.';

  @override
  String get settingsImmediateSaveHint => 'Changes are saved immediately and do not require an Apply button.';

  @override
  String get settingsIntegrationsSteam => 'Integrations · Steam';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsSaveError => 'The setting could not be saved.';

  @override
  String get settingsSaving => 'Saving…';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get sortBy => 'Sort by';

  @override
  String get soundtrack => 'Soundtrack';

  @override
  String get startAppNotInSelection => 'The specified AppID was not found in the current sorted selection.';

  @override
  String get status => 'Status';

  @override
  String get statusRunning => 'Running';

  @override
  String get steamAccountName => 'Steam account name';

  @override
  String get steamAuthInputFailed => 'Could not send the response to Steam';

  @override
  String get steamConnecting => 'Connecting to Steam…';

  @override
  String get steamConnection => 'Steam connection';

  @override
  String get steamCredentialsChecking => 'Checking Steam credentials…';

  @override
  String get steamCredentialsRequired => 'Enter your Steam account name and password';

  @override
  String get steamCredentialsTitle => 'Sign in with your account name';

  @override
  String get steamFamilyLibraryLoading => 'Loading the Steam Family library…';

  @override
  String get steamGuardAppPrompt => 'Enter the Steam Guard code from the Steam app';

  @override
  String get steamGuardChecking => 'Checking Steam Guard code…';

  @override
  String get steamGuardCode => 'Steam Guard code';

  @override
  String get steamGuardEmailLabel => 'Code from your Steam email';

  @override
  String get steamGuardEmailPrompt => 'Enter the Steam Guard code from your email';

  @override
  String get steamGuardSubmit => 'Confirm code';

  @override
  String get steamHelperProtocolError => 'Invalid response from the library helper';

  @override
  String get steamHelperReadFailed => 'Could not read the library helper response';

  @override
  String get steamHelperStartFailed =>
      'Could not start the library helper. Make sure ssf_steam_helper.exe is installed alongside SSF.';

  @override
  String get steamHelperStopUnconfirmed => 'Could not confirm that the process stopped. Try cancelling again.';

  @override
  String get steamId => 'SteamID';

  @override
  String steamLibraryFailedWithCode(Object arg0) {
    return 'Signed in. Could not get the library (code $arg0).';
  }

  @override
  String get steamLibraryLoading => 'Signed in. Loading the library…';

  @override
  String get steamLibraryMerging => 'Combining library data…';

  @override
  String get steamLibraryPartialStatus => 'Signed in. Library data is partially available.';

  @override
  String get steamLibraryReceived => 'Signed in. Library received.';

  @override
  String get steamLibraryTimeout => 'Signed in, but the library request timed out.';

  @override
  String get steamMetadataLoading => 'Loading app names and types…';

  @override
  String get steamMobileConfirmationPrompt => 'Approve the sign-in in the Steam app on your phone';

  @override
  String get steamPersonalLibraryLoading => 'Loading licenses and your apps…';

  @override
  String get steamPlaytimeUpdating => 'Updating playtime…';

  @override
  String get steamPrivateAppsChecking => 'Checking private apps…';

  @override
  String get steamQrAccessibilityLabel => 'QR code for signing in with Steam Mobile';

  @override
  String get steamQrInstructions => 'Use the Steam mobile app to sign in with a QR code';

  @override
  String get steamQrScanPrompt => 'Scan the QR code in Steam Mobile and approve the sign-in';

  @override
  String get steamQrTitle => 'Or use a QR code';

  @override
  String get steamSessionActive => 'You already have an active session';

  @override
  String get steamSessionChecking => 'Checking the saved session…';

  @override
  String get steamSessionPrivacyHint =>
      'Your password is not saved. The protected session is used for future refreshes without signing in again.';

  @override
  String get steamSessionReadFailed => 'Could not read the saved session';

  @override
  String get steamSignedOutCacheCleared => 'Signed out. Library cache cleared.';

  @override
  String get steamSignedOutStatus => 'Signed out of Steam. Choose a sign-in method.';

  @override
  String get steamSignInCancelled => 'Sign-in cancelled';

  @override
  String get steamSignInCancelling => 'Cancelling sign-in…';

  @override
  String steamSignInFailedWithCode(Object arg0) {
    return 'Could not sign in (code $arg0). Please try again.';
  }

  @override
  String get steamSigningOut => 'Signing out and clearing the cache…';

  @override
  String get steamSignInMethodPrompt => 'Choose a sign-in method';

  @override
  String get steamSignInTimeout => 'Sign-in timed out';

  @override
  String get steamSignOutFailed => 'Could not finish signing out. Please try again.';

  @override
  String steamSyncFailed(Object arg0) {
    return 'Sign-in or library request failed: $arg0';
  }

  @override
  String get stopAction => 'Stop';

  @override
  String get stopAll => 'Stop all';

  @override
  String get stopAllProcessesDescription =>
      'All games and Steam helper processes started by this SteamSpaceFarm instance will be stopped. Queued launches and library refresh will be cancelled.';

  @override
  String get stopAllProcessesFailed => 'Could not force stop the processes.';

  @override
  String get stopAllProcessesTitle => 'Force stop everything?';

  @override
  String get stopBatchQueueDescription => 'The queue will be cleared and the apps it launched will be stopped.';

  @override
  String get stopManualApps => 'Stop manual apps';

  @override
  String stopManualAppsCount(Object arg0) {
    return 'Stop manual apps · $arg0';
  }

  @override
  String stopManualAppsDescription(Object arg0) {
    return 'Apps launched manually in this session will be stopped: $arg0.';
  }

  @override
  String get stopManualAppsTitle => 'Stop manually launched apps?';

  @override
  String get stopMenuLabel => 'STOP';

  @override
  String get stopQueue => 'Stop queue';

  @override
  String get stopQueueTitle => 'Stop the active queue?';

  @override
  String stopSequentialQueueDescription(Object arg0) {
    return 'The current app will stop and the remaining $arg0 entries will be removed.';
  }

  @override
  String get storage => 'STORAGE';

  @override
  String targetAlreadyReachedHint(Object arg0) {
    return 'Current playtime is $arg0 min. This target will be cleared because it has already been reached.';
  }

  @override
  String get targetPlaytime => 'Target playtime';

  @override
  String get targetPlaytimeInMinutes => 'Target playtime in minutes';

  @override
  String get targetRangeBoundsHint =>
      'Targets apply to apps from the minimum playtime inclusive to the maximum exclusive.';

  @override
  String get technicalDetails => 'Technical details';

  @override
  String get timeUntilTarget => 'Time until target';

  @override
  String get tool => 'Tool';

  @override
  String get video => 'Video';

  @override
  String get clearText => 'Clear text';

  @override
  String get refreshOnStartup => 'Refresh library on startup';

  @override
  String get refreshOnStartupHint =>
      'Show the cached library immediately and refresh in the background using the saved session.';

  @override
  String get runnerSteamPresenceFailed => 'Could not switch to Invisible. Check your Steam connection and try again.';

  @override
  String get invisibleWhilePlaying => 'Go invisible when starting games';

  @override
  String get invisibleWhilePlayingHint =>
      'For Steamworks and SteamKit. Restores your previous status after all games stop. SteamKit also works without the local Steam client.';

  @override
  String get experimentalSteamKit => 'Launch via SteamKit — EXPERIMENTAL';

  @override
  String get experimentalSteamKitHint =>
      'Game sessions and Invisible status work without the local Steam client running: just sign in to SteamSpaceFarm. Steam determines whether playtime is recorded.';

  @override
  String get gamesBlockLibrary => 'Stop all games before refreshing the library or signing out.';

  @override
  String get leaveLibraryUpdateTitle => 'Stop updating the library?';

  @override
  String get leaveLibraryUpdateMessage =>
      'Leaving this screen will stop the library update. The saved catalog will remain available.';

  @override
  String get leaveScreen => 'Stop and leave';

  @override
  String get libraryRefreshInProgress => 'The library is updating. Wait for it to finish before starting games.';

  @override
  String get sessionSettings => 'Library and sessions';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get runnerSteamKitFailed => 'SteamKit could not confirm the session. Sign in to Steam again and retry.';

  @override
  String get sessionSettingsShort => 'Sessions';

  @override
  String gameSessionInterrupted(String name, int appId) {
    return 'The session for $name (AppID $appId) ended unexpectedly. Check your Steam connection before restarting. Active queues have been paused.';
  }

  @override
  String get steamPresenceRestoreFailed =>
      'Could not restore your previous Steam status after several attempts. Check your status in Steam.';
}
