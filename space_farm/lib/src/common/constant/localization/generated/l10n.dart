// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class GeneratedLocalizations {
  GeneratedLocalizations();

  static GeneratedLocalizations? _current;

  static GeneratedLocalizations get current {
    assert(_current != null,
        'No instance of GeneratedLocalizations was loaded. Try to initialize the GeneratedLocalizations delegate before accessing GeneratedLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<GeneratedLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
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
    assert(instance != null,
        'No instance of GeneratedLocalizations present in the widget tree. Did you add GeneratedLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static GeneratedLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<GeneratedLocalizations>(
        context, GeneratedLocalizations);
  }

  /// `Space Farm`
  String get appTitle {
    return Intl.message(
      'Space Farm',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get categoryGames {
    return Intl.message(
      'Games',
      name: 'categoryGames',
      desc: '',
      args: [],
    );
  }

  /// `Demos`
  String get categoryDemos {
    return Intl.message(
      'Demos',
      name: 'categoryDemos',
      desc: '',
      args: [],
    );
  }

  /// `Soundtracks`
  String get categorySoundtracks {
    return Intl.message(
      'Soundtracks',
      name: 'categorySoundtracks',
      desc: '',
      args: [],
    );
  }

  /// `Software`
  String get categorySoftware {
    return Intl.message(
      'Software',
      name: 'categorySoftware',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get categoryVideos {
    return Intl.message(
      'Videos',
      name: 'categoryVideos',
      desc: '',
      args: [],
    );
  }

  /// `Tools`
  String get categoryTools {
    return Intl.message(
      'Tools',
      name: 'categoryTools',
      desc: '',
      args: [],
    );
  }

  /// `DLC`
  String get categoryDlc {
    return Intl.message(
      'DLC',
      name: 'categoryDlc',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get categoryOther {
    return Intl.message(
      'Other',
      name: 'categoryOther',
      desc: '',
      args: [],
    );
  }

  /// `By time`
  String get sortByTime {
    return Intl.message(
      'By time',
      name: 'sortByTime',
      desc: '',
      args: [],
    );
  }

  /// `Alphabetically`
  String get sortAlphabetically {
    return Intl.message(
      'Alphabetically',
      name: 'sortAlphabetically',
      desc: '',
      args: [],
    );
  }

  /// `By launch date`
  String get sortByLaunchDate {
    return Intl.message(
      'By launch date',
      name: 'sortByLaunchDate',
      desc: '',
      args: [],
    );
  }

  /// `Hours`
  String get filterByHours {
    return Intl.message(
      'Hours',
      name: 'filterByHours',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get filterByMinutes {
    return Intl.message(
      'Minutes',
      name: 'filterByMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Running`
  String get filterRunning {
    return Intl.message(
      'Running',
      name: 'filterRunning',
      desc: '',
      args: [],
    );
  }

  /// `Marked`
  String get filterMarked {
    return Intl.message(
      'Marked',
      name: 'filterMarked',
      desc: '',
      args: [],
    );
  }

  /// `Hidden`
  String get filterHidden {
    return Intl.message(
      'Hidden',
      name: 'filterHidden',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get filterFavorites {
    return Intl.message(
      'Favorites',
      name: 'filterFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Min`
  String get filterMin {
    return Intl.message(
      'Min',
      name: 'filterMin',
      desc: '',
      args: [],
    );
  }

  /// `Max`
  String get filterMax {
    return Intl.message(
      'Max',
      name: 'filterMax',
      desc: '',
      args: [],
    );
  }

  /// `Search by name`
  String get searchByName {
    return Intl.message(
      'Search by name',
      name: 'searchByName',
      desc: '',
      args: [],
    );
  }

  /// `Launch marked`
  String get actionLaunchMarked {
    return Intl.message(
      'Launch marked',
      name: 'actionLaunchMarked',
      desc: '',
      args: [],
    );
  }

  /// `Launch favorites`
  String get actionLaunchFavorites {
    return Intl.message(
      'Launch favorites',
      name: 'actionLaunchFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Mark`
  String get actionMark {
    return Intl.message(
      'Mark',
      name: 'actionMark',
      desc: '',
      args: [],
    );
  }

  /// `Add to favorites`
  String get actionAddToFavorites {
    return Intl.message(
      'Add to favorites',
      name: 'actionAddToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Remove from favorites`
  String get actionRemoveFromFavorites {
    return Intl.message(
      'Remove from favorites',
      name: 'actionRemoveFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Change playtime`
  String get actionChangePlaytime {
    return Intl.message(
      'Change playtime',
      name: 'actionChangePlaytime',
      desc: '',
      args: [],
    );
  }

  /// `Change stop time`
  String get actionChangeStopTime {
    return Intl.message(
      'Change stop time',
      name: 'actionChangeStopTime',
      desc: '',
      args: [],
    );
  }

  /// `Copy ID`
  String get actionCopyId {
    return Intl.message(
      'Copy ID',
      name: 'actionCopyId',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingsLanguage {
    return Intl.message(
      'Language',
      name: 'settingsLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Russian`
  String get languageRussian {
    return Intl.message(
      'Russian',
      name: 'languageRussian',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get languageEnglish {
    return Intl.message(
      'English',
      name: 'languageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Card type`
  String get cardType {
    return Intl.message(
      'Card type',
      name: 'cardType',
      desc: '',
      args: [],
    );
  }

  /// `Load/update games`
  String get loadGames {
    return Intl.message(
      'Load/update games',
      name: 'loadGames',
      desc: '',
      args: [],
    );
  }

  /// `Download hidden Steam games data`
  String get loadHiddenGamesData {
    return Intl.message(
      'Download hidden Steam games data',
      name: 'loadHiddenGamesData',
      desc: '',
      args: [],
    );
  }

  /// `Steam Guard confirmation is required. This information is not sent anywhere.`
  String get steamGuardNotice {
    return Intl.message(
      'Steam Guard confirmation is required. This information is not sent anywhere.',
      name: 'steamGuardNotice',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Save login and password`
  String get saveLoginAndPassword {
    return Intl.message(
      'Save login and password',
      name: 'saveLoginAndPassword',
      desc: '',
      args: [],
    );
  }

  /// `Steam API Key`
  String get steamApiKey {
    return Intl.message(
      'Steam API Key',
      name: 'steamApiKey',
      desc: '',
      args: [],
    );
  }

  /// `How to get?`
  String get howToGet {
    return Intl.message(
      'How to get?',
      name: 'howToGet',
      desc: '',
      args: [],
    );
  }

  /// `SteamID`
  String get steamId {
    return Intl.message(
      'SteamID',
      name: 'steamId',
      desc: '',
      args: [],
    );
  }

  /// `Load`
  String get loadAction {
    return Intl.message(
      'Load',
      name: 'loadAction',
      desc: '',
      args: [],
    );
  }

  /// `all (including hidden)`
  String get loadAllIncludingHidden {
    return Intl.message(
      'all (including hidden)',
      name: 'loadAllIncludingHidden',
      desc: '',
      args: [],
    );
  }

  /// `games`
  String get loadActionGames {
    return Intl.message(
      'games',
      name: 'loadActionGames',
      desc: '',
      args: [],
    );
  }

  /// `Load from SteamKit. Steam Guard confirmation may be required`
  String get loadFromSteamKit {
    return Intl.message(
      'Load from SteamKit. Steam Guard confirmation may be required',
      name: 'loadFromSteamKit',
      desc: '',
      args: [],
    );
  }

  /// `Load from WebAPI`
  String get loadFromWebApi {
    return Intl.message(
      'Load from WebAPI',
      name: 'loadFromWebApi',
      desc: '',
      args: [],
    );
  }

  /// `An error may occur while loading. If you chose Steam Guard, refresh the page`
  String get steamGuardRetryNotice {
    return Intl.message(
      'An error may occur while loading. If you chose Steam Guard, refresh the page',
      name: 'steamGuardRetryNotice',
      desc: '',
      args: [],
    );
  }

  /// `Login, password, and API key must not be empty`
  String get emptyAuthFieldsError {
    return Intl.message(
      'Login, password, and API key must not be empty',
      name: 'emptyAuthFieldsError',
      desc: '',
      args: [],
    );
  }

  /// `API key and SteamID must not be empty`
  String get emptyApiKeyOrSteamIdError {
    return Intl.message(
      'API key and SteamID must not be empty',
      name: 'emptyApiKeyOrSteamIdError',
      desc: '',
      args: [],
    );
  }

  /// `Initialization failed`
  String get initializationFailed {
    return Intl.message(
      'Initialization failed',
      name: 'initializationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Set time for {game}`
  String changeTimeForGame(Object game) {
    return Intl.message(
      'Set time for $game',
      name: 'changeTimeForGame',
      desc: '',
      args: [game],
    );
  }

  /// `Auto stop for {game}`
  String changeStopTimeForGame(Object game) {
    return Intl.message(
      'Auto stop for $game',
      name: 'changeStopTimeForGame',
      desc: '',
      args: [game],
    );
  }

  /// `Time in minutes`
  String get timeInMinutes {
    return Intl.message(
      'Time in minutes',
      name: 'timeInMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get minutesShort {
    return Intl.message(
      'min',
      name: 'minutesShort',
      desc: '',
      args: [],
    );
  }

  /// `h`
  String get hoursShort {
    return Intl.message(
      'h',
      name: 'hoursShort',
      desc: '',
      args: [],
    );
  }

  /// `Stop time`
  String get autoStopTime {
    return Intl.message(
      'Stop time',
      name: 'autoStopTime',
      desc: '',
      args: [],
    );
  }

  /// `Mark`
  String get markGame {
    return Intl.message(
      'Mark',
      name: 'markGame',
      desc: '',
      args: [],
    );
  }

  /// `Mark games for auto start`
  String get markGamesToAutoStart {
    return Intl.message(
      'Mark games for auto start',
      name: 'markGamesToAutoStart',
      desc: '',
      args: [],
    );
  }

  /// `Stopped (Auto)`
  String get autoStopped {
    return Intl.message(
      'Stopped (Auto)',
      name: 'autoStopped',
      desc: '',
      args: [],
    );
  }

  /// `games`
  String get totalGamesCount {
    return Intl.message(
      'games',
      name: 'totalGamesCount',
      desc: '',
      args: [],
    );
  }

  /// `Auto Stop`
  String get autoStop {
    return Intl.message(
      'Auto Stop',
      name: 'autoStop',
      desc: '',
      args: [],
    );
  }

  /// `Manual Stop`
  String get manualStop {
    return Intl.message(
      'Manual Stop',
      name: 'manualStop',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop {
    return Intl.message(
      'Stop',
      name: 'stop',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get manualStart {
    return Intl.message(
      'Manual',
      name: 'manualStart',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get autoStart {
    return Intl.message(
      'Auto',
      name: 'autoStart',
      desc: '',
      args: [],
    );
  }

  /// `Game list is empty`
  String get emptyGameList {
    return Intl.message(
      'Game list is empty',
      name: 'emptyGameList',
      desc: '',
      args: [],
    );
  }

  /// `Games loaded from account`
  String get gamesLoadedFromAccount {
    return Intl.message(
      'Games loaded from account',
      name: 'gamesLoadedFromAccount',
      desc: '',
      args: [],
    );
  }

  /// `HARDSTOP`
  String get hardStop {
    return Intl.message(
      'HARDSTOP',
      name: 'hardStop',
      desc: '',
      args: [],
    );
  }

  /// `Prepared`
  String get prepared {
    return Intl.message(
      'Prepared',
      name: 'prepared',
      desc: '',
      args: [],
    );
  }

  /// `Games prepared for auto start`
  String get autoRunningGamesCount {
    return Intl.message(
      'Games prepared for auto start',
      name: 'autoRunningGamesCount',
      desc: '',
      args: [],
    );
  }

  /// `Error loading games`
  String get errorLoadingGames {
    return Intl.message(
      'Error loading games',
      name: 'errorLoadingGames',
      desc: '',
      args: [],
    );
  }

  /// `Stop ALL Steam games`
  String get stopAllSteamGames {
    return Intl.message(
      'Stop ALL Steam games',
      name: 'stopAllSteamGames',
      desc: '',
      args: [],
    );
  }

  /// `This will stop all processes, including those not shown in the app`
  String get stopAllSteamGamesWarning {
    return Intl.message(
      'This will stop all processes, including those not shown in the app',
      name: 'stopAllSteamGamesWarning',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<GeneratedLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<GeneratedLocalizations> load(Locale locale) =>
      GeneratedLocalizations.load(locale);
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
