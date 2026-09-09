import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(arg0) => "Could not save changes for ${arg0}";

  static String m1(arg0) => "${arg0} · Running";

  static String m2(arg0) => "auto ${arg0}";

  static String m3(arg0) => "${arg0} found";

  static String m4(arg0) => "Auto-stop targets will be removed from ${arg0} apps across the entire library.";

  static String m5(arg0) => "The concurrent app limit has been reached: ${arg0}.";

  static String m6(arg0) => "current: ${arg0}";

  static String m7(arg0) => "All favorites in the current selection run in parallel, up to ${arg0} at a time.";

  static String m8(arg0) => "Could not update the stop time for ${arg0}.";

  static String m9(arg0, arg1, arg2) => "Could not launch ${arg0} (AppID ${arg1}). ${arg2}";

  static String m10(arg0, arg1) => "Could not save playtime for ${arg0} (AppID ${arg1}).";

  static String m11(arg0, arg1) => "Could not stop ${arg0} (AppID ${arg1}). The process is still being monitored.";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'No apps cached', one: '${count} app cached', other: '${count} apps cached')}";

  static String m13(arg0) => "Library updated: ${arg0} apps.";

  static String m14(arg0) => "Library updated: ${arg0} apps. Some Steam data is unavailable.";

  static String m15(arg0) => "manual ${arg0}";

  static String m16(arg0) => "Games with an unmet target run in parallel, up to ${arg0} at a time.";

  static String m17(arg0) => "${arg0} h";

  static String m18(arg0) => "≈ ${arg0} h";

  static String m19(arg0) => "${arg0} min";

  static String m20(arg0) => "${arg0} · paused";

  static String m21(arg0) => "queued ${arg0}";

  static String m22(arg0, arg1) => "Running ${arg0}/${arg1}";

  static String m23(arg0) => "Signed in. Could not get the library (code ${arg0}).";

  static String m24(arg0) => "Could not sign in (code ${arg0}). Please try again.";

  static String m25(arg0) => "Sign-in or library request failed: ${arg0}";

  static String m26(arg0) => "Stop manual apps · ${arg0}";

  static String m27(arg0) => "Apps launched manually in this session will be stopped: ${arg0}.";

  static String m28(arg0) => "The current app will stop and the remaining ${arg0} entries will be removed.";

  static String m29(arg0) =>
      "Current playtime is ${arg0} min. This target will be cleared because it has already been reached.";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activeQueueMustStop": MessageLookupByLibrary.simpleMessage("Stop the active queue first."),
    "addToFavorites": MessageLookupByLibrary.simpleMessage("Add to favorites"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allProcessesStopped": MessageLookupByLibrary.simpleMessage("All games and Steam helper processes stopped."),
    "allSequentially": MessageLookupByLibrary.simpleMessage("All sequentially"),
    "alphabetical": MessageLookupByLibrary.simpleMessage("Alphabetical"),
    "appChangesSaveFailed": m0,
    "appIdCopied": MessageLookupByLibrary.simpleMessage("AppID copied"),
    "appIdInvalid": MessageLookupByLibrary.simpleMessage("Enter a valid AppID."),
    "appLanguage": MessageLookupByLibrary.simpleMessage("App language"),
    "appLookupHint": MessageLookupByLibrary.simpleMessage("Name, AppID or Steam link"),
    "appType": MessageLookupByLibrary.simpleMessage("App type"),
    "appTypeRunningLabel": m1,
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applyTargets": MessageLookupByLibrary.simpleMessage("Apply targets"),
    "ascending": MessageLookupByLibrary.simpleMessage("Ascending"),
    "autoStop": MessageLookupByLibrary.simpleMessage("Auto-stop"),
    "automatic": MessageLookupByLibrary.simpleMessage("automatic"),
    "automaticAppsCount": m2,
    "bulkChangesSaveFailed": MessageLookupByLibrary.simpleMessage("Could not save bulk changes. Please try again."),
    "bulkTargets": MessageLookupByLibrary.simpleMessage("Bulk targets"),
    "bulkTargetsDescription": MessageLookupByLibrary.simpleMessage(
      "Set auto-stop targets for the selected part of the catalog.",
    ),
    "bulkTargetsInvalidRange": MessageLookupByLibrary.simpleMessage(
      "Check the values: the range must be valid and targets must be positive.",
    ),
    "bulkTargetsNoChanges": MessageLookupByLibrary.simpleMessage("No apps would be changed by this operation."),
    "byLastPlayed": MessageLookupByLibrary.simpleMessage("By last played"),
    "byPlaytime": MessageLookupByLibrary.simpleMessage("By playtime"),
    "byTimeUntilTarget": MessageLookupByLibrary.simpleMessage("By time until target"),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelAction": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cardType": MessageLookupByLibrary.simpleMessage("Card type"),
    "cardTypeAppIcon": MessageLookupByLibrary.simpleMessage("App icon 32×32"),
    "cardTypeLibraryCapsule": MessageLookupByLibrary.simpleMessage("Library capsule"),
    "cardTypeMainCapsule": MessageLookupByLibrary.simpleMessage("Main capsule"),
    "cardTypeStoreHeader": MessageLookupByLibrary.simpleMessage("Store header"),
    "catalogEmptyDescription": MessageLookupByLibrary.simpleMessage("Connect Steam to get your games and playtime."),
    "catalogEmptyTitle": MessageLookupByLibrary.simpleMessage("Your local library is empty"),
    "catalogEmptyWithSession": MessageLookupByLibrary.simpleMessage(
      "You are already signed in to Steam. Refresh your library to load your games and playtime.",
    ),
    "catalogNoResultsHint": MessageLookupByLibrary.simpleMessage("Change your search or filter settings."),
    "catalogReadFailed": MessageLookupByLibrary.simpleMessage("Could not read the local catalog"),
    "catalogResultsCount": m3,
    "catalogSearchHint": MessageLookupByLibrary.simpleMessage("Name or AppID"),
    "clearAll": MessageLookupByLibrary.simpleMessage("Clear all"),
    "clearAllTargetsAction": MessageLookupByLibrary.simpleMessage("Clear all targets"),
    "clearAllTargetsDescription": m4,
    "clearAllTargetsTitle": MessageLookupByLibrary.simpleMessage("Clear all targets?"),
    "clearLibraryCache": MessageLookupByLibrary.simpleMessage("Clear library cache"),
    "clearTargets": MessageLookupByLibrary.simpleMessage("Clear targets"),
    "clearTargetsIgnoresFiltersHint": MessageLookupByLibrary.simpleMessage(
      "The current search and filters do not apply. You will be asked to confirm before targets are removed.",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "concurrentApps": MessageLookupByLibrary.simpleMessage("Concurrent apps"),
    "concurrentLimitReached": m5,
    "confirmLaunch": MessageLookupByLibrary.simpleMessage("Confirm launch"),
    "connectSteam": MessageLookupByLibrary.simpleMessage("Connect Steam"),
    "copyAppId": MessageLookupByLibrary.simpleMessage("Copy AppID"),
    "currentAppLabel": m6,
    "currentPlaytime": MessageLookupByLibrary.simpleMessage("Current playtime"),
    "currentSelection": MessageLookupByLibrary.simpleMessage("Current selection"),
    "defaultDuration": MessageLookupByLibrary.simpleMessage("Default duration"),
    "delayBetweenGames": MessageLookupByLibrary.simpleMessage("Delay between games"),
    "demo": MessageLookupByLibrary.simpleMessage("Demo"),
    "descending": MessageLookupByLibrary.simpleMessage("Descending"),
    "detectAutomatically": MessageLookupByLibrary.simpleMessage("Detect automatically"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit…"),
    "editAutoStopTarget": MessageLookupByLibrary.simpleMessage("Edit auto-stop target"),
    "editCurrentPlaytime": MessageLookupByLibrary.simpleMessage("Edit current playtime"),
    "editFilters": MessageLookupByLibrary.simpleMessage("Edit filters"),
    "editingRequiresStoppedGames": MessageLookupByLibrary.simpleMessage("Stop the running games and queue first."),
    "eligibleApps": MessageLookupByLibrary.simpleMessage("Eligible apps"),
    "emptyTargetClearsHint": MessageLookupByLibrary.simpleMessage("Leave empty to clear the target"),
    "enterCode": MessageLookupByLibrary.simpleMessage("Enter code"),
    "entireLibrary": MessageLookupByLibrary.simpleMessage("Entire library"),
    "entireLibraryOperationTitle": MessageLookupByLibrary.simpleMessage("Operation for the entire library"),
    "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
    "favoritesLaunchDescription": m7,
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "game": MessageLookupByLibrary.simpleMessage("Game"),
    "gameDeadlineUpdateFailed": m8,
    "gameLaunchFailed": m9,
    "gamePlaytimeSaveFailed": m10,
    "gameStopFailed": m11,
    "hidden": MessageLookupByLibrary.simpleMessage("Hidden"),
    "hours": MessageLookupByLibrary.simpleMessage("Hours"),
    "hoursAbbreviation": MessageLookupByLibrary.simpleMessage("h"),
    "initializationFailed": MessageLookupByLibrary.simpleMessage("Initialization failed"),
    "initializationFailureHint": MessageLookupByLibrary.simpleMessage(
      "Application components could not be prepared. Library data was not changed.",
    ),
    "interface": MessageLookupByLibrary.simpleMessage("INTERFACE"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languageRussian": MessageLookupByLibrary.simpleMessage("Russian"),
    "lastPlayed": MessageLookupByLibrary.simpleMessage("Last played"),
    "launchAction": MessageLookupByLibrary.simpleMessage("Launch"),
    "launchApps": MessageLookupByLibrary.simpleMessage("Launch apps"),
    "launchConfirmationHint": MessageLookupByLibrary.simpleMessage("Launch starts immediately after confirmation."),
    "launchMenuLabel": MessageLookupByLibrary.simpleMessage("LAUNCH"),
    "launchOptionsAction": MessageLookupByLibrary.simpleMessage("Launch…"),
    "launchOrder": MessageLookupByLibrary.simpleMessage("Launch order"),
    "launchUsesFiltersHint": MessageLookupByLibrary.simpleMessage(
      "Launch respects the search query and all active catalog filters.",
    ),
    "libraryCache": MessageLookupByLibrary.simpleMessage("Library cache"),
    "libraryCacheAppCount": m12,
    "libraryCacheClearDescription": MessageLookupByLibrary.simpleMessage(
      "Remove the downloaded game list, playtime, favorites and targets from SSF. Your Steam session will remain available for the next refresh.",
    ),
    "libraryCacheClearFailed": MessageLookupByLibrary.simpleMessage(
      "Could not clear the library cache. Please try again.",
    ),
    "libraryCacheCleared": MessageLookupByLibrary.simpleMessage("Library cache cleared. Your Steam session is saved."),
    "libraryCacheCountUnavailable": MessageLookupByLibrary.simpleMessage("Could not read the number of cached apps."),
    "libraryCacheCounting": MessageLookupByLibrary.simpleMessage("Counting cached apps…"),
    "librarySaveFailed": MessageLookupByLibrary.simpleMessage("Could not save the library. Please refresh again."),
    "librarySaving": MessageLookupByLibrary.simpleMessage("Saving the library to the catalog…"),
    "libraryUpdated": m13,
    "libraryUpdatedPartially": m14,
    "lowPlaytimeDurationLabel": MessageLookupByLibrary.simpleMessage("If below 30 minutes"),
    "manage": MessageLookupByLibrary.simpleMessage("Manage…"),
    "manualAppsCount": m15,
    "manualLaunch": MessageLookupByLibrary.simpleMessage("Manual launch"),
    "marked": MessageLookupByLibrary.simpleMessage("Marked"),
    "markedLaunchDescription": m16,
    "maximum": MessageLookupByLibrary.simpleMessage("Maximum"),
    "maximumExclusive": MessageLookupByLibrary.simpleMessage("Maximum <"),
    "maximumTarget": MessageLookupByLibrary.simpleMessage("Maximum target"),
    "milestoneTargetRulesHint": MessageLookupByLibrary.simpleMessage(
      "The next eligible target is set to an exact milestone minute. Games at the target or up to 5 minutes past it are not marked again.",
    ),
    "minimum": MessageLookupByLibrary.simpleMessage("Minimum"),
    "minimumInclusive": MessageLookupByLibrary.simpleMessage("Minimum ≥"),
    "minimumTarget": MessageLookupByLibrary.simpleMessage("Minimum target"),
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesAbbreviation": MessageLookupByLibrary.simpleMessage("min"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "moreActions": MessageLookupByLibrary.simpleMessage("More actions"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nonNegativeIntegerRequired": MessageLookupByLibrary.simpleMessage("Enter an integer of 0 or more"),
    "nothingFound": MessageLookupByLibrary.simpleMessage("Nothing found"),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "optionalMaximumHint": MessageLookupByLibrary.simpleMessage("Optional — defaults to the maximum"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "ownership": MessageLookupByLibrary.simpleMessage("Ownership"),
    "ownershipFromSteamOnRefresh": MessageLookupByLibrary.simpleMessage("Use Steam data on the next refresh"),
    "ownershipNonPersonal": MessageLookupByLibrary.simpleMessage("Not mine / unknown"),
    "ownershipPersonal": MessageLookupByLibrary.simpleMessage("Mine"),
    "ownershipPersonalFilter": MessageLookupByLibrary.simpleMessage("Mine"),
    "ownershipUnknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "ownershipUnknownFilter": MessageLookupByLibrary.simpleMessage("Unknown"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "playtime": MessageLookupByLibrary.simpleMessage("Playtime"),
    "playtimeClearsReachedTargetHint": MessageLookupByLibrary.simpleMessage(
      "The new playtime reaches the current auto-stop target, so the target will be cleared.",
    ),
    "playtimeHours": m17,
    "playtimeHoursApproximate": m18,
    "playtimeInMinutes": MessageLookupByLibrary.simpleMessage("Playtime in minutes"),
    "playtimeMilestones": MessageLookupByLibrary.simpleMessage("Playtime milestones"),
    "playtimeMinutes": m19,
    "playtimeMinutesExample": MessageLookupByLibrary.simpleMessage("For example, 120"),
    "positiveIntegerRequired": MessageLookupByLibrary.simpleMessage("Enter a positive integer"),
    "queuePausedLabel": m20,
    "queuedAppsCount": m21,
    "range": MessageLookupByLibrary.simpleMessage("Range"),
    "refreshLibrary": MessageLookupByLibrary.simpleMessage("Refresh library"),
    "refreshQrCode": MessageLookupByLibrary.simpleMessage("Refresh QR code"),
    "removeFromFavorites": MessageLookupByLibrary.simpleMessage("Remove from favorites"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetAll": MessageLookupByLibrary.simpleMessage("Reset all"),
    "resume": MessageLookupByLibrary.simpleMessage("Resume"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "runnerAccountMismatch": MessageLookupByLibrary.simpleMessage(
      "Make sure the SSF library and Steam client use the same account.",
    ),
    "runnerCleanupFailed": MessageLookupByLibrary.simpleMessage(
      "Could not enable automatic cleanup of game processes. Restart SSF and try again.",
    ),
    "runnerLaunchUnconfirmed": MessageLookupByLibrary.simpleMessage("SteamAPI did not confirm the launch."),
    "runnerLibraryRequired": MessageLookupByLibrary.simpleMessage("Load your Steam account library first."),
    "runnerUpdateRequired": MessageLookupByLibrary.simpleMessage("Rebuild or update ssf_game alongside SSF."),
    "runningAppsCount": m22,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "searchByName": MessageLookupByLibrary.simpleMessage("Search by name"),
    "secondsAbbreviation": MessageLookupByLibrary.simpleMessage("sec"),
    "selectAValue": MessageLookupByLibrary.simpleMessage("Select a value"),
    "selectionHasNoEligibleApps": MessageLookupByLibrary.simpleMessage("No eligible apps in the current selection."),
    "sequentialLaunchDescription": MessageLookupByLibrary.simpleMessage(
      "The entire current selection runs one app at a time.",
    ),
    "sequentialQueue": MessageLookupByLibrary.simpleMessage("Sequential queue"),
    "sequentialQueueBlocksManualLaunch": MessageLookupByLibrary.simpleMessage(
      "Manual launch is unavailable while a sequential queue is active.",
    ),
    "sequentialQueueRequiresStoppedGames": MessageLookupByLibrary.simpleMessage(
      "Stop the running apps before starting a sequential queue.",
    ),
    "sequentialStartAppId": MessageLookupByLibrary.simpleMessage("Start from AppID"),
    "sequentialTimingInvalid": MessageLookupByLibrary.simpleMessage(
      "Duration must be at least 1 second and the delay must be 0 or more.",
    ),
    "setOwnership": MessageLookupByLibrary.simpleMessage("Set ownership"),
    "setTargets": MessageLookupByLibrary.simpleMessage("Set targets…"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsAppearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "settingsCardPreviewHint": MessageLookupByLibrary.simpleMessage(
      "Select a tile to apply that card format to the catalog immediately.",
    ),
    "settingsImmediateSaveHint": MessageLookupByLibrary.simpleMessage(
      "Changes are saved immediately and do not require an Apply button.",
    ),
    "settingsIntegrationsSteam": MessageLookupByLibrary.simpleMessage("Integrations · Steam"),
    "settingsLanguage": MessageLookupByLibrary.simpleMessage("Language"),
    "settingsSaveError": MessageLookupByLibrary.simpleMessage("The setting could not be saved."),
    "settingsSaved": MessageLookupByLibrary.simpleMessage("Settings saved"),
    "settingsSaving": MessageLookupByLibrary.simpleMessage("Saving…"),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign in"),
    "signOut": MessageLookupByLibrary.simpleMessage("Sign out"),
    "sortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
    "soundtrack": MessageLookupByLibrary.simpleMessage("Soundtrack"),
    "startAppNotInSelection": MessageLookupByLibrary.simpleMessage(
      "The specified AppID was not found in the current sorted selection.",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Running"),
    "steamAccountName": MessageLookupByLibrary.simpleMessage("Steam account name"),
    "steamAuthInputFailed": MessageLookupByLibrary.simpleMessage("Could not send the response to Steam"),
    "steamConnecting": MessageLookupByLibrary.simpleMessage("Connecting to Steam…"),
    "steamConnection": MessageLookupByLibrary.simpleMessage("Steam connection"),
    "steamCredentialsChecking": MessageLookupByLibrary.simpleMessage("Checking Steam credentials…"),
    "steamCredentialsRequired": MessageLookupByLibrary.simpleMessage("Enter your Steam account name and password"),
    "steamCredentialsTitle": MessageLookupByLibrary.simpleMessage("Sign in with your account name"),
    "steamFamilyLibraryLoading": MessageLookupByLibrary.simpleMessage("Loading the Steam Family library…"),
    "steamGuardAppPrompt": MessageLookupByLibrary.simpleMessage("Enter the Steam Guard code from the Steam app"),
    "steamGuardChecking": MessageLookupByLibrary.simpleMessage("Checking Steam Guard code…"),
    "steamGuardCode": MessageLookupByLibrary.simpleMessage("Steam Guard code"),
    "steamGuardEmailLabel": MessageLookupByLibrary.simpleMessage("Code from your Steam email"),
    "steamGuardEmailPrompt": MessageLookupByLibrary.simpleMessage("Enter the Steam Guard code from your email"),
    "steamGuardSubmit": MessageLookupByLibrary.simpleMessage("Confirm code"),
    "steamHelperProtocolError": MessageLookupByLibrary.simpleMessage("Invalid response from the library helper"),
    "steamHelperReadFailed": MessageLookupByLibrary.simpleMessage("Could not read the library helper response"),
    "steamHelperStartFailed": MessageLookupByLibrary.simpleMessage(
      "Could not start the library helper. Make sure ssf_steam_helper.exe is installed alongside SSF.",
    ),
    "steamHelperStopUnconfirmed": MessageLookupByLibrary.simpleMessage(
      "Could not confirm that the process stopped. Try cancelling again.",
    ),
    "steamId": MessageLookupByLibrary.simpleMessage("SteamID"),
    "steamLibraryFailedWithCode": m23,
    "steamLibraryLoading": MessageLookupByLibrary.simpleMessage("Signed in. Loading the library…"),
    "steamLibraryMerging": MessageLookupByLibrary.simpleMessage("Combining library data…"),
    "steamLibraryPartialStatus": MessageLookupByLibrary.simpleMessage(
      "Signed in. Library data is partially available.",
    ),
    "steamLibraryReceived": MessageLookupByLibrary.simpleMessage("Signed in. Library received."),
    "steamLibraryTimeout": MessageLookupByLibrary.simpleMessage("Signed in, but the library request timed out."),
    "steamMetadataLoading": MessageLookupByLibrary.simpleMessage("Loading app names and types…"),
    "steamMobileConfirmationPrompt": MessageLookupByLibrary.simpleMessage(
      "Approve the sign-in in the Steam app on your phone",
    ),
    "steamPersonalLibraryLoading": MessageLookupByLibrary.simpleMessage("Loading licenses and your apps…"),
    "steamPlaytimeUpdating": MessageLookupByLibrary.simpleMessage("Updating playtime…"),
    "steamPrivateAppsChecking": MessageLookupByLibrary.simpleMessage("Checking private apps…"),
    "steamQrAccessibilityLabel": MessageLookupByLibrary.simpleMessage("QR code for signing in with Steam Mobile"),
    "steamQrInstructions": MessageLookupByLibrary.simpleMessage("Use the Steam mobile app to sign in with a QR code"),
    "steamQrScanPrompt": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code in Steam Mobile and approve the sign-in",
    ),
    "steamQrTitle": MessageLookupByLibrary.simpleMessage("Or use a QR code"),
    "steamSessionActive": MessageLookupByLibrary.simpleMessage("You already have an active session"),
    "steamSessionChecking": MessageLookupByLibrary.simpleMessage("Checking the saved session…"),
    "steamSessionPrivacyHint": MessageLookupByLibrary.simpleMessage(
      "Your password is not saved. The protected session is used for future refreshes without signing in again.",
    ),
    "steamSessionReadFailed": MessageLookupByLibrary.simpleMessage("Could not read the saved session"),
    "steamSignInCancelled": MessageLookupByLibrary.simpleMessage("Sign-in cancelled"),
    "steamSignInCancelling": MessageLookupByLibrary.simpleMessage("Cancelling sign-in…"),
    "steamSignInFailedWithCode": m24,
    "steamSignInMethodPrompt": MessageLookupByLibrary.simpleMessage("Choose a sign-in method"),
    "steamSignInTimeout": MessageLookupByLibrary.simpleMessage("Sign-in timed out"),
    "steamSignOutFailed": MessageLookupByLibrary.simpleMessage("Could not finish signing out. Please try again."),
    "steamSignedOutCacheCleared": MessageLookupByLibrary.simpleMessage("Signed out. Library cache cleared."),
    "steamSignedOutStatus": MessageLookupByLibrary.simpleMessage("Signed out of Steam. Choose a sign-in method."),
    "steamSigningOut": MessageLookupByLibrary.simpleMessage("Signing out and clearing the cache…"),
    "steamSyncFailed": m25,
    "stopAction": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopAll": MessageLookupByLibrary.simpleMessage("Stop all"),
    "stopAllProcessesDescription": MessageLookupByLibrary.simpleMessage(
      "All games and Steam helper processes started by this SteamSpaceFarm instance will be stopped. Queued launches and library refresh will be cancelled.",
    ),
    "stopAllProcessesFailed": MessageLookupByLibrary.simpleMessage("Could not force stop the processes."),
    "stopAllProcessesTitle": MessageLookupByLibrary.simpleMessage("Force stop everything?"),
    "stopBatchQueueDescription": MessageLookupByLibrary.simpleMessage(
      "The queue will be cleared and the apps it launched will be stopped.",
    ),
    "stopManualApps": MessageLookupByLibrary.simpleMessage("Stop manual apps"),
    "stopManualAppsCount": m26,
    "stopManualAppsDescription": m27,
    "stopManualAppsTitle": MessageLookupByLibrary.simpleMessage("Stop manually launched apps?"),
    "stopMenuLabel": MessageLookupByLibrary.simpleMessage("STOP"),
    "stopQueue": MessageLookupByLibrary.simpleMessage("Stop queue"),
    "stopQueueTitle": MessageLookupByLibrary.simpleMessage("Stop the active queue?"),
    "stopSequentialQueueDescription": m28,
    "storage": MessageLookupByLibrary.simpleMessage("STORAGE"),
    "targetAlreadyReachedHint": m29,
    "targetPlaytime": MessageLookupByLibrary.simpleMessage("Target playtime"),
    "targetPlaytimeInMinutes": MessageLookupByLibrary.simpleMessage("Target playtime in minutes"),
    "targetRangeBoundsHint": MessageLookupByLibrary.simpleMessage(
      "Targets apply to apps from the minimum playtime inclusive to the maximum exclusive.",
    ),
    "technicalDetails": MessageLookupByLibrary.simpleMessage("Technical details"),
    "timeUntilTarget": MessageLookupByLibrary.simpleMessage("Time until target"),
    "tool": MessageLookupByLibrary.simpleMessage("Tool"),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
  };
}
