// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(game) => "Auto stop for ${game}";

  static String m1(game) => "Set time for ${game}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAddToFavorites":
            MessageLookupByLibrary.simpleMessage("Add to favorites"),
        "actionChangePlaytime":
            MessageLookupByLibrary.simpleMessage("Change playtime"),
        "actionChangeStopTime":
            MessageLookupByLibrary.simpleMessage("Change stop time"),
        "actionCopyId": MessageLookupByLibrary.simpleMessage("Copy ID"),
        "actionLaunchFavorites":
            MessageLookupByLibrary.simpleMessage("Launch favorites"),
        "actionLaunchMarked":
            MessageLookupByLibrary.simpleMessage("Launch marked"),
        "actionMark": MessageLookupByLibrary.simpleMessage("Mark"),
        "actionRemoveFromFavorites":
            MessageLookupByLibrary.simpleMessage("Remove from favorites"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Space Farm"),
        "autoRunningGamesCount": MessageLookupByLibrary.simpleMessage(
            "Games prepared for auto start"),
        "autoStart": MessageLookupByLibrary.simpleMessage("Auto"),
        "autoStop": MessageLookupByLibrary.simpleMessage("Auto Stop"),
        "autoStopTime": MessageLookupByLibrary.simpleMessage("Stop time"),
        "autoStopped": MessageLookupByLibrary.simpleMessage("Stopped (Auto)"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cardType": MessageLookupByLibrary.simpleMessage("Card type"),
        "categoryDemos": MessageLookupByLibrary.simpleMessage("Demos"),
        "categoryDlc": MessageLookupByLibrary.simpleMessage("DLC"),
        "categoryGames": MessageLookupByLibrary.simpleMessage("Games"),
        "categoryOther": MessageLookupByLibrary.simpleMessage("Other"),
        "categorySoftware": MessageLookupByLibrary.simpleMessage("Software"),
        "categorySoundtracks":
            MessageLookupByLibrary.simpleMessage("Soundtracks"),
        "categoryTools": MessageLookupByLibrary.simpleMessage("Tools"),
        "categoryVideos": MessageLookupByLibrary.simpleMessage("Videos"),
        "changeStopTimeForGame": m0,
        "changeTimeForGame": m1,
        "emptyApiKeyOrSteamIdError": MessageLookupByLibrary.simpleMessage(
            "API key and SteamID must not be empty"),
        "emptyAuthFieldsError": MessageLookupByLibrary.simpleMessage(
            "Login, password, and API key must not be empty"),
        "emptyGameList":
            MessageLookupByLibrary.simpleMessage("Game list is empty"),
        "errorLoadingGames":
            MessageLookupByLibrary.simpleMessage("Error loading games"),
        "filterByHours": MessageLookupByLibrary.simpleMessage("Hours"),
        "filterByMinutes": MessageLookupByLibrary.simpleMessage("Minutes"),
        "filterFavorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "filterHidden": MessageLookupByLibrary.simpleMessage("Hidden"),
        "filterMarked": MessageLookupByLibrary.simpleMessage("Marked"),
        "filterMax": MessageLookupByLibrary.simpleMessage("Max"),
        "filterMin": MessageLookupByLibrary.simpleMessage("Min"),
        "filterRunning": MessageLookupByLibrary.simpleMessage("Running"),
        "gamesLoadedFromAccount":
            MessageLookupByLibrary.simpleMessage("Games loaded from account"),
        "hardStop": MessageLookupByLibrary.simpleMessage("HARDSTOP"),
        "hoursShort": MessageLookupByLibrary.simpleMessage("h"),
        "howToGet": MessageLookupByLibrary.simpleMessage("How to get?"),
        "initializationFailed":
            MessageLookupByLibrary.simpleMessage("Initialization failed"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
        "languageRussian": MessageLookupByLibrary.simpleMessage("Russian"),
        "loadAction": MessageLookupByLibrary.simpleMessage("Load"),
        "loadActionGames": MessageLookupByLibrary.simpleMessage("games"),
        "loadAllIncludingHidden":
            MessageLookupByLibrary.simpleMessage("all (including hidden)"),
        "loadFromSteamKit": MessageLookupByLibrary.simpleMessage(
            "Load from SteamKit. Steam Guard confirmation may be required"),
        "loadFromWebApi":
            MessageLookupByLibrary.simpleMessage("Load from WebAPI"),
        "loadGames": MessageLookupByLibrary.simpleMessage("Load/update games"),
        "loadHiddenGamesData": MessageLookupByLibrary.simpleMessage(
            "Download hidden Steam games data"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "manualStart": MessageLookupByLibrary.simpleMessage("Manual"),
        "manualStop": MessageLookupByLibrary.simpleMessage("Manual Stop"),
        "markGame": MessageLookupByLibrary.simpleMessage("Mark"),
        "markGamesToAutoStart":
            MessageLookupByLibrary.simpleMessage("Mark games for auto start"),
        "minutesShort": MessageLookupByLibrary.simpleMessage("min"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "prepared": MessageLookupByLibrary.simpleMessage("Prepared"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveLoginAndPassword":
            MessageLookupByLibrary.simpleMessage("Save login and password"),
        "searchByName": MessageLookupByLibrary.simpleMessage("Search by name"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsLanguage": MessageLookupByLibrary.simpleMessage("Language"),
        "sortAlphabetically":
            MessageLookupByLibrary.simpleMessage("Alphabetically"),
        "sortByLaunchDate":
            MessageLookupByLibrary.simpleMessage("By launch date"),
        "sortByTime": MessageLookupByLibrary.simpleMessage("By time"),
        "steamApiKey": MessageLookupByLibrary.simpleMessage("Steam API Key"),
        "steamGuardNotice": MessageLookupByLibrary.simpleMessage(
            "Steam Guard confirmation is required. This information is not sent anywhere."),
        "steamGuardRetryNotice": MessageLookupByLibrary.simpleMessage(
            "An error may occur while loading. If you chose Steam Guard, refresh the page"),
        "steamId": MessageLookupByLibrary.simpleMessage("SteamID"),
        "stop": MessageLookupByLibrary.simpleMessage("Stop"),
        "stopAllSteamGames":
            MessageLookupByLibrary.simpleMessage("Stop ALL Steam games"),
        "stopAllSteamGamesWarning": MessageLookupByLibrary.simpleMessage(
            "This will stop all processes, including those not shown in the app"),
        "timeInMinutes":
            MessageLookupByLibrary.simpleMessage("Time in minutes"),
        "totalGamesCount": MessageLookupByLibrary.simpleMessage("games")
      };
}
