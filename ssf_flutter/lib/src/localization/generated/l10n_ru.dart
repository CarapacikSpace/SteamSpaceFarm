// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class GeneratedLocalizationsRu extends GeneratedLocalizations {
  GeneratedLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get activeQueueMustStop => 'Сначала остановите активную очередь.';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get all => 'Все';

  @override
  String get allProcessesStopped => 'Все игры и процессы Steam helper остановлены.';

  @override
  String get allSequentially => 'Все по очереди';

  @override
  String get alphabetical => 'По алфавиту';

  @override
  String appChangesSaveFailed(Object arg0) {
    return 'Не удалось сохранить изменения для $arg0';
  }

  @override
  String get appIdCopied => 'AppID скопирован';

  @override
  String get appIdInvalid => 'Укажите корректный AppID.';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get application => 'Программа';

  @override
  String get appLookupHint => 'Название, AppID или ссылка Steam';

  @override
  String get applyTargets => 'Применить отметки';

  @override
  String get appType => 'Тип приложения';

  @override
  String appTypeRunningLabel(Object arg0) {
    return '$arg0 · Запущена';
  }

  @override
  String get ascending => 'По возрастанию';

  @override
  String get automatic => 'автоматически';

  @override
  String automaticAppsCount(Object arg0) {
    return 'авто $arg0';
  }

  @override
  String get autoStop => 'Автоостановка';

  @override
  String get bulkChangesSaveFailed => 'Не удалось сохранить массовые изменения. Попробуйте ещё раз.';

  @override
  String get bulkTargets => 'Массовая отметка';

  @override
  String get bulkTargetsDescription => 'Подготовьте цели автоостановки для выбранной части каталога.';

  @override
  String get bulkTargetsInvalidRange => 'Проверьте значения: диапазон должен быть корректным, а цели — положительными.';

  @override
  String get bulkTargetsNoChanges => 'Нет приложений, для которых эта операция что-либо изменит.';

  @override
  String get byLastPlayed => 'По дате запуска';

  @override
  String get byPlaytime => 'По времени';

  @override
  String get byTimeUntilTarget => 'По времени до отметки';

  @override
  String get cache => 'Кеш';

  @override
  String get cancel => 'Отмена';

  @override
  String get cancelAction => 'Отменить';

  @override
  String get cardType => 'Тип карточки';

  @override
  String get cardTypeAppIcon => 'App icon 32×32';

  @override
  String get cardTypeLibraryCapsule => 'Library capsule';

  @override
  String get cardTypeMainCapsule => 'Main capsule';

  @override
  String get cardTypeStoreHeader => 'Store header';

  @override
  String get catalogEmptyDescription => 'Подключите Steam, чтобы получить игры и время.';

  @override
  String get catalogEmptyTitle => 'Локальная библиотека пуста';

  @override
  String get catalogEmptyWithSession => 'Вход в Steam уже выполнен. Обновите библиотеку, чтобы загрузить игры и время.';

  @override
  String get catalogNoResultsHint => 'Измените запрос или параметры фильтрации.';

  @override
  String get catalogReadFailed => 'Не удалось прочитать локальный каталог';

  @override
  String catalogResultsCount(Object arg0) {
    return '$arg0 найдено';
  }

  @override
  String get catalogSearchHint => 'Название или AppID';

  @override
  String get clearAll => 'Снять все';

  @override
  String get clearAllTargetsAction => 'Снять все отметки';

  @override
  String clearAllTargetsDescription(Object arg0) {
    return 'Цели автоостановки будут удалены у $arg0 приложений во всей библиотеке.';
  }

  @override
  String get clearAllTargetsTitle => 'Снять все отметки?';

  @override
  String get clearLibraryCache => 'Очистить кеш библиотеки';

  @override
  String get clearTargets => 'Снять отметки';

  @override
  String get clearTargetsIgnoresFiltersHint =>
      'Текущие поиск и фильтры не применяются. Перед удалением целей появится подтверждение.';

  @override
  String get close => 'Закрыть';

  @override
  String get concurrentApps => 'Одновременно запущено';

  @override
  String concurrentLimitReached(Object arg0) {
    return 'Достигнут лимит одновременно запущенных приложений: $arg0.';
  }

  @override
  String get confirmLaunch => 'Подтвердить запуск';

  @override
  String get connectSteam => 'Подключить Steam';

  @override
  String get copyAppId => 'Скопировать AppID';

  @override
  String currentAppLabel(Object arg0) {
    return 'сейчас: $arg0';
  }

  @override
  String get currentPlaytime => 'Текущее время';

  @override
  String get currentSelection => 'В текущей выборке';

  @override
  String get defaultDuration => 'Обычная длительность';

  @override
  String get delayBetweenGames => 'Пауза между играми';

  @override
  String get demo => 'Демо';

  @override
  String get descending => 'По убыванию';

  @override
  String get detectAutomatically => 'Определять автоматически';

  @override
  String get done => 'Готово';

  @override
  String get edit => 'Изменить…';

  @override
  String get editAutoStopTarget => 'Изменить время автоостановки';

  @override
  String get editCurrentPlaytime => 'Изменить текущее время';

  @override
  String get editFilters => 'Изменить фильтры';

  @override
  String get editingRequiresStoppedGames => 'Сначала остановите запущенные игры и очередь.';

  @override
  String get eligibleApps => 'Подходящих приложений';

  @override
  String get emptyTargetClearsHint => 'Пустое поле снимает цель';

  @override
  String get enterCode => 'Введите код';

  @override
  String get entireLibrary => 'Во всей библиотеке';

  @override
  String get entireLibraryOperationTitle => 'Операция для всей библиотеки';

  @override
  String get favorites => 'Избранные';

  @override
  String favoritesLaunchDescription(Object arg0) {
    return 'Все избранные в текущей выборке запускаются параллельно, до $arg0 одновременно.';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get game => 'Игра';

  @override
  String gameDeadlineUpdateFailed(Object arg0) {
    return 'Не удалось обновить время остановки $arg0.';
  }

  @override
  String gameLaunchFailed(Object arg0, Object arg1, Object arg2) {
    return 'Не удалось запустить $arg0 (AppID $arg1). $arg2';
  }

  @override
  String gamePlaytimeSaveFailed(Object arg0, Object arg1) {
    return 'Не удалось сохранить время для $arg0 (AppID $arg1).';
  }

  @override
  String gameStopFailed(Object arg0, Object arg1) {
    return 'Не удалось остановить $arg0 (AppID $arg1). Процесс остаётся под наблюдением.';
  }

  @override
  String get hidden => 'Скрытые';

  @override
  String get hours => 'Часы';

  @override
  String get hoursAbbreviation => 'ч';

  @override
  String get initializationFailed => 'Инициализация неудачна';

  @override
  String get initializationFailureHint =>
      'Не удалось подготовить компоненты приложения. Данные библиотеки не изменены.';

  @override
  String get interface => 'ИНТЕРФЕЙС';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get lastPlayed => 'Последний запуск';

  @override
  String get launchAction => 'Запустить';

  @override
  String get launchApps => 'Запустить приложения';

  @override
  String get launchConfirmationHint => 'После подтверждения запуск начнётся сразу.';

  @override
  String get launchMenuLabel => 'ЗАПУСТИТЬ';

  @override
  String get launchOptionsAction => 'Запустить…';

  @override
  String get launchOrder => 'Порядок запуска';

  @override
  String get launchUsesFiltersHint => 'Запуск учитывает поиск и все активные фильтры каталога.';

  @override
  String get libraryCache => 'Кеш библиотеки';

  @override
  String libraryCacheAppCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В кеше $count приложения',
      many: 'В кеше $count приложений',
      few: 'В кеше $count приложения',
      one: 'В кеше $count приложение',
      zero: 'В кеше нет приложений',
    );
    return '$_temp0';
  }

  @override
  String get libraryCacheClearDescription =>
      'Удалить загруженный список игр, часы, избранное и цели из SSF. Сессия Steam останется для следующего обновления.';

  @override
  String get libraryCacheCleared => 'Кеш библиотеки очищен. Сессия Steam сохранена.';

  @override
  String get libraryCacheClearFailed => 'Не удалось очистить кеш библиотеки. Повторите действие.';

  @override
  String get libraryCacheCounting => 'Подсчитываем приложения в кеше…';

  @override
  String get libraryCacheCountUnavailable => 'Не удалось прочитать количество приложений в кеше.';

  @override
  String get librarySaveFailed => 'Не удалось сохранить библиотеку. Повторите обновление.';

  @override
  String get librarySaving => 'Сохраняем библиотеку в каталог…';

  @override
  String libraryUpdated(Object arg0) {
    return 'Библиотека обновлена: $arg0 приложений.';
  }

  @override
  String libraryUpdatedPartially(Object arg0) {
    return 'Библиотека обновлена: $arg0 приложений. Часть данных Steam недоступна.';
  }

  @override
  String get lowPlaytimeDurationLabel => 'Если меньше 30 минут';

  @override
  String get manage => 'Управление…';

  @override
  String manualAppsCount(Object arg0) {
    return 'вручную $arg0';
  }

  @override
  String get manualLaunch => 'Ручной запуск';

  @override
  String get marked => 'Отмеченные';

  @override
  String markedLaunchDescription(Object arg0) {
    return 'Игры с недостигнутой целью запускаются параллельно, до $arg0 одновременно.';
  }

  @override
  String get maximum => 'Максимум';

  @override
  String get maximumExclusive => 'Максимум <';

  @override
  String get maximumTarget => 'Максимальная цель';

  @override
  String get milestoneTargetRulesHint =>
      'Следующая подходящая цель ставится точно на красивую минуту. Игры от цели до 5 минут после неё не отмечаются повторно.';

  @override
  String get minimum => 'Минимум';

  @override
  String get minimumInclusive => 'Минимум ≥';

  @override
  String get minimumTarget => 'Минимальная цель';

  @override
  String get minutes => 'Минуты';

  @override
  String get minutesAbbreviation => 'мин';

  @override
  String get mode => 'Режим';

  @override
  String get moreActions => 'Дополнительные действия';

  @override
  String get name => 'Название';

  @override
  String get nonNegativeIntegerRequired => 'Введите целое число от 0';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get optional => 'Необязательно';

  @override
  String get optionalMaximumHint => 'Необязательно — по умолчанию максимум';

  @override
  String get other => 'Другое';

  @override
  String get ownership => 'Принадлежность';

  @override
  String get ownershipFromSteamOnRefresh => 'Использовать данные Steam при следующем обновлении';

  @override
  String get ownershipNonPersonal => 'Не моя / не определено';

  @override
  String get ownershipPersonal => 'Моя';

  @override
  String get ownershipPersonalFilter => 'Мои';

  @override
  String get ownershipUnknown => 'Неизвестно';

  @override
  String get ownershipUnknownFilter => 'Не определено';

  @override
  String get password => 'Пароль';

  @override
  String get pause => 'Пауза';

  @override
  String get playtime => 'Время';

  @override
  String get playtimeClearsReachedTargetHint =>
      'Новое время достигнет текущей цели автоостановки, поэтому цель будет снята.';

  @override
  String playtimeHours(Object arg0) {
    return '$arg0 ч';
  }

  @override
  String playtimeHoursApproximate(Object arg0) {
    return '≈ $arg0 ч';
  }

  @override
  String get playtimeInMinutes => 'Время в минутах';

  @override
  String get playtimeMilestones => 'Красивые часы';

  @override
  String playtimeMinutes(Object arg0) {
    return '$arg0 мин';
  }

  @override
  String get playtimeMinutesExample => 'Например, 120';

  @override
  String get positiveIntegerRequired => 'Введите положительное целое число';

  @override
  String queuedAppsCount(Object arg0) {
    return 'в очереди $arg0';
  }

  @override
  String queuePausedLabel(Object arg0) {
    return '$arg0 · пауза';
  }

  @override
  String get range => 'Диапазон';

  @override
  String get refreshLibrary => 'Обновить библиотеку';

  @override
  String get refreshQrCode => 'Обновить QR-код';

  @override
  String get removeFromFavorites => 'Убрать из избранного';

  @override
  String get reset => 'Сбросить';

  @override
  String get resetAll => 'Сбросить всё';

  @override
  String get resume => 'Продолжить';

  @override
  String get retry => 'Повторить';

  @override
  String get runnerAccountMismatch => 'Проверьте, что библиотека SSF и клиент Steam используют один аккаунт.';

  @override
  String get runnerCleanupFailed =>
      'Не удалось включить автоматическое завершение процессов игр. Перезапустите SSF и повторите попытку.';

  @override
  String get runnerLaunchUnconfirmed => 'SteamAPI не подтвердил запуск.';

  @override
  String get runnerLibraryRequired => 'Сначала загрузите библиотеку аккаунта Steam.';

  @override
  String get runnerUpdateRequired => 'Пересоберите или обновите ssf_game вместе с SSF.';

  @override
  String runningAppsCount(Object arg0, Object arg1) {
    return 'Запущено $arg0/$arg1';
  }

  @override
  String get save => 'Сохранить';

  @override
  String get searchByName => 'Поиск по названию';

  @override
  String get secondsAbbreviation => 'сек';

  @override
  String get selectAValue => 'Выберите значение';

  @override
  String get selectionHasNoEligibleApps => 'В текущей выборке нет подходящих приложений.';

  @override
  String get sequentialLaunchDescription => 'Вся текущая выборка запускается строго по одному приложению.';

  @override
  String get sequentialQueue => 'Последовательная очередь';

  @override
  String get sequentialQueueBlocksManualLaunch => 'Во время последовательной очереди ручной запуск недоступен.';

  @override
  String get sequentialQueueRequiresStoppedGames =>
      'Перед последовательным запуском остановите уже работающие приложения.';

  @override
  String get sequentialStartAppId => 'Начать с AppID';

  @override
  String get sequentialTimingInvalid => 'Длительность должна быть не меньше 1 секунды, пауза — не меньше 0.';

  @override
  String get setOwnership => 'Задать принадлежность';

  @override
  String get setTargets => 'Отметить…';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsCardPreviewHint => 'Нажмите на плитку: выбранный формат сразу применяется к каталогу.';

  @override
  String get settingsImmediateSaveHint => 'Изменения сохраняются сразу и не требуют отдельной кнопки.';

  @override
  String get settingsIntegrationsSteam => 'Интеграции · Steam';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSaved => 'Настройки сохранены';

  @override
  String get settingsSaveError => 'Не удалось сохранить настройку.';

  @override
  String get settingsSaving => 'Сохранение…';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти из аккаунта';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get soundtrack => 'Саундтрек';

  @override
  String get startAppNotInSelection => 'Указанный AppID не найден в текущей отсортированной выборке.';

  @override
  String get status => 'Состояние';

  @override
  String get statusRunning => 'Запущенные';

  @override
  String get steamAccountName => 'Имя аккаунта Steam';

  @override
  String get steamAuthInputFailed => 'Не удалось передать ответ Steam';

  @override
  String get steamConnecting => 'Соединяемся со Steam…';

  @override
  String get steamConnection => 'Подключение Steam';

  @override
  String get steamCredentialsChecking => 'Проверяем данные Steam…';

  @override
  String get steamCredentialsRequired => 'Введите логин и пароль Steam';

  @override
  String get steamCredentialsTitle => 'Войдите, используя имя аккаунта';

  @override
  String get steamFamilyLibraryLoading => 'Получаем библиотеку Steam Family…';

  @override
  String get steamGuardAppPrompt => 'Введите код Steam Guard из приложения Steam';

  @override
  String get steamGuardChecking => 'Проверяем код Steam Guard…';

  @override
  String get steamGuardCode => 'Код Steam Guard';

  @override
  String get steamGuardEmailLabel => 'Код из письма Steam';

  @override
  String get steamGuardEmailPrompt => 'Введите код Steam Guard из письма';

  @override
  String get steamGuardSubmit => 'Подтвердить код';

  @override
  String get steamHelperProtocolError => 'Некорректный ответ загрузчика';

  @override
  String get steamHelperReadFailed => 'Ошибка чтения ответа загрузчика';

  @override
  String get steamHelperStartFailed =>
      'Не удалось запустить загрузчик библиотеки. Убедитесь, что ssf_steam_helper.exe установлен рядом с SSF.';

  @override
  String get steamHelperStopUnconfirmed => 'Не удалось подтвердить остановку. Повторите отмену.';

  @override
  String get steamId => 'SteamID';

  @override
  String steamLibraryFailedWithCode(Object arg0) {
    return 'Вход выполнен. Библиотеку получить не удалось (код $arg0).';
  }

  @override
  String get steamLibraryLoading => 'Вход выполнен. Получаем библиотеку…';

  @override
  String get steamLibraryMerging => 'Объединяем данные библиотеки…';

  @override
  String get steamLibraryPartialStatus => 'Вход выполнен. Библиотека получена частично.';

  @override
  String get steamLibraryReceived => 'Вход выполнен. Библиотека получена.';

  @override
  String get steamLibraryTimeout => 'Вход выполнен, но загрузка библиотеки превысила время ожидания.';

  @override
  String get steamMetadataLoading => 'Получаем названия и типы приложений…';

  @override
  String get steamMobileConfirmationPrompt => 'Подтвердите вход в приложении Steam на телефоне';

  @override
  String get steamPersonalLibraryLoading => 'Получаем лицензии и список моих приложений…';

  @override
  String get steamPlaytimeUpdating => 'Обновляем время в играх…';

  @override
  String get steamPrivateAppsChecking => 'Проверяем приватные приложения…';

  @override
  String get steamQrAccessibilityLabel => 'QR для входа через Steam Mobile';

  @override
  String get steamQrInstructions => 'Используйте мобильное приложение Steam, чтобы войти с помощью QR-кода';

  @override
  String get steamQrScanPrompt => 'Отсканируйте QR в Steam Mobile и подтвердите вход';

  @override
  String get steamQrTitle => 'Или QR-код';

  @override
  String get steamSessionActive => 'Уже есть активная сессия';

  @override
  String get steamSessionChecking => 'Проверяем сохранённую сессию…';

  @override
  String get steamSessionPrivacyHint =>
      'Пароль не сохраняется. Защищённая сессия используется для следующих обновлений без повторного входа.';

  @override
  String get steamSessionReadFailed => 'Не удалось прочитать сохранённую сессию';

  @override
  String get steamSignedOutCacheCleared => 'Вы вышли из аккаунта. Кеш библиотеки очищен.';

  @override
  String get steamSignedOutStatus => 'Вы вышли из Steam. Выберите способ входа.';

  @override
  String get steamSignInCancelled => 'Вход отменён';

  @override
  String get steamSignInCancelling => 'Отменяем вход…';

  @override
  String steamSignInFailedWithCode(Object arg0) {
    return 'Не удалось войти (код $arg0). Попробуйте ещё раз.';
  }

  @override
  String get steamSigningOut => 'Выходим из аккаунта и очищаем кеш…';

  @override
  String get steamSignInMethodPrompt => 'Выберите способ входа';

  @override
  String get steamSignInTimeout => 'Время ожидания входа истекло';

  @override
  String get steamSignOutFailed => 'Не удалось завершить выход из аккаунта. Повторите действие.';

  @override
  String steamSyncFailed(Object arg0) {
    return 'Ошибка входа или загрузки: $arg0';
  }

  @override
  String get stopAction => 'Остановить';

  @override
  String get stopAll => 'Остановить всё';

  @override
  String get stopAllProcessesDescription =>
      'Будут остановлены все игры и процессы Steam helper, запущенные этим экземпляром SteamSpaceFarm. Очередь запусков и обновление библиотеки будут отменены.';

  @override
  String get stopAllProcessesFailed => 'Не удалось выполнить принудительную остановку.';

  @override
  String get stopAllProcessesTitle => 'Принудительно остановить всё?';

  @override
  String get stopBatchQueueDescription => 'Очередь будет очищена, а запущенные ею приложения будут остановлены.';

  @override
  String get stopManualApps => 'Остановить вручную';

  @override
  String stopManualAppsCount(Object arg0) {
    return 'Остановить вручную · $arg0';
  }

  @override
  String stopManualAppsDescription(Object arg0) {
    return 'Будут остановлены приложения, запущенные вручную из этой сессии: $arg0.';
  }

  @override
  String get stopManualAppsTitle => 'Остановить ручные запуски?';

  @override
  String get stopMenuLabel => 'ОСТАНОВИТЬ';

  @override
  String get stopQueue => 'Остановить очередь';

  @override
  String get stopQueueTitle => 'Остановить активную очередь?';

  @override
  String stopSequentialQueueDescription(Object arg0) {
    return 'Будет остановлено текущее приложение и удалены оставшиеся: $arg0.';
  }

  @override
  String get storage => 'ХРАНИЛИЩЕ';

  @override
  String targetAlreadyReachedHint(Object arg0) {
    return 'Текущее время — $arg0 мин. Такая цель будет снята, потому что она уже достигнута.';
  }

  @override
  String get targetPlaytime => 'Конечное время';

  @override
  String get targetPlaytimeInMinutes => 'Конечное время в минутах';

  @override
  String get targetRangeBoundsHint =>
      'Отмечаются приложения с временем от минимума включительно до максимума исключительно.';

  @override
  String get technicalDetails => 'Технические подробности';

  @override
  String get timeUntilTarget => 'Остаток до отметки';

  @override
  String get tool => 'Инструмент';

  @override
  String get video => 'Видео';

  @override
  String get clearText => 'Очистить поле';

  @override
  String get refreshOnStartup => 'Обновлять библиотеку при запуске';

  @override
  String get refreshOnStartupHint =>
      'Сначала показывать сохранённую библиотеку и обновлять её в фоне через сохранённую сессию.';

  @override
  String get runnerSteamPresenceFailed =>
      'Не удалось включить «Невидимку». Проверьте подключение к Steam и повторите запуск.';

  @override
  String get invisibleWhilePlaying => 'Переходить в «Невидимку» при запуске игр';

  @override
  String get invisibleWhilePlayingHint =>
      'Для Steamworks и SteamKit. После завершения всех игр восстановится предыдущий статус. SteamKit работает и без локального Steam.';

  @override
  String get experimentalSteamKit => 'Запуск через SteamKit — ЭКСПЕРИМЕНТАЛЬНО';

  @override
  String get experimentalSteamKitHint =>
      'Запуск игр и переход в «Невидимку» работают без локально запущенного Steam: достаточно войти в аккаунт в SteamSpaceFarm. Учёт времени зависит от Steam.';

  @override
  String get gamesBlockLibrary => 'Остановите все игры перед обновлением библиотеки или выходом из аккаунта.';

  @override
  String get leaveLibraryUpdateTitle => 'Остановить обновление библиотеки?';

  @override
  String get leaveLibraryUpdateMessage =>
      'Если вы выйдете с этого экрана, обновление библиотеки остановится. Сохранённый каталог останется доступен.';

  @override
  String get leaveScreen => 'Остановить и выйти';

  @override
  String get libraryRefreshInProgress => 'Библиотека обновляется. Дождитесь завершения перед запуском игр.';

  @override
  String get sessionSettings => 'Библиотека и сеансы';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get runnerSteamKitFailed => 'SteamKit не подтвердил сеанс. Повторно войдите в Steam и попробуйте снова.';

  @override
  String get sessionSettingsShort => 'Сеансы';

  @override
  String gameSessionInterrupted(String name, int appId) {
    return 'Сеанс $name (AppID $appId) неожиданно завершился. Проверьте подключение к Steam перед повторным запуском. Активные очереди приостановлены.';
  }

  @override
  String get steamPresenceRestoreFailed =>
      'Не удалось восстановить предыдущий статус Steam после нескольких попыток. Проверьте свой статус в Steam.';
}
