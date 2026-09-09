import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(arg0) => "Не удалось сохранить изменения для ${arg0}";

  static String m1(arg0) => "${arg0} · Запущена";

  static String m2(arg0) => "авто ${arg0}";

  static String m3(arg0) => "${arg0} найдено";

  static String m4(arg0) => "Цели автоостановки будут удалены у ${arg0} приложений во всей библиотеке.";

  static String m5(arg0) => "Достигнут лимит одновременно запущенных приложений: ${arg0}.";

  static String m6(arg0) => "сейчас: ${arg0}";

  static String m7(arg0) => "Все избранные в текущей выборке запускаются параллельно, до ${arg0} одновременно.";

  static String m8(arg0) => "Не удалось обновить время остановки ${arg0}.";

  static String m9(arg0, arg1, arg2) => "Не удалось запустить ${arg0} (AppID ${arg1}). ${arg2}";

  static String m10(arg0, arg1) => "Не удалось сохранить время для ${arg0} (AppID ${arg1}).";

  static String m11(arg0, arg1) => "Не удалось остановить ${arg0} (AppID ${arg1}). Процесс остаётся под наблюдением.";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'В кеше нет приложений', one: 'В кеше ${count} приложение', few: 'В кеше ${count} приложения', many: 'В кеше ${count} приложений', other: 'В кеше ${count} приложения')}";

  static String m13(arg0) => "Библиотека обновлена: ${arg0} приложений.";

  static String m14(arg0) => "Библиотека обновлена: ${arg0} приложений. Часть данных Steam недоступна.";

  static String m15(arg0) => "вручную ${arg0}";

  static String m16(arg0) => "Игры с недостигнутой целью запускаются параллельно, до ${arg0} одновременно.";

  static String m17(arg0) => "${arg0} ч";

  static String m18(arg0) => "≈ ${arg0} ч";

  static String m19(arg0) => "${arg0} мин";

  static String m20(arg0) => "${arg0} · пауза";

  static String m21(arg0) => "в очереди ${arg0}";

  static String m22(arg0, arg1) => "Запущено ${arg0}/${arg1}";

  static String m23(arg0) => "Вход выполнен. Библиотеку получить не удалось (код ${arg0}).";

  static String m24(arg0) => "Не удалось войти (код ${arg0}). Попробуйте ещё раз.";

  static String m25(arg0) => "Ошибка входа или загрузки: ${arg0}";

  static String m26(arg0) => "Остановить вручную · ${arg0}";

  static String m27(arg0) => "Будут остановлены приложения, запущенные вручную из этой сессии: ${arg0}.";

  static String m28(arg0) => "Будет остановлено текущее приложение и удалены оставшиеся: ${arg0}.";

  static String m29(arg0) => "Текущее время — ${arg0} мин. Такая цель будет снята, потому что она уже достигнута.";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activeQueueMustStop": MessageLookupByLibrary.simpleMessage("Сначала остановите активную очередь."),
    "addToFavorites": MessageLookupByLibrary.simpleMessage("Добавить в избранное"),
    "all": MessageLookupByLibrary.simpleMessage("Все"),
    "allProcessesStopped": MessageLookupByLibrary.simpleMessage("Все игры и процессы Steam helper остановлены."),
    "allSequentially": MessageLookupByLibrary.simpleMessage("Все по очереди"),
    "alphabetical": MessageLookupByLibrary.simpleMessage("По алфавиту"),
    "appChangesSaveFailed": m0,
    "appIdCopied": MessageLookupByLibrary.simpleMessage("AppID скопирован"),
    "appIdInvalid": MessageLookupByLibrary.simpleMessage("Укажите корректный AppID."),
    "appLanguage": MessageLookupByLibrary.simpleMessage("Язык приложения"),
    "appLookupHint": MessageLookupByLibrary.simpleMessage("Название, AppID или ссылка Steam"),
    "appType": MessageLookupByLibrary.simpleMessage("Тип приложения"),
    "appTypeRunningLabel": m1,
    "application": MessageLookupByLibrary.simpleMessage("Программа"),
    "applyTargets": MessageLookupByLibrary.simpleMessage("Применить отметки"),
    "ascending": MessageLookupByLibrary.simpleMessage("По возрастанию"),
    "autoStop": MessageLookupByLibrary.simpleMessage("Автоостановка"),
    "automatic": MessageLookupByLibrary.simpleMessage("автоматически"),
    "automaticAppsCount": m2,
    "bulkChangesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить массовые изменения. Попробуйте ещё раз.",
    ),
    "bulkTargets": MessageLookupByLibrary.simpleMessage("Массовая отметка"),
    "bulkTargetsDescription": MessageLookupByLibrary.simpleMessage(
      "Подготовьте цели автоостановки для выбранной части каталога.",
    ),
    "bulkTargetsInvalidRange": MessageLookupByLibrary.simpleMessage(
      "Проверьте значения: диапазон должен быть корректным, а цели — положительными.",
    ),
    "bulkTargetsNoChanges": MessageLookupByLibrary.simpleMessage(
      "Нет приложений, для которых эта операция что-либо изменит.",
    ),
    "byLastPlayed": MessageLookupByLibrary.simpleMessage("По дате запуска"),
    "byPlaytime": MessageLookupByLibrary.simpleMessage("По времени"),
    "byTimeUntilTarget": MessageLookupByLibrary.simpleMessage("По времени до отметки"),
    "cache": MessageLookupByLibrary.simpleMessage("Кеш"),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelAction": MessageLookupByLibrary.simpleMessage("Отменить"),
    "cardType": MessageLookupByLibrary.simpleMessage("Тип карточки"),
    "cardTypeAppIcon": MessageLookupByLibrary.simpleMessage("App icon 32×32"),
    "cardTypeLibraryCapsule": MessageLookupByLibrary.simpleMessage("Library capsule"),
    "cardTypeMainCapsule": MessageLookupByLibrary.simpleMessage("Main capsule"),
    "cardTypeStoreHeader": MessageLookupByLibrary.simpleMessage("Store header"),
    "catalogEmptyDescription": MessageLookupByLibrary.simpleMessage("Подключите Steam, чтобы получить игры и время."),
    "catalogEmptyTitle": MessageLookupByLibrary.simpleMessage("Локальная библиотека пуста"),
    "catalogEmptyWithSession": MessageLookupByLibrary.simpleMessage(
      "Вход в Steam уже выполнен. Обновите библиотеку, чтобы загрузить игры и время.",
    ),
    "catalogNoResultsHint": MessageLookupByLibrary.simpleMessage("Измените запрос или параметры фильтрации."),
    "catalogReadFailed": MessageLookupByLibrary.simpleMessage("Не удалось прочитать локальный каталог"),
    "catalogResultsCount": m3,
    "catalogSearchHint": MessageLookupByLibrary.simpleMessage("Название или AppID"),
    "clearAll": MessageLookupByLibrary.simpleMessage("Снять все"),
    "clearAllTargetsAction": MessageLookupByLibrary.simpleMessage("Снять все отметки"),
    "clearAllTargetsDescription": m4,
    "clearAllTargetsTitle": MessageLookupByLibrary.simpleMessage("Снять все отметки?"),
    "clearLibraryCache": MessageLookupByLibrary.simpleMessage("Очистить кеш библиотеки"),
    "clearTargets": MessageLookupByLibrary.simpleMessage("Снять отметки"),
    "clearTargetsIgnoresFiltersHint": MessageLookupByLibrary.simpleMessage(
      "Текущие поиск и фильтры не применяются. Перед удалением целей появится подтверждение.",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "concurrentApps": MessageLookupByLibrary.simpleMessage("Одновременно запущено"),
    "concurrentLimitReached": m5,
    "confirmLaunch": MessageLookupByLibrary.simpleMessage("Подтвердить запуск"),
    "connectSteam": MessageLookupByLibrary.simpleMessage("Подключить Steam"),
    "copyAppId": MessageLookupByLibrary.simpleMessage("Скопировать AppID"),
    "currentAppLabel": m6,
    "currentPlaytime": MessageLookupByLibrary.simpleMessage("Текущее время"),
    "currentSelection": MessageLookupByLibrary.simpleMessage("В текущей выборке"),
    "defaultDuration": MessageLookupByLibrary.simpleMessage("Обычная длительность"),
    "delayBetweenGames": MessageLookupByLibrary.simpleMessage("Пауза между играми"),
    "demo": MessageLookupByLibrary.simpleMessage("Демо"),
    "descending": MessageLookupByLibrary.simpleMessage("По убыванию"),
    "detectAutomatically": MessageLookupByLibrary.simpleMessage("Определять автоматически"),
    "done": MessageLookupByLibrary.simpleMessage("Готово"),
    "edit": MessageLookupByLibrary.simpleMessage("Изменить…"),
    "editAutoStopTarget": MessageLookupByLibrary.simpleMessage("Изменить время автоостановки"),
    "editCurrentPlaytime": MessageLookupByLibrary.simpleMessage("Изменить текущее время"),
    "editFilters": MessageLookupByLibrary.simpleMessage("Изменить фильтры"),
    "editingRequiresStoppedGames": MessageLookupByLibrary.simpleMessage(
      "Сначала остановите запущенные игры и очередь.",
    ),
    "eligibleApps": MessageLookupByLibrary.simpleMessage("Подходящих приложений"),
    "emptyTargetClearsHint": MessageLookupByLibrary.simpleMessage("Пустое поле снимает цель"),
    "enterCode": MessageLookupByLibrary.simpleMessage("Введите код"),
    "entireLibrary": MessageLookupByLibrary.simpleMessage("Во всей библиотеке"),
    "entireLibraryOperationTitle": MessageLookupByLibrary.simpleMessage("Операция для всей библиотеки"),
    "favorites": MessageLookupByLibrary.simpleMessage("Избранные"),
    "favoritesLaunchDescription": m7,
    "filters": MessageLookupByLibrary.simpleMessage("Фильтры"),
    "game": MessageLookupByLibrary.simpleMessage("Игра"),
    "gameDeadlineUpdateFailed": m8,
    "gameLaunchFailed": m9,
    "gamePlaytimeSaveFailed": m10,
    "gameStopFailed": m11,
    "hidden": MessageLookupByLibrary.simpleMessage("Скрытые"),
    "hours": MessageLookupByLibrary.simpleMessage("Часы"),
    "hoursAbbreviation": MessageLookupByLibrary.simpleMessage("ч"),
    "initializationFailed": MessageLookupByLibrary.simpleMessage("Инициализация неудачна"),
    "initializationFailureHint": MessageLookupByLibrary.simpleMessage(
      "Не удалось подготовить компоненты приложения. Данные библиотеки не изменены.",
    ),
    "interface": MessageLookupByLibrary.simpleMessage("ИНТЕРФЕЙС"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("Английский"),
    "languageRussian": MessageLookupByLibrary.simpleMessage("Русский"),
    "lastPlayed": MessageLookupByLibrary.simpleMessage("Последний запуск"),
    "launchAction": MessageLookupByLibrary.simpleMessage("Запустить"),
    "launchApps": MessageLookupByLibrary.simpleMessage("Запустить приложения"),
    "launchConfirmationHint": MessageLookupByLibrary.simpleMessage("После подтверждения запуск начнётся сразу."),
    "launchMenuLabel": MessageLookupByLibrary.simpleMessage("ЗАПУСТИТЬ"),
    "launchOptionsAction": MessageLookupByLibrary.simpleMessage("Запустить…"),
    "launchOrder": MessageLookupByLibrary.simpleMessage("Порядок запуска"),
    "launchUsesFiltersHint": MessageLookupByLibrary.simpleMessage(
      "Запуск учитывает поиск и все активные фильтры каталога.",
    ),
    "libraryCache": MessageLookupByLibrary.simpleMessage("Кеш библиотеки"),
    "libraryCacheAppCount": m12,
    "libraryCacheClearDescription": MessageLookupByLibrary.simpleMessage(
      "Удалить загруженный список игр, часы, избранное и цели из SSF. Сессия Steam останется для следующего обновления.",
    ),
    "libraryCacheClearFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось очистить кеш библиотеки. Повторите действие.",
    ),
    "libraryCacheCleared": MessageLookupByLibrary.simpleMessage("Кеш библиотеки очищен. Сессия Steam сохранена."),
    "libraryCacheCountUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать количество приложений в кеше.",
    ),
    "libraryCacheCounting": MessageLookupByLibrary.simpleMessage("Подсчитываем приложения в кеше…"),
    "librarySaveFailed": MessageLookupByLibrary.simpleMessage("Не удалось сохранить библиотеку. Повторите обновление."),
    "librarySaving": MessageLookupByLibrary.simpleMessage("Сохраняем библиотеку в каталог…"),
    "libraryUpdated": m13,
    "libraryUpdatedPartially": m14,
    "lowPlaytimeDurationLabel": MessageLookupByLibrary.simpleMessage("Если меньше 30 минут"),
    "manage": MessageLookupByLibrary.simpleMessage("Управление…"),
    "manualAppsCount": m15,
    "manualLaunch": MessageLookupByLibrary.simpleMessage("Ручной запуск"),
    "marked": MessageLookupByLibrary.simpleMessage("Отмеченные"),
    "markedLaunchDescription": m16,
    "maximum": MessageLookupByLibrary.simpleMessage("Максимум"),
    "maximumExclusive": MessageLookupByLibrary.simpleMessage("Максимум <"),
    "maximumTarget": MessageLookupByLibrary.simpleMessage("Максимальная цель"),
    "milestoneTargetRulesHint": MessageLookupByLibrary.simpleMessage(
      "Следующая подходящая цель ставится точно на красивую минуту. Игры от цели до 5 минут после неё не отмечаются повторно.",
    ),
    "minimum": MessageLookupByLibrary.simpleMessage("Минимум"),
    "minimumInclusive": MessageLookupByLibrary.simpleMessage("Минимум ≥"),
    "minimumTarget": MessageLookupByLibrary.simpleMessage("Минимальная цель"),
    "minutes": MessageLookupByLibrary.simpleMessage("Минуты"),
    "minutesAbbreviation": MessageLookupByLibrary.simpleMessage("мин"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "moreActions": MessageLookupByLibrary.simpleMessage("Дополнительные действия"),
    "name": MessageLookupByLibrary.simpleMessage("Название"),
    "nonNegativeIntegerRequired": MessageLookupByLibrary.simpleMessage("Введите целое число от 0"),
    "nothingFound": MessageLookupByLibrary.simpleMessage("Ничего не найдено"),
    "optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
    "optionalMaximumHint": MessageLookupByLibrary.simpleMessage("Необязательно — по умолчанию максимум"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "ownership": MessageLookupByLibrary.simpleMessage("Принадлежность"),
    "ownershipFromSteamOnRefresh": MessageLookupByLibrary.simpleMessage(
      "Использовать данные Steam при следующем обновлении",
    ),
    "ownershipNonPersonal": MessageLookupByLibrary.simpleMessage("Не моя / не определено"),
    "ownershipPersonal": MessageLookupByLibrary.simpleMessage("Моя"),
    "ownershipPersonalFilter": MessageLookupByLibrary.simpleMessage("Мои"),
    "ownershipUnknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "ownershipUnknownFilter": MessageLookupByLibrary.simpleMessage("Не определено"),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "pause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "playtime": MessageLookupByLibrary.simpleMessage("Время"),
    "playtimeClearsReachedTargetHint": MessageLookupByLibrary.simpleMessage(
      "Новое время достигнет текущей цели автоостановки, поэтому цель будет снята.",
    ),
    "playtimeHours": m17,
    "playtimeHoursApproximate": m18,
    "playtimeInMinutes": MessageLookupByLibrary.simpleMessage("Время в минутах"),
    "playtimeMilestones": MessageLookupByLibrary.simpleMessage("Красивые часы"),
    "playtimeMinutes": m19,
    "playtimeMinutesExample": MessageLookupByLibrary.simpleMessage("Например, 120"),
    "positiveIntegerRequired": MessageLookupByLibrary.simpleMessage("Введите положительное целое число"),
    "queuePausedLabel": m20,
    "queuedAppsCount": m21,
    "range": MessageLookupByLibrary.simpleMessage("Диапазон"),
    "refreshLibrary": MessageLookupByLibrary.simpleMessage("Обновить библиотеку"),
    "refreshQrCode": MessageLookupByLibrary.simpleMessage("Обновить QR-код"),
    "removeFromFavorites": MessageLookupByLibrary.simpleMessage("Убрать из избранного"),
    "reset": MessageLookupByLibrary.simpleMessage("Сбросить"),
    "resetAll": MessageLookupByLibrary.simpleMessage("Сбросить всё"),
    "resume": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "runnerAccountMismatch": MessageLookupByLibrary.simpleMessage(
      "Проверьте, что библиотека SSF и клиент Steam используют один аккаунт.",
    ),
    "runnerCleanupFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось включить автоматическое завершение процессов игр. Перезапустите SSF и повторите попытку.",
    ),
    "runnerLaunchUnconfirmed": MessageLookupByLibrary.simpleMessage("SteamAPI не подтвердил запуск."),
    "runnerLibraryRequired": MessageLookupByLibrary.simpleMessage("Сначала загрузите библиотеку аккаунта Steam."),
    "runnerUpdateRequired": MessageLookupByLibrary.simpleMessage("Пересоберите или обновите ssf_game вместе с SSF."),
    "runningAppsCount": m22,
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "searchByName": MessageLookupByLibrary.simpleMessage("Поиск по названию"),
    "secondsAbbreviation": MessageLookupByLibrary.simpleMessage("сек"),
    "selectAValue": MessageLookupByLibrary.simpleMessage("Выберите значение"),
    "selectionHasNoEligibleApps": MessageLookupByLibrary.simpleMessage("В текущей выборке нет подходящих приложений."),
    "sequentialLaunchDescription": MessageLookupByLibrary.simpleMessage(
      "Вся текущая выборка запускается строго по одному приложению.",
    ),
    "sequentialQueue": MessageLookupByLibrary.simpleMessage("Последовательная очередь"),
    "sequentialQueueBlocksManualLaunch": MessageLookupByLibrary.simpleMessage(
      "Во время последовательной очереди ручной запуск недоступен.",
    ),
    "sequentialQueueRequiresStoppedGames": MessageLookupByLibrary.simpleMessage(
      "Перед последовательным запуском остановите уже работающие приложения.",
    ),
    "sequentialStartAppId": MessageLookupByLibrary.simpleMessage("Начать с AppID"),
    "sequentialTimingInvalid": MessageLookupByLibrary.simpleMessage(
      "Длительность должна быть не меньше 1 секунды, пауза — не меньше 0.",
    ),
    "setOwnership": MessageLookupByLibrary.simpleMessage("Задать принадлежность"),
    "setTargets": MessageLookupByLibrary.simpleMessage("Отметить…"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "settingsAppearance": MessageLookupByLibrary.simpleMessage("Внешний вид"),
    "settingsCardPreviewHint": MessageLookupByLibrary.simpleMessage(
      "Нажмите на плитку: выбранный формат сразу применяется к каталогу.",
    ),
    "settingsImmediateSaveHint": MessageLookupByLibrary.simpleMessage(
      "Изменения сохраняются сразу и не требуют отдельной кнопки.",
    ),
    "settingsIntegrationsSteam": MessageLookupByLibrary.simpleMessage("Интеграции · Steam"),
    "settingsLanguage": MessageLookupByLibrary.simpleMessage("Язык"),
    "settingsSaveError": MessageLookupByLibrary.simpleMessage("Не удалось сохранить настройку."),
    "settingsSaved": MessageLookupByLibrary.simpleMessage("Настройки сохранены"),
    "settingsSaving": MessageLookupByLibrary.simpleMessage("Сохранение…"),
    "signIn": MessageLookupByLibrary.simpleMessage("Войти"),
    "signOut": MessageLookupByLibrary.simpleMessage("Выйти из аккаунта"),
    "sortBy": MessageLookupByLibrary.simpleMessage("Сортировать по"),
    "soundtrack": MessageLookupByLibrary.simpleMessage("Саундтрек"),
    "startAppNotInSelection": MessageLookupByLibrary.simpleMessage(
      "Указанный AppID не найден в текущей отсортированной выборке.",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Состояние"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Запущенные"),
    "steamAccountName": MessageLookupByLibrary.simpleMessage("Имя аккаунта Steam"),
    "steamAuthInputFailed": MessageLookupByLibrary.simpleMessage("Не удалось передать ответ Steam"),
    "steamConnecting": MessageLookupByLibrary.simpleMessage("Соединяемся со Steam…"),
    "steamConnection": MessageLookupByLibrary.simpleMessage("Подключение Steam"),
    "steamCredentialsChecking": MessageLookupByLibrary.simpleMessage("Проверяем данные Steam…"),
    "steamCredentialsRequired": MessageLookupByLibrary.simpleMessage("Введите логин и пароль Steam"),
    "steamCredentialsTitle": MessageLookupByLibrary.simpleMessage("Войдите, используя имя аккаунта"),
    "steamFamilyLibraryLoading": MessageLookupByLibrary.simpleMessage("Получаем библиотеку Steam Family…"),
    "steamGuardAppPrompt": MessageLookupByLibrary.simpleMessage("Введите код Steam Guard из приложения Steam"),
    "steamGuardChecking": MessageLookupByLibrary.simpleMessage("Проверяем код Steam Guard…"),
    "steamGuardCode": MessageLookupByLibrary.simpleMessage("Код Steam Guard"),
    "steamGuardEmailLabel": MessageLookupByLibrary.simpleMessage("Код из письма Steam"),
    "steamGuardEmailPrompt": MessageLookupByLibrary.simpleMessage("Введите код Steam Guard из письма"),
    "steamGuardSubmit": MessageLookupByLibrary.simpleMessage("Подтвердить код"),
    "steamHelperProtocolError": MessageLookupByLibrary.simpleMessage("Некорректный ответ загрузчика"),
    "steamHelperReadFailed": MessageLookupByLibrary.simpleMessage("Ошибка чтения ответа загрузчика"),
    "steamHelperStartFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить загрузчик библиотеки. Убедитесь, что ssf_steam_helper.exe установлен рядом с SSF.",
    ),
    "steamHelperStopUnconfirmed": MessageLookupByLibrary.simpleMessage(
      "Не удалось подтвердить остановку. Повторите отмену.",
    ),
    "steamId": MessageLookupByLibrary.simpleMessage("SteamID"),
    "steamLibraryFailedWithCode": m23,
    "steamLibraryLoading": MessageLookupByLibrary.simpleMessage("Вход выполнен. Получаем библиотеку…"),
    "steamLibraryMerging": MessageLookupByLibrary.simpleMessage("Объединяем данные библиотеки…"),
    "steamLibraryPartialStatus": MessageLookupByLibrary.simpleMessage("Вход выполнен. Библиотека получена частично."),
    "steamLibraryReceived": MessageLookupByLibrary.simpleMessage("Вход выполнен. Библиотека получена."),
    "steamLibraryTimeout": MessageLookupByLibrary.simpleMessage(
      "Вход выполнен, но загрузка библиотеки превысила время ожидания.",
    ),
    "steamMetadataLoading": MessageLookupByLibrary.simpleMessage("Получаем названия и типы приложений…"),
    "steamMobileConfirmationPrompt": MessageLookupByLibrary.simpleMessage(
      "Подтвердите вход в приложении Steam на телефоне",
    ),
    "steamPersonalLibraryLoading": MessageLookupByLibrary.simpleMessage("Получаем лицензии и список моих приложений…"),
    "steamPlaytimeUpdating": MessageLookupByLibrary.simpleMessage("Обновляем время в играх…"),
    "steamPrivateAppsChecking": MessageLookupByLibrary.simpleMessage("Проверяем приватные приложения…"),
    "steamQrAccessibilityLabel": MessageLookupByLibrary.simpleMessage("QR для входа через Steam Mobile"),
    "steamQrInstructions": MessageLookupByLibrary.simpleMessage(
      "Используйте мобильное приложение Steam, чтобы войти с помощью QR-кода",
    ),
    "steamQrScanPrompt": MessageLookupByLibrary.simpleMessage("Отсканируйте QR в Steam Mobile и подтвердите вход"),
    "steamQrTitle": MessageLookupByLibrary.simpleMessage("Или QR-код"),
    "steamSessionActive": MessageLookupByLibrary.simpleMessage("Уже есть активная сессия"),
    "steamSessionChecking": MessageLookupByLibrary.simpleMessage("Проверяем сохранённую сессию…"),
    "steamSessionPrivacyHint": MessageLookupByLibrary.simpleMessage(
      "Пароль не сохраняется. Защищённая сессия используется для следующих обновлений без повторного входа.",
    ),
    "steamSessionReadFailed": MessageLookupByLibrary.simpleMessage("Не удалось прочитать сохранённую сессию"),
    "steamSignInCancelled": MessageLookupByLibrary.simpleMessage("Вход отменён"),
    "steamSignInCancelling": MessageLookupByLibrary.simpleMessage("Отменяем вход…"),
    "steamSignInFailedWithCode": m24,
    "steamSignInMethodPrompt": MessageLookupByLibrary.simpleMessage("Выберите способ входа"),
    "steamSignInTimeout": MessageLookupByLibrary.simpleMessage("Время ожидания входа истекло"),
    "steamSignOutFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось завершить выход из аккаунта. Повторите действие.",
    ),
    "steamSignedOutCacheCleared": MessageLookupByLibrary.simpleMessage("Вы вышли из аккаунта. Кеш библиотеки очищен."),
    "steamSignedOutStatus": MessageLookupByLibrary.simpleMessage("Вы вышли из Steam. Выберите способ входа."),
    "steamSigningOut": MessageLookupByLibrary.simpleMessage("Выходим из аккаунта и очищаем кеш…"),
    "steamSyncFailed": m25,
    "stopAction": MessageLookupByLibrary.simpleMessage("Остановить"),
    "stopAll": MessageLookupByLibrary.simpleMessage("Остановить всё"),
    "stopAllProcessesDescription": MessageLookupByLibrary.simpleMessage(
      "Будут остановлены все игры и процессы Steam helper, запущенные этим экземпляром SteamSpaceFarm. Очередь запусков и обновление библиотеки будут отменены.",
    ),
    "stopAllProcessesFailed": MessageLookupByLibrary.simpleMessage("Не удалось выполнить принудительную остановку."),
    "stopAllProcessesTitle": MessageLookupByLibrary.simpleMessage("Принудительно остановить всё?"),
    "stopBatchQueueDescription": MessageLookupByLibrary.simpleMessage(
      "Очередь будет очищена, а запущенные ею приложения будут остановлены.",
    ),
    "stopManualApps": MessageLookupByLibrary.simpleMessage("Остановить вручную"),
    "stopManualAppsCount": m26,
    "stopManualAppsDescription": m27,
    "stopManualAppsTitle": MessageLookupByLibrary.simpleMessage("Остановить ручные запуски?"),
    "stopMenuLabel": MessageLookupByLibrary.simpleMessage("ОСТАНОВИТЬ"),
    "stopQueue": MessageLookupByLibrary.simpleMessage("Остановить очередь"),
    "stopQueueTitle": MessageLookupByLibrary.simpleMessage("Остановить активную очередь?"),
    "stopSequentialQueueDescription": m28,
    "storage": MessageLookupByLibrary.simpleMessage("ХРАНИЛИЩЕ"),
    "targetAlreadyReachedHint": m29,
    "targetPlaytime": MessageLookupByLibrary.simpleMessage("Конечное время"),
    "targetPlaytimeInMinutes": MessageLookupByLibrary.simpleMessage("Конечное время в минутах"),
    "targetRangeBoundsHint": MessageLookupByLibrary.simpleMessage(
      "Отмечаются приложения с временем от минимума включительно до максимума исключительно.",
    ),
    "technicalDetails": MessageLookupByLibrary.simpleMessage("Технические подробности"),
    "timeUntilTarget": MessageLookupByLibrary.simpleMessage("Остаток до отметки"),
    "tool": MessageLookupByLibrary.simpleMessage("Инструмент"),
    "video": MessageLookupByLibrary.simpleMessage("Видео"),
  };
}
