// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class GeneratedLocalizationsZh extends GeneratedLocalizations {
  GeneratedLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get activeQueueMustStop => '请先停止正在运行的队列。';

  @override
  String get addToFavorites => '添加到收藏';

  @override
  String get all => '全部';

  @override
  String get allProcessesStopped => '所有游戏和 Steam 辅助进程均已停止。';

  @override
  String get allSequentially => '依次运行全部';

  @override
  String get alphabetical => '按名称';

  @override
  String appChangesSaveFailed(Object arg0) {
    return '无法保存对 $arg0 的更改';
  }

  @override
  String get appIdCopied => '已复制 AppID';

  @override
  String get appIdInvalid => '请输入有效的 AppID。';

  @override
  String get appLanguage => '应用语言';

  @override
  String get application => '应用程序';

  @override
  String get appLookupHint => '名称、AppID 或 Steam 链接';

  @override
  String get applyTargets => '应用目标';

  @override
  String get appType => '应用类型';

  @override
  String appTypeRunningLabel(Object arg0) {
    return '$arg0 · 运行中';
  }

  @override
  String get ascending => '升序';

  @override
  String get automatic => '自动';

  @override
  String automaticAppsCount(Object arg0) {
    return '自动 $arg0';
  }

  @override
  String get autoStop => '自动停止';

  @override
  String get bulkChangesSaveFailed => '无法保存批量更改，请重试。';

  @override
  String get bulkTargets => '批量设置目标';

  @override
  String get bulkTargetsDescription => '为游戏列表中选定的应用设置自动停止目标。';

  @override
  String get bulkTargetsInvalidRange => '请检查输入值：范围必须有效，目标必须大于零。';

  @override
  String get bulkTargetsNoChanges => '此操作不会更改任何应用。';

  @override
  String get byLastPlayed => '按上次运行时间';

  @override
  String get byPlaytime => '按游戏时长';

  @override
  String get byTimeUntilTarget => '按距目标剩余时间';

  @override
  String get cache => '缓存';

  @override
  String get cancel => '取消';

  @override
  String get cancelAction => '取消';

  @override
  String get cardType => '卡片样式';

  @override
  String get cardTypeAppIcon => '应用图标 32×32';

  @override
  String get cardTypeLibraryCapsule => '库竖版封面';

  @override
  String get cardTypeMainCapsule => '主宣传图';

  @override
  String get cardTypeStoreHeader => '商店页头图';

  @override
  String get catalogEmptyDescription => '连接 Steam 以获取游戏和游戏时长。';

  @override
  String get catalogEmptyTitle => '本地库为空';

  @override
  String get catalogEmptyWithSession => '您已登录 Steam。请刷新库以加载游戏和游戏时长。';

  @override
  String get catalogNoResultsHint => '请更改搜索内容或筛选条件。';

  @override
  String get catalogReadFailed => '无法读取本地游戏列表';

  @override
  String catalogResultsCount(Object arg0) {
    return '找到 $arg0 项';
  }

  @override
  String get catalogSearchHint => '名称或 AppID';

  @override
  String get clearAll => '全部清除';

  @override
  String get clearAllTargetsAction => '清除所有目标';

  @override
  String clearAllTargetsDescription(Object arg0) {
    return '将移除整个库中 $arg0 个应用的自动停止目标。';
  }

  @override
  String get clearAllTargetsTitle => '清除所有目标？';

  @override
  String get clearLibraryCache => '清除库缓存';

  @override
  String get clearTargets => '清除目标';

  @override
  String get clearTargetsIgnoresFiltersHint => '当前搜索和筛选条件不适用于此操作。移除目标前会要求确认。';

  @override
  String get close => '关闭';

  @override
  String get concurrentApps => '同时运行的应用';

  @override
  String concurrentLimitReached(Object arg0) {
    return '已达到同时运行的应用数量上限：$arg0。';
  }

  @override
  String get confirmLaunch => '确认启动';

  @override
  String get connectSteam => '连接 Steam';

  @override
  String get copyAppId => '复制 AppID';

  @override
  String currentAppLabel(Object arg0) {
    return '当前：$arg0';
  }

  @override
  String get currentPlaytime => '当前游戏时长';

  @override
  String get currentSelection => '当前筛选结果';

  @override
  String get defaultDuration => '默认运行时长';

  @override
  String get delayBetweenGames => '游戏间隔';

  @override
  String get demo => '试玩版';

  @override
  String get descending => '降序';

  @override
  String get detectAutomatically => '自动检测';

  @override
  String get done => '完成';

  @override
  String get edit => '编辑…';

  @override
  String get editAutoStopTarget => '编辑自动停止目标';

  @override
  String get editCurrentPlaytime => '编辑当前游戏时长';

  @override
  String get editFilters => '编辑筛选条件';

  @override
  String get editingRequiresStoppedGames => '请先停止正在运行的游戏和队列。';

  @override
  String get eligibleApps => '符合条件的应用';

  @override
  String get emptyTargetClearsHint => '留空以清除目标';

  @override
  String get enterCode => '输入验证码';

  @override
  String get entireLibrary => '整个库';

  @override
  String get entireLibraryOperationTitle => '对整个库执行操作';

  @override
  String get favorites => '收藏';

  @override
  String favoritesLaunchDescription(Object arg0) {
    return '同时运行当前筛选结果中的所有收藏应用，每次最多 $arg0 个。';
  }

  @override
  String get filters => '筛选';

  @override
  String get game => '游戏';

  @override
  String gameDeadlineUpdateFailed(Object arg0) {
    return '无法更新 $arg0 的停止时间。';
  }

  @override
  String gameLaunchFailed(Object arg0, Object arg1, Object arg2) {
    return '无法启动 $arg0（AppID $arg1）。$arg2';
  }

  @override
  String gamePlaytimeSaveFailed(Object arg0, Object arg1) {
    return '无法保存 $arg0（AppID $arg1）的游戏时长。';
  }

  @override
  String gameStopFailed(Object arg0, Object arg1) {
    return '无法停止 $arg0（AppID $arg1）。仍在监控该进程。';
  }

  @override
  String get hidden => '隐藏';

  @override
  String get hours => '小时';

  @override
  String get hoursAbbreviation => '小时';

  @override
  String get initializationFailed => '初始化失败';

  @override
  String get initializationFailureHint => '无法准备应用组件，库数据未被更改。';

  @override
  String get interface => '界面';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageRussian => '俄语';

  @override
  String get lastPlayed => '上次运行';

  @override
  String get launchAction => '启动';

  @override
  String get launchApps => '启动应用';

  @override
  String get launchConfirmationHint => '确认后将立即启动。';

  @override
  String get launchMenuLabel => '启动';

  @override
  String get launchOptionsAction => '启动…';

  @override
  String get launchOrder => '启动顺序';

  @override
  String get launchUsesFiltersHint => '启动范围遵循搜索内容和所有已启用的筛选条件。';

  @override
  String get libraryCache => '库缓存';

  @override
  String libraryCacheAppCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '已缓存 $count 个应用', zero: '没有已缓存的应用');
    return '$_temp0';
  }

  @override
  String get libraryCacheClearDescription => '从 SSF 中移除已下载的游戏列表、游戏时长、收藏和目标。Steam 登录会话将被保留，以便下次刷新。';

  @override
  String get libraryCacheCleared => '库缓存已清除，Steam 登录会话已保留。';

  @override
  String get libraryCacheClearFailed => '无法清除库缓存，请重试。';

  @override
  String get libraryCacheCounting => '正在统计已缓存的应用…';

  @override
  String get libraryCacheCountUnavailable => '无法读取已缓存的应用数量。';

  @override
  String get librarySaveFailed => '无法保存库，请再次刷新。';

  @override
  String get librarySaving => '正在将库保存到本地列表…';

  @override
  String libraryUpdated(Object arg0) {
    return '库已更新：$arg0 个应用。';
  }

  @override
  String libraryUpdatedPartially(Object arg0) {
    return '库已更新：$arg0 个应用。部分 Steam 数据不可用。';
  }

  @override
  String get lowPlaytimeDurationLabel => '时长不足 30 分钟时';

  @override
  String get manage => '管理…';

  @override
  String manualAppsCount(Object arg0) {
    return '手动 $arg0';
  }

  @override
  String get manualLaunch => '手动启动';

  @override
  String get marked => '已标记';

  @override
  String markedLaunchDescription(Object arg0) {
    return '同时运行尚未达到目标的游戏，每次最多 $arg0 个。';
  }

  @override
  String get maximum => '最大值';

  @override
  String get maximumExclusive => '最大值 <';

  @override
  String get maximumTarget => '最大目标';

  @override
  String get milestoneTargetRulesHint => '下一个符合条件的目标将设为整点时长对应的分钟数。已达到目标或超出目标不超过 5 分钟的游戏不会再次被标记。';

  @override
  String get minimum => '最小值';

  @override
  String get minimumInclusive => '最小值 ≥';

  @override
  String get minimumTarget => '最小目标';

  @override
  String get minutes => '分钟';

  @override
  String get minutesAbbreviation => '分钟';

  @override
  String get mode => '模式';

  @override
  String get moreActions => '更多操作';

  @override
  String get name => '名称';

  @override
  String get nonNegativeIntegerRequired => '请输入大于或等于 0 的整数';

  @override
  String get nothingFound => '未找到结果';

  @override
  String get optional => '可选';

  @override
  String get optionalMaximumHint => '可选，默认为最大值';

  @override
  String get other => '其他';

  @override
  String get ownership => '归属';

  @override
  String get ownershipFromSteamOnRefresh => '下次刷新时使用 Steam 数据';

  @override
  String get ownershipNonPersonal => '非本人拥有 / 未知';

  @override
  String get ownershipPersonal => '本人拥有';

  @override
  String get ownershipPersonalFilter => '本人拥有';

  @override
  String get ownershipUnknown => '未知';

  @override
  String get ownershipUnknownFilter => '未知';

  @override
  String get password => '密码';

  @override
  String get pause => '暂停';

  @override
  String get playtime => '游戏时长';

  @override
  String get playtimeClearsReachedTargetHint => '新的游戏时长已达到当前自动停止目标，因此该目标将被清除。';

  @override
  String playtimeHours(Object arg0) {
    return '$arg0 小时';
  }

  @override
  String playtimeHoursApproximate(Object arg0) {
    return '≈ $arg0 小时';
  }

  @override
  String get playtimeInMinutes => '游戏时长（分钟）';

  @override
  String get playtimeMilestones => '整点时长目标';

  @override
  String playtimeMinutes(Object arg0) {
    return '$arg0 分钟';
  }

  @override
  String get playtimeMinutesExample => '例如：120';

  @override
  String get positiveIntegerRequired => '请输入正整数';

  @override
  String queuedAppsCount(Object arg0) {
    return '排队中 $arg0';
  }

  @override
  String queuePausedLabel(Object arg0) {
    return '$arg0 · 已暂停';
  }

  @override
  String get range => '范围';

  @override
  String get refreshLibrary => '刷新库';

  @override
  String get refreshQrCode => '刷新二维码';

  @override
  String get removeFromFavorites => '取消收藏';

  @override
  String get reset => '重置';

  @override
  String get resetAll => '全部重置';

  @override
  String get resume => '继续';

  @override
  String get retry => '重试';

  @override
  String get runnerAccountMismatch => '请确保 SSF 库和 Steam 客户端使用同一账号。';

  @override
  String get runnerCleanupFailed => '无法启用游戏进程自动清理。请重启 SSF 后重试。';

  @override
  String get runnerLaunchUnconfirmed => 'SteamAPI 未确认启动。';

  @override
  String get runnerLibraryRequired => '请先加载您的 Steam 账号库。';

  @override
  String get runnerUpdateRequired => '请同时重新构建或更新 ssf_game 和 SSF。';

  @override
  String runningAppsCount(Object arg0, Object arg1) {
    return '运行中 $arg0/$arg1';
  }

  @override
  String get save => '保存';

  @override
  String get searchByName => '按名称搜索';

  @override
  String get secondsAbbreviation => '秒';

  @override
  String get selectAValue => '请选择一个值';

  @override
  String get selectionHasNoEligibleApps => '当前筛选结果中没有符合条件的应用。';

  @override
  String get sequentialLaunchDescription => '依次运行当前筛选结果中的所有应用，每次一个。';

  @override
  String get sequentialQueue => '顺序队列';

  @override
  String get sequentialQueueBlocksManualLaunch => '顺序队列运行期间无法手动启动。';

  @override
  String get sequentialQueueRequiresStoppedGames => '请先停止正在运行的应用，再启动顺序队列。';

  @override
  String get sequentialStartAppId => '起始 AppID';

  @override
  String get sequentialTimingInvalid => '运行时长必须至少为 1 秒，间隔必须大于或等于 0。';

  @override
  String get setOwnership => '设置归属';

  @override
  String get setTargets => '设置目标…';

  @override
  String get settings => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsCardPreviewHint => '选择一个预览，即可立即将该卡片样式应用到游戏列表。';

  @override
  String get settingsImmediateSaveHint => '更改会立即保存，无需点击应用按钮。';

  @override
  String get settingsIntegrationsSteam => '集成 · Steam';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsSaved => '设置已保存';

  @override
  String get settingsSaveError => '无法保存此设置。';

  @override
  String get settingsSaving => '正在保存…';

  @override
  String get signIn => '登录';

  @override
  String get signOut => '退出登录';

  @override
  String get sortBy => '排序方式';

  @override
  String get soundtrack => '原声音轨';

  @override
  String get startAppNotInSelection => '在当前排序后的筛选结果中未找到指定的 AppID。';

  @override
  String get status => '状态';

  @override
  String get statusRunning => '运行中';

  @override
  String get steamAccountName => 'Steam 账号名称';

  @override
  String get steamAuthInputFailed => '无法向 Steam 发送响应';

  @override
  String get steamConnecting => '正在连接 Steam…';

  @override
  String get steamConnection => 'Steam 连接';

  @override
  String get steamCredentialsChecking => '正在验证 Steam 登录信息…';

  @override
  String get steamCredentialsRequired => '请输入 Steam 账号名称和密码';

  @override
  String get steamCredentialsTitle => '使用账号名称登录';

  @override
  String get steamFamilyLibraryLoading => '正在加载 Steam 家庭库…';

  @override
  String get steamGuardAppPrompt => '请输入 Steam 应用中的 Steam 令牌验证码';

  @override
  String get steamGuardChecking => '正在验证 Steam 令牌验证码…';

  @override
  String get steamGuardCode => 'Steam 令牌验证码';

  @override
  String get steamGuardEmailLabel => 'Steam 邮件验证码';

  @override
  String get steamGuardEmailPrompt => '请输入邮件中的 Steam 令牌验证码';

  @override
  String get steamGuardSubmit => '确认验证码';

  @override
  String get steamHelperProtocolError => '库辅助程序返回了无效响应';

  @override
  String get steamHelperReadFailed => '无法读取库辅助程序的响应';

  @override
  String get steamHelperStartFailed => '无法启动库辅助程序。请确保 ssf_steam_helper.exe 与 SSF 一同安装。';

  @override
  String get steamHelperStopUnconfirmed => '无法确认进程已停止，请再次尝试取消。';

  @override
  String get steamId => 'SteamID';

  @override
  String steamLibraryFailedWithCode(Object arg0) {
    return '已登录，但无法获取库（代码 $arg0）。';
  }

  @override
  String get steamLibraryLoading => '已登录，正在加载库…';

  @override
  String get steamLibraryMerging => '正在合并库数据…';

  @override
  String get steamLibraryPartialStatus => '已登录，部分库数据可用。';

  @override
  String get steamLibraryReceived => '已登录，已获取库。';

  @override
  String get steamLibraryTimeout => '已登录，但库请求超时。';

  @override
  String get steamMetadataLoading => '正在加载应用名称和类型…';

  @override
  String get steamMobileConfirmationPrompt => '请在手机上的 Steam 应用中批准登录';

  @override
  String get steamPersonalLibraryLoading => '正在加载许可证和您的应用…';

  @override
  String get steamPlaytimeUpdating => '正在更新游戏时长…';

  @override
  String get steamPrivateAppsChecking => '正在检查私密应用…';

  @override
  String get steamQrAccessibilityLabel => '用于 Steam 手机应用登录的二维码';

  @override
  String get steamQrInstructions => '使用 Steam 手机应用扫码登录';

  @override
  String get steamQrScanPrompt => '请使用 Steam 手机应用扫描二维码并批准登录';

  @override
  String get steamQrTitle => '或使用二维码';

  @override
  String get steamSessionActive => '您已登录';

  @override
  String get steamSessionChecking => '正在检查已保存的登录会话…';

  @override
  String get steamSessionPrivacyHint => '不会保存您的密码。受保护的登录会话可用于后续刷新，无需再次登录。';

  @override
  String get steamSessionReadFailed => '无法读取已保存的登录会话';

  @override
  String get steamSignedOutCacheCleared => '已退出登录，库缓存已清除。';

  @override
  String get steamSignedOutStatus => '已退出 Steam 登录，请选择登录方式。';

  @override
  String get steamSignInCancelled => '已取消登录';

  @override
  String get steamSignInCancelling => '正在取消登录…';

  @override
  String steamSignInFailedWithCode(Object arg0) {
    return '无法登录（代码 $arg0），请重试。';
  }

  @override
  String get steamSigningOut => '正在退出登录并清除缓存…';

  @override
  String get steamSignInMethodPrompt => '请选择登录方式';

  @override
  String get steamSignInTimeout => '登录超时';

  @override
  String get steamSignOutFailed => '无法完成退出登录，请重试。';

  @override
  String steamSyncFailed(Object arg0) {
    return '登录或库请求失败：$arg0';
  }

  @override
  String get stopAction => '停止';

  @override
  String get stopAll => '全部停止';

  @override
  String get stopAllProcessesDescription => '将停止由此 SteamSpaceFarm 实例启动的所有游戏和 Steam 辅助进程，并取消排队中的启动任务和库刷新。';

  @override
  String get stopAllProcessesFailed => '无法强制停止进程。';

  @override
  String get stopAllProcessesTitle => '强制停止全部？';

  @override
  String get stopBatchQueueDescription => '将清空队列，并停止由该队列启动的应用。';

  @override
  String get stopManualApps => '停止手动启动的应用';

  @override
  String stopManualAppsCount(Object arg0) {
    return '停止手动启动的应用 · $arg0';
  }

  @override
  String stopManualAppsDescription(Object arg0) {
    return '将停止本次会话中手动启动的应用：$arg0。';
  }

  @override
  String get stopManualAppsTitle => '停止手动启动的应用？';

  @override
  String get stopMenuLabel => '停止';

  @override
  String get stopQueue => '停止队列';

  @override
  String get stopQueueTitle => '停止正在运行的队列？';

  @override
  String stopSequentialQueueDescription(Object arg0) {
    return '将停止当前应用，并移除其余 $arg0 个队列项。';
  }

  @override
  String get storage => '存储';

  @override
  String targetAlreadyReachedHint(Object arg0) {
    return '当前游戏时长为 $arg0 分钟。目标已达到，因此将被清除。';
  }

  @override
  String get targetPlaytime => '目标游戏时长';

  @override
  String get targetPlaytimeInMinutes => '目标游戏时长（分钟）';

  @override
  String get targetRangeBoundsHint => '目标适用于游戏时长大于或等于最小值且小于最大值的应用。';

  @override
  String get technicalDetails => '技术详情';

  @override
  String get timeUntilTarget => '距目标剩余时间';

  @override
  String get tool => '工具';

  @override
  String get video => '视频';

  @override
  String get clearText => '清除文本';

  @override
  String get refreshOnStartup => '启动时刷新库';

  @override
  String get refreshOnStartupHint => '立即显示已缓存的库，并使用已保存的登录会话在后台刷新。';

  @override
  String get runnerSteamPresenceFailed => '无法切换为隐身状态。请检查 Steam 连接后重试。';

  @override
  String get invisibleWhilePlaying => '启动游戏时设为隐身';

  @override
  String get invisibleWhilePlayingHint => '适用于 Steamworks 和 SteamKit。所有游戏停止后恢复之前的状态。SteamKit 也可在未打开本地 Steam 客户端时使用。';

  @override
  String get experimentalSteamKit => '无需打开 Steam 客户端即可运行';

  @override
  String get experimentalSteamKitHint => '只需登录 SteamSpaceFarm。即使 Steam 客户端已关闭，游戏会话和隐身状态仍可使用。游戏时长是否被记录由 Steam 决定。';

  @override
  String get gamesBlockLibrary => '请先停止所有游戏，再刷新库或退出登录。';

  @override
  String get leaveLibraryUpdateTitle => '停止更新库？';

  @override
  String get leaveLibraryUpdateMessage => '离开此页面将停止库更新。已保存的游戏列表仍然可用。';

  @override
  String get leaveScreen => '停止并离开';

  @override
  String get libraryRefreshInProgress => '库正在更新，请等待完成后再启动游戏。';

  @override
  String get sessionSettings => '库与会话';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get runnerSteamKitFailed => 'SteamKit 无法确认会话。请重新登录 Steam 后重试。';

  @override
  String get sessionSettingsShort => '会话';

  @override
  String gameSessionInterrupted(String name, int appId) {
    return '$name（AppID $appId）的会话意外结束。请检查 Steam 连接后再重新启动。正在运行的队列已暂停。';
  }

  @override
  String get steamPresenceRestoreFailed => '多次尝试后仍无法恢复之前的 Steam 状态，请在 Steam 中检查您的状态。';

  @override
  String get cardFarmingMode => '挂卡模式';

  @override
  String get cardModeFast => '快速';

  @override
  String get cardModeSequential => '逐个';

  @override
  String get cardModeCombined => '混合';

  @override
  String get cardModeFastHint => '交替进行 5 分钟的多游戏同时运行和短时间的单游戏运行。';

  @override
  String get cardModeSequentialHint => '运行一款游戏，直到可掉落的卡牌全部获取完毕，再切换到下一款。';

  @override
  String get cardModeCombinedHint => '先同时运行多款游戏，将时长累积至 2 小时，再逐个挂卡。';

  @override
  String get refreshPlaytimeHourly => '每小时更新 Steam 游戏时长';

  @override
  String get refreshPlaytimeHourlyHint => '暂时停止会话，从 Steam 获取游戏时长，然后继续运行。';

  @override
  String get cardsTitle => '集换式卡牌';

  @override
  String get cardsRefresh => '检查卡牌掉落';

  @override
  String get cardsStartAll => '获取所有卡牌';

  @override
  String get cardsStart => '开始挂卡';

  @override
  String get cardsUnknown => '尚未检查卡牌掉落';

  @override
  String get cardsEmpty => '无卡牌可掉落';

  @override
  String get cardsPartial => '数据不完整，未知数量不会被视为零。';

  @override
  String get cardsFailed => '无法检查数据或运行会话，请重试。';

  @override
  String get cardsPriority => '挂卡优先于普通时长任务，已累积的时长会保留。';

  @override
  String get cardsFilter => '有卡牌掉落';

  @override
  String cardsRemaining(int count) {
    return '剩余卡牌掉落：$count';
  }

  @override
  String cardsCheckedAt(String time) {
    return '检查时间：$time';
  }

  @override
  String cardsQueued(int count) {
    return '挂卡队列游戏数：$count';
  }

  @override
  String get workPreparing => '正在准备会话';

  @override
  String get workGroup => '挂卡：同时运行';

  @override
  String get workSingle => '挂卡：单个游戏';

  @override
  String get workChecking => '正在检查剩余卡牌掉落';

  @override
  String get workWaiting => '等待中 / 已暂停';

  @override
  String get workSyncing => '正在更新 Steam 游戏时长';

  @override
  String get cardsStopDescription => '停止挂卡并继续等待中的游戏时长任务？';

  @override
  String cardsCount(int count) {
    return '卡牌 $count';
  }
}
