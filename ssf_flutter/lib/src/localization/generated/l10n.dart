import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_es.dart';
import 'l10n_ru.dart';
import 'l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of GeneratedLocalizations
/// returned by `GeneratedLocalizations.of(context)`.
///
/// Applications need to include `GeneratedLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GeneratedLocalizations.localizationsDelegates,
///   supportedLocales: GeneratedLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the GeneratedLocalizations.supportedLocales
/// property.
abstract class GeneratedLocalizations {
  GeneratedLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GeneratedLocalizations of(BuildContext context) {
    return Localizations.of<GeneratedLocalizations>(context, GeneratedLocalizations)!;
  }

  static const LocalizationsDelegate<GeneratedLocalizations> delegate = _GeneratedLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es'), Locale('ru'), Locale('zh')];

  /// No description provided for @activeQueueMustStop.
  ///
  /// In en, this message translates to:
  /// **'Stop the active queue first.'**
  String get activeQueueMustStop;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allProcessesStopped.
  ///
  /// In en, this message translates to:
  /// **'All games and Steam helper processes stopped.'**
  String get allProcessesStopped;

  /// No description provided for @allSequentially.
  ///
  /// In en, this message translates to:
  /// **'All sequentially'**
  String get allSequentially;

  /// No description provided for @alphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get alphabetical;

  /// No description provided for @appChangesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes for {arg0}'**
  String appChangesSaveFailed(Object arg0);

  /// No description provided for @appIdCopied.
  ///
  /// In en, this message translates to:
  /// **'AppID copied'**
  String get appIdCopied;

  /// No description provided for @appIdInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid AppID.'**
  String get appIdInvalid;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @appLookupHint.
  ///
  /// In en, this message translates to:
  /// **'Name, AppID or Steam link'**
  String get appLookupHint;

  /// No description provided for @applyTargets.
  ///
  /// In en, this message translates to:
  /// **'Apply targets'**
  String get applyTargets;

  /// No description provided for @appType.
  ///
  /// In en, this message translates to:
  /// **'App type'**
  String get appType;

  /// No description provided for @appTypeRunningLabel.
  ///
  /// In en, this message translates to:
  /// **'{arg0} · Running'**
  String appTypeRunningLabel(Object arg0);

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'automatic'**
  String get automatic;

  /// No description provided for @automaticAppsCount.
  ///
  /// In en, this message translates to:
  /// **'auto {arg0}'**
  String automaticAppsCount(Object arg0);

  /// No description provided for @autoStop.
  ///
  /// In en, this message translates to:
  /// **'Auto-stop'**
  String get autoStop;

  /// No description provided for @bulkChangesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save bulk changes. Please try again.'**
  String get bulkChangesSaveFailed;

  /// No description provided for @bulkTargets.
  ///
  /// In en, this message translates to:
  /// **'Bulk targets'**
  String get bulkTargets;

  /// No description provided for @bulkTargetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set auto-stop targets for the selected part of the catalog.'**
  String get bulkTargetsDescription;

  /// No description provided for @bulkTargetsInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Check the values: the range must be valid and targets must be positive.'**
  String get bulkTargetsInvalidRange;

  /// No description provided for @bulkTargetsNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No apps would be changed by this operation.'**
  String get bulkTargetsNoChanges;

  /// No description provided for @byLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'By last played'**
  String get byLastPlayed;

  /// No description provided for @byPlaytime.
  ///
  /// In en, this message translates to:
  /// **'By playtime'**
  String get byPlaytime;

  /// No description provided for @byTimeUntilTarget.
  ///
  /// In en, this message translates to:
  /// **'By time until target'**
  String get byTimeUntilTarget;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @cardType.
  ///
  /// In en, this message translates to:
  /// **'Card type'**
  String get cardType;

  /// No description provided for @cardTypeAppIcon.
  ///
  /// In en, this message translates to:
  /// **'App icon 32×32'**
  String get cardTypeAppIcon;

  /// No description provided for @cardTypeLibraryCapsule.
  ///
  /// In en, this message translates to:
  /// **'Library capsule'**
  String get cardTypeLibraryCapsule;

  /// No description provided for @cardTypeMainCapsule.
  ///
  /// In en, this message translates to:
  /// **'Main capsule'**
  String get cardTypeMainCapsule;

  /// No description provided for @cardTypeStoreHeader.
  ///
  /// In en, this message translates to:
  /// **'Store header'**
  String get cardTypeStoreHeader;

  /// No description provided for @catalogEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect Steam to get your games and playtime.'**
  String get catalogEmptyDescription;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your local library is empty'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyWithSession.
  ///
  /// In en, this message translates to:
  /// **'You are already signed in to Steam. Refresh your library to load your games and playtime.'**
  String get catalogEmptyWithSession;

  /// No description provided for @catalogNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Change your search or filter settings.'**
  String get catalogNoResultsHint;

  /// No description provided for @catalogReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the local catalog'**
  String get catalogReadFailed;

  /// No description provided for @catalogResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{arg0} found'**
  String catalogResultsCount(Object arg0);

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name or AppID'**
  String get catalogSearchHint;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearAllTargetsAction.
  ///
  /// In en, this message translates to:
  /// **'Clear all targets'**
  String get clearAllTargetsAction;

  /// No description provided for @clearAllTargetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Auto-stop targets will be removed from {arg0} apps across the entire library.'**
  String clearAllTargetsDescription(Object arg0);

  /// No description provided for @clearAllTargetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all targets?'**
  String get clearAllTargetsTitle;

  /// No description provided for @clearLibraryCache.
  ///
  /// In en, this message translates to:
  /// **'Clear library cache'**
  String get clearLibraryCache;

  /// No description provided for @clearTargets.
  ///
  /// In en, this message translates to:
  /// **'Clear targets'**
  String get clearTargets;

  /// No description provided for @clearTargetsIgnoresFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'The current search and filters do not apply. You will be asked to confirm before targets are removed.'**
  String get clearTargetsIgnoresFiltersHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @concurrentApps.
  ///
  /// In en, this message translates to:
  /// **'Concurrent apps'**
  String get concurrentApps;

  /// No description provided for @concurrentLimitReached.
  ///
  /// In en, this message translates to:
  /// **'The concurrent app limit has been reached: {arg0}.'**
  String concurrentLimitReached(Object arg0);

  /// No description provided for @confirmLaunch.
  ///
  /// In en, this message translates to:
  /// **'Confirm launch'**
  String get confirmLaunch;

  /// No description provided for @connectSteam.
  ///
  /// In en, this message translates to:
  /// **'Connect Steam'**
  String get connectSteam;

  /// No description provided for @copyAppId.
  ///
  /// In en, this message translates to:
  /// **'Copy AppID'**
  String get copyAppId;

  /// No description provided for @currentAppLabel.
  ///
  /// In en, this message translates to:
  /// **'current: {arg0}'**
  String currentAppLabel(Object arg0);

  /// No description provided for @currentPlaytime.
  ///
  /// In en, this message translates to:
  /// **'Current playtime'**
  String get currentPlaytime;

  /// No description provided for @currentSelection.
  ///
  /// In en, this message translates to:
  /// **'Current selection'**
  String get currentSelection;

  /// No description provided for @defaultDuration.
  ///
  /// In en, this message translates to:
  /// **'Default duration'**
  String get defaultDuration;

  /// No description provided for @delayBetweenGames.
  ///
  /// In en, this message translates to:
  /// **'Delay between games'**
  String get delayBetweenGames;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demo;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @detectAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Detect automatically'**
  String get detectAutomatically;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit…'**
  String get edit;

  /// No description provided for @editAutoStopTarget.
  ///
  /// In en, this message translates to:
  /// **'Edit auto-stop target'**
  String get editAutoStopTarget;

  /// No description provided for @editCurrentPlaytime.
  ///
  /// In en, this message translates to:
  /// **'Edit current playtime'**
  String get editCurrentPlaytime;

  /// No description provided for @editFilters.
  ///
  /// In en, this message translates to:
  /// **'Edit filters'**
  String get editFilters;

  /// No description provided for @editingRequiresStoppedGames.
  ///
  /// In en, this message translates to:
  /// **'Stop the running games and queue first.'**
  String get editingRequiresStoppedGames;

  /// No description provided for @eligibleApps.
  ///
  /// In en, this message translates to:
  /// **'Eligible apps'**
  String get eligibleApps;

  /// No description provided for @emptyTargetClearsHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to clear the target'**
  String get emptyTargetClearsHint;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @entireLibrary.
  ///
  /// In en, this message translates to:
  /// **'Entire library'**
  String get entireLibrary;

  /// No description provided for @entireLibraryOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation for the entire library'**
  String get entireLibraryOperationTitle;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesLaunchDescription.
  ///
  /// In en, this message translates to:
  /// **'All favorites in the current selection run in parallel, up to {arg0} at a time.'**
  String favoritesLaunchDescription(Object arg0);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @gameDeadlineUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the stop time for {arg0}.'**
  String gameDeadlineUpdateFailed(Object arg0);

  /// No description provided for @gameLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {arg0} (AppID {arg1}). {arg2}'**
  String gameLaunchFailed(Object arg0, Object arg1, Object arg2);

  /// No description provided for @gamePlaytimeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save playtime for {arg0} (AppID {arg1}).'**
  String gamePlaytimeSaveFailed(Object arg0, Object arg1);

  /// No description provided for @gameStopFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not stop {arg0} (AppID {arg1}). The process is still being monitored.'**
  String gameStopFailed(Object arg0, Object arg1);

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @hoursAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursAbbreviation;

  /// No description provided for @initializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializationFailed;

  /// No description provided for @initializationFailureHint.
  ///
  /// In en, this message translates to:
  /// **'Application components could not be prepared. Library data was not changed.'**
  String get initializationFailureHint;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'INTERFACE'**
  String get interface;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @lastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get lastPlayed;

  /// No description provided for @launchAction.
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get launchAction;

  /// No description provided for @launchApps.
  ///
  /// In en, this message translates to:
  /// **'Launch apps'**
  String get launchApps;

  /// No description provided for @launchConfirmationHint.
  ///
  /// In en, this message translates to:
  /// **'Launch starts immediately after confirmation.'**
  String get launchConfirmationHint;

  /// No description provided for @launchMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'LAUNCH'**
  String get launchMenuLabel;

  /// No description provided for @launchOptionsAction.
  ///
  /// In en, this message translates to:
  /// **'Launch…'**
  String get launchOptionsAction;

  /// No description provided for @launchOrder.
  ///
  /// In en, this message translates to:
  /// **'Launch order'**
  String get launchOrder;

  /// No description provided for @launchUsesFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'Launch respects the search query and all active catalog filters.'**
  String get launchUsesFiltersHint;

  /// No description provided for @libraryCache.
  ///
  /// In en, this message translates to:
  /// **'Library cache'**
  String get libraryCache;

  /// No description provided for @libraryCacheAppCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No apps cached} one{{count} app cached} other{{count} apps cached}}'**
  String libraryCacheAppCount(int count);

  /// No description provided for @libraryCacheClearDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove the downloaded game list, playtime, favorites and targets from SSF. Your Steam session will remain available for the next refresh.'**
  String get libraryCacheClearDescription;

  /// No description provided for @libraryCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Library cache cleared. Your Steam session is saved.'**
  String get libraryCacheCleared;

  /// No description provided for @libraryCacheClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear the library cache. Please try again.'**
  String get libraryCacheClearFailed;

  /// No description provided for @libraryCacheCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting cached apps…'**
  String get libraryCacheCounting;

  /// No description provided for @libraryCacheCountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not read the number of cached apps.'**
  String get libraryCacheCountUnavailable;

  /// No description provided for @librarySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the library. Please refresh again.'**
  String get librarySaveFailed;

  /// No description provided for @librarySaving.
  ///
  /// In en, this message translates to:
  /// **'Saving the library to the catalog…'**
  String get librarySaving;

  /// No description provided for @libraryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Library updated: {arg0} apps.'**
  String libraryUpdated(Object arg0);

  /// No description provided for @libraryUpdatedPartially.
  ///
  /// In en, this message translates to:
  /// **'Library updated: {arg0} apps. Some Steam data is unavailable.'**
  String libraryUpdatedPartially(Object arg0);

  /// No description provided for @lowPlaytimeDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'If below 30 minutes'**
  String get lowPlaytimeDurationLabel;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage…'**
  String get manage;

  /// No description provided for @manualAppsCount.
  ///
  /// In en, this message translates to:
  /// **'manual {arg0}'**
  String manualAppsCount(Object arg0);

  /// No description provided for @manualLaunch.
  ///
  /// In en, this message translates to:
  /// **'Manual launch'**
  String get manualLaunch;

  /// No description provided for @marked.
  ///
  /// In en, this message translates to:
  /// **'Marked'**
  String get marked;

  /// No description provided for @markedLaunchDescription.
  ///
  /// In en, this message translates to:
  /// **'Games with an unmet target run in parallel, up to {arg0} at a time.'**
  String markedLaunchDescription(Object arg0);

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @maximumExclusive.
  ///
  /// In en, this message translates to:
  /// **'Maximum <'**
  String get maximumExclusive;

  /// No description provided for @maximumTarget.
  ///
  /// In en, this message translates to:
  /// **'Maximum target'**
  String get maximumTarget;

  /// No description provided for @milestoneTargetRulesHint.
  ///
  /// In en, this message translates to:
  /// **'The next eligible target is set to an exact milestone minute. Games at the target or up to 5 minutes past it are not marked again.'**
  String get milestoneTargetRulesHint;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @minimumInclusive.
  ///
  /// In en, this message translates to:
  /// **'Minimum ≥'**
  String get minimumInclusive;

  /// No description provided for @minimumTarget.
  ///
  /// In en, this message translates to:
  /// **'Minimum target'**
  String get minimumTarget;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @minutesAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesAbbreviation;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nonNegativeIntegerRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an integer of 0 or more'**
  String get nonNegativeIntegerRequired;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @optionalMaximumHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — defaults to the maximum'**
  String get optionalMaximumHint;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @ownership.
  ///
  /// In en, this message translates to:
  /// **'Ownership'**
  String get ownership;

  /// No description provided for @ownershipFromSteamOnRefresh.
  ///
  /// In en, this message translates to:
  /// **'Use Steam data on the next refresh'**
  String get ownershipFromSteamOnRefresh;

  /// No description provided for @ownershipNonPersonal.
  ///
  /// In en, this message translates to:
  /// **'Not mine / unknown'**
  String get ownershipNonPersonal;

  /// No description provided for @ownershipPersonal.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get ownershipPersonal;

  /// No description provided for @ownershipPersonalFilter.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get ownershipPersonalFilter;

  /// No description provided for @ownershipUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get ownershipUnknown;

  /// No description provided for @ownershipUnknownFilter.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get ownershipUnknownFilter;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @playtime.
  ///
  /// In en, this message translates to:
  /// **'Playtime'**
  String get playtime;

  /// No description provided for @playtimeClearsReachedTargetHint.
  ///
  /// In en, this message translates to:
  /// **'The new playtime reaches the current auto-stop target, so the target will be cleared.'**
  String get playtimeClearsReachedTargetHint;

  /// No description provided for @playtimeHours.
  ///
  /// In en, this message translates to:
  /// **'{arg0} h'**
  String playtimeHours(Object arg0);

  /// No description provided for @playtimeHoursApproximate.
  ///
  /// In en, this message translates to:
  /// **'≈ {arg0} h'**
  String playtimeHoursApproximate(Object arg0);

  /// No description provided for @playtimeInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Playtime in minutes'**
  String get playtimeInMinutes;

  /// No description provided for @playtimeMilestones.
  ///
  /// In en, this message translates to:
  /// **'Playtime milestones'**
  String get playtimeMilestones;

  /// No description provided for @playtimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{arg0} min'**
  String playtimeMinutes(Object arg0);

  /// No description provided for @playtimeMinutesExample.
  ///
  /// In en, this message translates to:
  /// **'For example, 120'**
  String get playtimeMinutesExample;

  /// No description provided for @positiveIntegerRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive integer'**
  String get positiveIntegerRequired;

  /// No description provided for @queuedAppsCount.
  ///
  /// In en, this message translates to:
  /// **'queued {arg0}'**
  String queuedAppsCount(Object arg0);

  /// No description provided for @queuePausedLabel.
  ///
  /// In en, this message translates to:
  /// **'{arg0} · paused'**
  String queuePausedLabel(Object arg0);

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @refreshLibrary.
  ///
  /// In en, this message translates to:
  /// **'Refresh library'**
  String get refreshLibrary;

  /// No description provided for @refreshQrCode.
  ///
  /// In en, this message translates to:
  /// **'Refresh QR code'**
  String get refreshQrCode;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @runnerAccountMismatch.
  ///
  /// In en, this message translates to:
  /// **'Make sure the SSF library and Steam client use the same account.'**
  String get runnerAccountMismatch;

  /// No description provided for @runnerCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable automatic cleanup of game processes. Restart SSF and try again.'**
  String get runnerCleanupFailed;

  /// No description provided for @runnerLaunchUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'SteamAPI did not confirm the launch.'**
  String get runnerLaunchUnconfirmed;

  /// No description provided for @runnerLibraryRequired.
  ///
  /// In en, this message translates to:
  /// **'Load your Steam account library first.'**
  String get runnerLibraryRequired;

  /// No description provided for @runnerUpdateRequired.
  ///
  /// In en, this message translates to:
  /// **'Rebuild or update ssf_game alongside SSF.'**
  String get runnerUpdateRequired;

  /// No description provided for @runningAppsCount.
  ///
  /// In en, this message translates to:
  /// **'Running {arg0}/{arg1}'**
  String runningAppsCount(Object arg0, Object arg1);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @secondsAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondsAbbreviation;

  /// No description provided for @selectAValue.
  ///
  /// In en, this message translates to:
  /// **'Select a value'**
  String get selectAValue;

  /// No description provided for @selectionHasNoEligibleApps.
  ///
  /// In en, this message translates to:
  /// **'No eligible apps in the current selection.'**
  String get selectionHasNoEligibleApps;

  /// No description provided for @sequentialLaunchDescription.
  ///
  /// In en, this message translates to:
  /// **'The entire current selection runs one app at a time.'**
  String get sequentialLaunchDescription;

  /// No description provided for @sequentialQueue.
  ///
  /// In en, this message translates to:
  /// **'Sequential queue'**
  String get sequentialQueue;

  /// No description provided for @sequentialQueueBlocksManualLaunch.
  ///
  /// In en, this message translates to:
  /// **'Manual launch is unavailable while a sequential queue is active.'**
  String get sequentialQueueBlocksManualLaunch;

  /// No description provided for @sequentialQueueRequiresStoppedGames.
  ///
  /// In en, this message translates to:
  /// **'Stop the running apps before starting a sequential queue.'**
  String get sequentialQueueRequiresStoppedGames;

  /// No description provided for @sequentialStartAppId.
  ///
  /// In en, this message translates to:
  /// **'Start from AppID'**
  String get sequentialStartAppId;

  /// No description provided for @sequentialTimingInvalid.
  ///
  /// In en, this message translates to:
  /// **'Duration must be at least 1 second and the delay must be 0 or more.'**
  String get sequentialTimingInvalid;

  /// No description provided for @setOwnership.
  ///
  /// In en, this message translates to:
  /// **'Set ownership'**
  String get setOwnership;

  /// No description provided for @setTargets.
  ///
  /// In en, this message translates to:
  /// **'Set targets…'**
  String get setTargets;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsCardPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Select a tile to apply that card format to the catalog immediately.'**
  String get settingsCardPreviewHint;

  /// No description provided for @settingsImmediateSaveHint.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved immediately and do not require an Apply button.'**
  String get settingsImmediateSaveHint;

  /// No description provided for @settingsIntegrationsSteam.
  ///
  /// In en, this message translates to:
  /// **'Integrations · Steam'**
  String get settingsIntegrationsSteam;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'The setting could not be saved.'**
  String get settingsSaveError;

  /// No description provided for @settingsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get settingsSaving;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @soundtrack.
  ///
  /// In en, this message translates to:
  /// **'Soundtrack'**
  String get soundtrack;

  /// No description provided for @startAppNotInSelection.
  ///
  /// In en, this message translates to:
  /// **'The specified AppID was not found in the current sorted selection.'**
  String get startAppNotInSelection;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @steamAccountName.
  ///
  /// In en, this message translates to:
  /// **'Steam account name'**
  String get steamAccountName;

  /// No description provided for @steamAuthInputFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the response to Steam'**
  String get steamAuthInputFailed;

  /// No description provided for @steamConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Steam…'**
  String get steamConnecting;

  /// No description provided for @steamConnection.
  ///
  /// In en, this message translates to:
  /// **'Steam connection'**
  String get steamConnection;

  /// No description provided for @steamCredentialsChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking Steam credentials…'**
  String get steamCredentialsChecking;

  /// No description provided for @steamCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your Steam account name and password'**
  String get steamCredentialsRequired;

  /// No description provided for @steamCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your account name'**
  String get steamCredentialsTitle;

  /// No description provided for @steamFamilyLibraryLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the Steam Family library…'**
  String get steamFamilyLibraryLoading;

  /// No description provided for @steamGuardAppPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the Steam Guard code from the Steam app'**
  String get steamGuardAppPrompt;

  /// No description provided for @steamGuardChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking Steam Guard code…'**
  String get steamGuardChecking;

  /// No description provided for @steamGuardCode.
  ///
  /// In en, this message translates to:
  /// **'Steam Guard code'**
  String get steamGuardCode;

  /// No description provided for @steamGuardEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from your Steam email'**
  String get steamGuardEmailLabel;

  /// No description provided for @steamGuardEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the Steam Guard code from your email'**
  String get steamGuardEmailPrompt;

  /// No description provided for @steamGuardSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get steamGuardSubmit;

  /// No description provided for @steamHelperProtocolError.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from the library helper'**
  String get steamHelperProtocolError;

  /// No description provided for @steamHelperReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the library helper response'**
  String get steamHelperReadFailed;

  /// No description provided for @steamHelperStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the library helper. Make sure ssf_steam_helper.exe is installed alongside SSF.'**
  String get steamHelperStartFailed;

  /// No description provided for @steamHelperStopUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm that the process stopped. Try cancelling again.'**
  String get steamHelperStopUnconfirmed;

  /// No description provided for @steamId.
  ///
  /// In en, this message translates to:
  /// **'SteamID'**
  String get steamId;

  /// No description provided for @steamLibraryFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Could not get the library (code {arg0}).'**
  String steamLibraryFailedWithCode(Object arg0);

  /// No description provided for @steamLibraryLoading.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Loading the library…'**
  String get steamLibraryLoading;

  /// No description provided for @steamLibraryMerging.
  ///
  /// In en, this message translates to:
  /// **'Combining library data…'**
  String get steamLibraryMerging;

  /// No description provided for @steamLibraryPartialStatus.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Library data is partially available.'**
  String get steamLibraryPartialStatus;

  /// No description provided for @steamLibraryReceived.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Library received.'**
  String get steamLibraryReceived;

  /// No description provided for @steamLibraryTimeout.
  ///
  /// In en, this message translates to:
  /// **'Signed in, but the library request timed out.'**
  String get steamLibraryTimeout;

  /// No description provided for @steamMetadataLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading app names and types…'**
  String get steamMetadataLoading;

  /// No description provided for @steamMobileConfirmationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Approve the sign-in in the Steam app on your phone'**
  String get steamMobileConfirmationPrompt;

  /// No description provided for @steamPersonalLibraryLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading licenses and your apps…'**
  String get steamPersonalLibraryLoading;

  /// No description provided for @steamPlaytimeUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating playtime…'**
  String get steamPlaytimeUpdating;

  /// No description provided for @steamPrivateAppsChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking private apps…'**
  String get steamPrivateAppsChecking;

  /// No description provided for @steamQrAccessibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'QR code for signing in with Steam Mobile'**
  String get steamQrAccessibilityLabel;

  /// No description provided for @steamQrInstructions.
  ///
  /// In en, this message translates to:
  /// **'Use the Steam mobile app to sign in with a QR code'**
  String get steamQrInstructions;

  /// No description provided for @steamQrScanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code in Steam Mobile and approve the sign-in'**
  String get steamQrScanPrompt;

  /// No description provided for @steamQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Or use a QR code'**
  String get steamQrTitle;

  /// No description provided for @steamSessionActive.
  ///
  /// In en, this message translates to:
  /// **'You already have an active session'**
  String get steamSessionActive;

  /// No description provided for @steamSessionChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the saved session…'**
  String get steamSessionChecking;

  /// No description provided for @steamSessionPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'Your password is not saved. The protected session is used for future refreshes without signing in again.'**
  String get steamSessionPrivacyHint;

  /// No description provided for @steamSessionReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the saved session'**
  String get steamSessionReadFailed;

  /// No description provided for @steamSignedOutCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Signed out. Library cache cleared.'**
  String get steamSignedOutCacheCleared;

  /// No description provided for @steamSignedOutStatus.
  ///
  /// In en, this message translates to:
  /// **'Signed out of Steam. Choose a sign-in method.'**
  String get steamSignedOutStatus;

  /// No description provided for @steamSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled'**
  String get steamSignInCancelled;

  /// No description provided for @steamSignInCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling sign-in…'**
  String get steamSignInCancelling;

  /// No description provided for @steamSignInFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in (code {arg0}). Please try again.'**
  String steamSignInFailedWithCode(Object arg0);

  /// No description provided for @steamSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out and clearing the cache…'**
  String get steamSigningOut;

  /// No description provided for @steamSignInMethodPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a sign-in method'**
  String get steamSignInMethodPrompt;

  /// No description provided for @steamSignInTimeout.
  ///
  /// In en, this message translates to:
  /// **'Sign-in timed out'**
  String get steamSignInTimeout;

  /// No description provided for @steamSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not finish signing out. Please try again.'**
  String get steamSignOutFailed;

  /// No description provided for @steamSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in or library request failed: {arg0}'**
  String steamSyncFailed(Object arg0);

  /// No description provided for @stopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAction;

  /// No description provided for @stopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop all'**
  String get stopAll;

  /// No description provided for @stopAllProcessesDescription.
  ///
  /// In en, this message translates to:
  /// **'All games and Steam helper processes started by this SteamSpaceFarm instance will be stopped. Queued launches and library refresh will be cancelled.'**
  String get stopAllProcessesDescription;

  /// No description provided for @stopAllProcessesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not force stop the processes.'**
  String get stopAllProcessesFailed;

  /// No description provided for @stopAllProcessesTitle.
  ///
  /// In en, this message translates to:
  /// **'Force stop everything?'**
  String get stopAllProcessesTitle;

  /// No description provided for @stopBatchQueueDescription.
  ///
  /// In en, this message translates to:
  /// **'The queue will be cleared and the apps it launched will be stopped.'**
  String get stopBatchQueueDescription;

  /// No description provided for @stopManualApps.
  ///
  /// In en, this message translates to:
  /// **'Stop manual apps'**
  String get stopManualApps;

  /// No description provided for @stopManualAppsCount.
  ///
  /// In en, this message translates to:
  /// **'Stop manual apps · {arg0}'**
  String stopManualAppsCount(Object arg0);

  /// No description provided for @stopManualAppsDescription.
  ///
  /// In en, this message translates to:
  /// **'Apps launched manually in this session will be stopped: {arg0}.'**
  String stopManualAppsDescription(Object arg0);

  /// No description provided for @stopManualAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop manually launched apps?'**
  String get stopManualAppsTitle;

  /// No description provided for @stopMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get stopMenuLabel;

  /// No description provided for @stopQueue.
  ///
  /// In en, this message translates to:
  /// **'Stop queue'**
  String get stopQueue;

  /// No description provided for @stopQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the active queue?'**
  String get stopQueueTitle;

  /// No description provided for @stopSequentialQueueDescription.
  ///
  /// In en, this message translates to:
  /// **'The current app will stop and the remaining {arg0} entries will be removed.'**
  String stopSequentialQueueDescription(Object arg0);

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'STORAGE'**
  String get storage;

  /// No description provided for @targetAlreadyReachedHint.
  ///
  /// In en, this message translates to:
  /// **'Current playtime is {arg0} min. This target will be cleared because it has already been reached.'**
  String targetAlreadyReachedHint(Object arg0);

  /// No description provided for @targetPlaytime.
  ///
  /// In en, this message translates to:
  /// **'Target playtime'**
  String get targetPlaytime;

  /// No description provided for @targetPlaytimeInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Target playtime in minutes'**
  String get targetPlaytimeInMinutes;

  /// No description provided for @targetRangeBoundsHint.
  ///
  /// In en, this message translates to:
  /// **'Targets apply to apps from the minimum playtime inclusive to the maximum exclusive.'**
  String get targetRangeBoundsHint;

  /// No description provided for @technicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical details'**
  String get technicalDetails;

  /// No description provided for @timeUntilTarget.
  ///
  /// In en, this message translates to:
  /// **'Time until target'**
  String get timeUntilTarget;

  /// No description provided for @tool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get tool;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @clearText.
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get clearText;

  /// No description provided for @refreshOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Refresh library on startup'**
  String get refreshOnStartup;

  /// No description provided for @refreshOnStartupHint.
  ///
  /// In en, this message translates to:
  /// **'Show the cached library immediately and refresh in the background using the saved session.'**
  String get refreshOnStartupHint;

  /// No description provided for @runnerSteamPresenceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not switch to Invisible. Check your Steam connection and try again.'**
  String get runnerSteamPresenceFailed;

  /// No description provided for @invisibleWhilePlaying.
  ///
  /// In en, this message translates to:
  /// **'Go invisible when starting games'**
  String get invisibleWhilePlaying;

  /// No description provided for @invisibleWhilePlayingHint.
  ///
  /// In en, this message translates to:
  /// **'For Steamworks and SteamKit. Restores your previous status after all games stop. SteamKit also works without the local Steam client.'**
  String get invisibleWhilePlayingHint;

  /// No description provided for @experimentalSteamKit.
  ///
  /// In en, this message translates to:
  /// **'Run without the Steam client open'**
  String get experimentalSteamKit;

  /// No description provided for @experimentalSteamKitHint.
  ///
  /// In en, this message translates to:
  /// **'Just sign in to SteamSpaceFarm. Game sessions and Invisible status work even when the Steam client is closed. Steam determines whether playtime is recorded.'**
  String get experimentalSteamKitHint;

  /// No description provided for @gamesBlockLibrary.
  ///
  /// In en, this message translates to:
  /// **'Stop all games before refreshing the library or signing out.'**
  String get gamesBlockLibrary;

  /// No description provided for @leaveLibraryUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop updating the library?'**
  String get leaveLibraryUpdateTitle;

  /// No description provided for @leaveLibraryUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Leaving this screen will stop the library update. The saved catalog will remain available.'**
  String get leaveLibraryUpdateMessage;

  /// No description provided for @leaveScreen.
  ///
  /// In en, this message translates to:
  /// **'Stop and leave'**
  String get leaveScreen;

  /// No description provided for @libraryRefreshInProgress.
  ///
  /// In en, this message translates to:
  /// **'The library is updating. Wait for it to finish before starting games.'**
  String get libraryRefreshInProgress;

  /// No description provided for @sessionSettings.
  ///
  /// In en, this message translates to:
  /// **'Library and sessions'**
  String get sessionSettings;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @runnerSteamKitFailed.
  ///
  /// In en, this message translates to:
  /// **'SteamKit could not confirm the session. Sign in to Steam again and retry.'**
  String get runnerSteamKitFailed;

  /// No description provided for @sessionSettingsShort.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionSettingsShort;

  /// No description provided for @gameSessionInterrupted.
  ///
  /// In en, this message translates to:
  /// **'The session for {name} (AppID {appId}) ended unexpectedly. Check your Steam connection before restarting. Active queues have been paused.'**
  String gameSessionInterrupted(String name, int appId);

  /// No description provided for @steamPresenceRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore your previous Steam status after several attempts. Check your status in Steam.'**
  String get steamPresenceRestoreFailed;

  /// No description provided for @cardFarmingMode.
  ///
  /// In en, this message translates to:
  /// **'Card farming mode'**
  String get cardFarmingMode;

  /// No description provided for @cardModeFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get cardModeFast;

  /// No description provided for @cardModeSequential.
  ///
  /// In en, this message translates to:
  /// **'One at a time'**
  String get cardModeSequential;

  /// No description provided for @cardModeCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get cardModeCombined;

  /// No description provided for @cardModeFastHint.
  ///
  /// In en, this message translates to:
  /// **'Alternates 5 minutes of simultaneous sessions with short individual sessions.'**
  String get cardModeFastHint;

  /// No description provided for @cardModeSequentialHint.
  ///
  /// In en, this message translates to:
  /// **'Runs one game until its available card drops are exhausted, then moves to the next.'**
  String get cardModeSequentialHint;

  /// No description provided for @cardModeCombinedHint.
  ///
  /// In en, this message translates to:
  /// **'First builds up 2 hours in multiple games, then farms one game at a time.'**
  String get cardModeCombinedHint;

  /// No description provided for @refreshPlaytimeHourly.
  ///
  /// In en, this message translates to:
  /// **'Update Steam playtime every hour'**
  String get refreshPlaytimeHourly;

  /// No description provided for @refreshPlaytimeHourlyHint.
  ///
  /// In en, this message translates to:
  /// **'Temporarily stops sessions, retrieves playtime from Steam, then resumes them.'**
  String get refreshPlaytimeHourlyHint;

  /// No description provided for @cardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trading cards'**
  String get cardsTitle;

  /// No description provided for @cardsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Check card drops'**
  String get cardsRefresh;

  /// No description provided for @cardsStartAll.
  ///
  /// In en, this message translates to:
  /// **'Farm all cards'**
  String get cardsStartAll;

  /// No description provided for @cardsStart.
  ///
  /// In en, this message translates to:
  /// **'Farm cards'**
  String get cardsStart;

  /// No description provided for @cardsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Card drops have not been checked yet'**
  String get cardsUnknown;

  /// No description provided for @cardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get cardsEmpty;

  /// No description provided for @cardsPartial.
  ///
  /// In en, this message translates to:
  /// **'Data is incomplete. An unknown count is not treated as zero.'**
  String get cardsPartial;

  /// No description provided for @cardsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check data or run the session. Please retry.'**
  String get cardsFailed;

  /// No description provided for @cardsPriority.
  ///
  /// In en, this message translates to:
  /// **'Cards take priority over regular playtime. Hour progress is preserved.'**
  String get cardsPriority;

  /// No description provided for @cardsFilter.
  ///
  /// In en, this message translates to:
  /// **'With card drops'**
  String get cardsFilter;

  /// No description provided for @cardsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Card drops remaining: {count}'**
  String cardsRemaining(int count);

  /// No description provided for @cardsCheckedAt.
  ///
  /// In en, this message translates to:
  /// **'Checked: {time}'**
  String cardsCheckedAt(String time);

  /// No description provided for @cardsQueued.
  ///
  /// In en, this message translates to:
  /// **'Card games queued: {count}'**
  String cardsQueued(int count);

  /// No description provided for @workPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing sessions'**
  String get workPreparing;

  /// No description provided for @workGroup.
  ///
  /// In en, this message translates to:
  /// **'Cards: simultaneous sessions'**
  String get workGroup;

  /// No description provided for @workSingle.
  ///
  /// In en, this message translates to:
  /// **'Cards: one game'**
  String get workSingle;

  /// No description provided for @workChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking remaining card drops'**
  String get workChecking;

  /// No description provided for @workWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting / paused'**
  String get workWaiting;

  /// No description provided for @workSyncing.
  ///
  /// In en, this message translates to:
  /// **'Updating Steam playtime'**
  String get workSyncing;

  /// No description provided for @cardsStopDescription.
  ///
  /// In en, this message translates to:
  /// **'Stop card farming and resume waiting playtime sessions?'**
  String get cardsStopDescription;

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'Cards {count}'**
  String cardsCount(int count);
}

class _GeneratedLocalizationsDelegate extends LocalizationsDelegate<GeneratedLocalizations> {
  const _GeneratedLocalizationsDelegate();

  @override
  Future<GeneratedLocalizations> load(Locale locale) {
    return SynchronousFuture<GeneratedLocalizations>(lookupGeneratedLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_GeneratedLocalizationsDelegate old) => false;
}

GeneratedLocalizations lookupGeneratedLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return GeneratedLocalizationsEn();
    case 'es':
      return GeneratedLocalizationsEs();
    case 'ru':
      return GeneratedLocalizationsRu();
    case 'zh':
      return GeneratedLocalizationsZh();
  }

  throw FlutterError(
    'GeneratedLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
