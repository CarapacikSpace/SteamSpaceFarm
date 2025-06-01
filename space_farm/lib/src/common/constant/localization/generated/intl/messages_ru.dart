// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(game) => "Автоостановка для ${game}";

  static String m1(game) => "Установить время для ${game}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAddToFavorites":
            MessageLookupByLibrary.simpleMessage("Добавить в избранное"),
        "actionChangePlaytime":
            MessageLookupByLibrary.simpleMessage("Сменить текущее время"),
        "actionChangeStopTime":
            MessageLookupByLibrary.simpleMessage("Сменить время остановки"),
        "actionCopyId": MessageLookupByLibrary.simpleMessage("Скопировать ID"),
        "actionLaunchFavorites":
            MessageLookupByLibrary.simpleMessage("Запустить избранные"),
        "actionLaunchMarked":
            MessageLookupByLibrary.simpleMessage("Запустить отмеченные"),
        "actionMark": MessageLookupByLibrary.simpleMessage("Отметить"),
        "actionRemoveFromFavorites":
            MessageLookupByLibrary.simpleMessage("Убрать из избранного"),
        "all": MessageLookupByLibrary.simpleMessage("Все"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Space Farm"),
        "autoRunningGamesCount":
            MessageLookupByLibrary.simpleMessage("игр для авто запуска"),
        "autoStart": MessageLookupByLibrary.simpleMessage("Авто"),
        "autoStop": MessageLookupByLibrary.simpleMessage("Остановить Авто"),
        "autoStopTime": MessageLookupByLibrary.simpleMessage("Конечное время"),
        "autoStopped": MessageLookupByLibrary.simpleMessage("Конечные"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "cardType": MessageLookupByLibrary.simpleMessage("Тип карточки"),
        "categoryDemos": MessageLookupByLibrary.simpleMessage("Демо"),
        "categoryDlc": MessageLookupByLibrary.simpleMessage("DLC"),
        "categoryGames": MessageLookupByLibrary.simpleMessage("Игры"),
        "categoryOther": MessageLookupByLibrary.simpleMessage("Другие"),
        "categorySoftware": MessageLookupByLibrary.simpleMessage("Программы"),
        "categorySoundtracks":
            MessageLookupByLibrary.simpleMessage("Саундтреки"),
        "categoryTools": MessageLookupByLibrary.simpleMessage("Инструменты"),
        "categoryVideos": MessageLookupByLibrary.simpleMessage("Видео"),
        "changeStopTimeForGame": m0,
        "changeTimeForGame": m1,
        "emptyApiKeyOrSteamIdError": MessageLookupByLibrary.simpleMessage(
            "API ключ и SteamID не должны быть пустыми"),
        "emptyAuthFieldsError": MessageLookupByLibrary.simpleMessage(
            "Логин, пароль и API ключ не должны быть пустыми"),
        "emptyGameList":
            MessageLookupByLibrary.simpleMessage("Список игр пуст"),
        "errorLoadingGames":
            MessageLookupByLibrary.simpleMessage("Ошибка при загрузке игр"),
        "filterByHours": MessageLookupByLibrary.simpleMessage("Часы"),
        "filterByMinutes": MessageLookupByLibrary.simpleMessage("Минуты"),
        "filterFavorites": MessageLookupByLibrary.simpleMessage("Избранные"),
        "filterHidden": MessageLookupByLibrary.simpleMessage("Скрытые"),
        "filterMarked": MessageLookupByLibrary.simpleMessage("Отмеченные"),
        "filterMax": MessageLookupByLibrary.simpleMessage("Макс"),
        "filterMin": MessageLookupByLibrary.simpleMessage("Мин"),
        "filterRunning": MessageLookupByLibrary.simpleMessage("Запущенные"),
        "gamesLoadedFromAccount": MessageLookupByLibrary.simpleMessage(
            "Игры с учётной записи загружены"),
        "hardStop": MessageLookupByLibrary.simpleMessage("HARDSTOP"),
        "hoursShort": MessageLookupByLibrary.simpleMessage("ч"),
        "howToGet": MessageLookupByLibrary.simpleMessage("Как получить?"),
        "initializationFailed":
            MessageLookupByLibrary.simpleMessage("Инициализация неудачна"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("Английский"),
        "languageRussian": MessageLookupByLibrary.simpleMessage("Русский"),
        "loadAction": MessageLookupByLibrary.simpleMessage("Загрузить"),
        "loadActionGames": MessageLookupByLibrary.simpleMessage("игры"),
        "loadAllIncludingHidden":
            MessageLookupByLibrary.simpleMessage("все (включая скрытые)"),
        "loadFromSteamKit": MessageLookupByLibrary.simpleMessage(
            "Загрузка из SteamKit. Может потребоваться подтверждение Steam Guard"),
        "loadFromWebApi":
            MessageLookupByLibrary.simpleMessage("Загрузка из WebAPI"),
        "loadGames":
            MessageLookupByLibrary.simpleMessage("Загрузить/обновить игры"),
        "loadHiddenGamesData": MessageLookupByLibrary.simpleMessage(
            "Скачать данные скрытых игр Steam"),
        "login": MessageLookupByLibrary.simpleMessage("Логин"),
        "manualStart": MessageLookupByLibrary.simpleMessage("Вручную"),
        "manualStop":
            MessageLookupByLibrary.simpleMessage("Остановить Вручную"),
        "markGame": MessageLookupByLibrary.simpleMessage("Пометить"),
        "markGamesToAutoStart": MessageLookupByLibrary.simpleMessage(
            "Пометить игры для автозапуска"),
        "minutesShort": MessageLookupByLibrary.simpleMessage("мин"),
        "password": MessageLookupByLibrary.simpleMessage("Пароль"),
        "prepared": MessageLookupByLibrary.simpleMessage("Подготовлено"),
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "saveLoginAndPassword":
            MessageLookupByLibrary.simpleMessage("Сохранять логин и пароль"),
        "searchByName":
            MessageLookupByLibrary.simpleMessage("Поиск по названию"),
        "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "settingsLanguage": MessageLookupByLibrary.simpleMessage("Язык"),
        "sortAlphabetically":
            MessageLookupByLibrary.simpleMessage("По алфавиту"),
        "sortByLaunchDate":
            MessageLookupByLibrary.simpleMessage("По дате запуска"),
        "sortByTime": MessageLookupByLibrary.simpleMessage("По времени"),
        "steamApiKey": MessageLookupByLibrary.simpleMessage("Steam API Key"),
        "steamGuardNotice": MessageLookupByLibrary.simpleMessage(
            "Необходимо подтвердить вход через Steam Guard. Эта информация никуда не отправляется."),
        "steamGuardRetryNotice": MessageLookupByLibrary.simpleMessage(
            "Возможна ошибка при подгрузке. Если вы выбрали Steam Guard, перезайдите на страницу"),
        "steamId": MessageLookupByLibrary.simpleMessage("SteamID"),
        "stop": MessageLookupByLibrary.simpleMessage("Остановить"),
        "stopAllSteamGames":
            MessageLookupByLibrary.simpleMessage("Остановить ВСЕ Steam-игры"),
        "stopAllSteamGamesWarning": MessageLookupByLibrary.simpleMessage(
            "Это остановит все процессы, включая те, что не отображаются в приложении"),
        "timeInMinutes":
            MessageLookupByLibrary.simpleMessage("Время в минутах"),
        "totalGamesCount": MessageLookupByLibrary.simpleMessage("игр")
      };
}
