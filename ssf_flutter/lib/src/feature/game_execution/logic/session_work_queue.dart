import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/steam_game.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/game_launcher.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_drops.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/card_farming_mode.dart';
import 'package:ssf_flutter/src/storage/app_paths.dart';

enum WorkPhase() {
  idle,
  preparing,
  group,
  single,
  checking,
  waiting,
  syncing,
}

/// Coordinates exclusive card phases and periodic synchronization with the hour queue.
class SessionWorkQueue({
  required final GameLauncher launcher,
  required final SteamGameService service,
  required final IAppsRepository repository,
  required final LocalApp? Function(int) appById,
  final File? cacheFile,
  final Duration groupDuration = const Duration(minutes: 5),
  final Duration soloDuration = const Duration(seconds: 5),
  final Duration settleDelay = const Duration(seconds: 5),
  final Duration refreshInterval = const Duration(hours: 1),
  final Duration clockTick = const Duration(seconds: 10),
}) extends ChangeNotifier {
  this {
    launcher.beforeStopAll = () => stop(resumeHours: false);
    launcher.hasBackgroundWork = () => active || loading;
    launcher.onUnexpectedExit = () {
      paused = true;
      failed = true;
      _wakeUp();
      _notify();
    };
    _clock = Timer.periodic(clockTick, (_) {
      if (launcher.launchedGames.isNotEmpty) {
        _sinceSync += clockTick;
      }
      if (refreshHourly && _sinceSync >= refreshInterval && !active && !_disposed) {
        _operation = _synchronize();
      }
    });
  }

  final drops = <int, CardDrops>{};
  final jobs = <int, LocalApp>{};
  CardFarmingMode mode = CardFarmingMode.fast;
  bool refreshHourly = false;
  bool loading = false;
  bool partial = false;
  bool failed = false;
  bool paused = false;
  bool _running = false;
  bool _resume = true;
  bool _disposed = false;
  String? _account;
  DateTime? checkedAt;
  WorkPhase phase = WorkPhase.idle;
  Future<void>? _operation;
  Future<void>? _refresh;
  Timer? _clock;
  Timer? _waitTimer;
  Completer<void>? _wake;
  Duration _sinceSync = Duration.zero;
  int _rotation = 0;

  bool get active => _operation != null;

  bool get farming => _running;

  int get remaining => drops.values.fold(0, (sum, game) => sum + (game.remaining ?? 0));

  File get _file => cacheFile ?? File('${AppPaths.library.path}/cards.json');

  Future<void> loadCache() async {
    try {
      final String? account = await repository.getCatalogSteamId();
      if (_account != account) {
        drops.clear();
        checkedAt = null;
        partial = false;
        failed = false;
        launcher.clearKnownApps();
        _account = account;
        _notify();
      }
      if (_account == null || !await _file.exists()) {
        drops.clear();
        checkedAt = null;
        partial = false;
        _notify();
        return;
      }
      final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      if (json['steamId'] != _account || json['v'] != 1) {
        return;
      }
      final Iterable<CardDrops> values = (json['games'] as List).map(
        (dynamic value) => CardDrops.fromJson(value as Map<String, dynamic>),
      );
      drops.addEntries(values.map((game) => MapEntry(game.appId, game)));
      checkedAt = DateTime.fromMillisecondsSinceEpoch((json['checkedAt'] as int) * 1000);
      partial = json['partial'] == true;
      _notify();
    } on Object {
      /* A cache is optional; fresh data is always verified before farming. */
    }
  }

  Future<void> refresh({List<int> appIds = const []}) => _refresh ??= _read(appIds).whenComplete(() => _refresh = null);

  Future<void> _read(List<int> ids) async {
    loading = true;
    _notify();
    try {
      final String? account = await repository.getCatalogSteamId();
      if (account == null) {
        throw StateError('account_required');
      }
      if (_account != account) {
        drops.clear();
        checkedAt = null;
        _account = account;
      }
      final Map<String, dynamic> response = await service.queryData(account, 'cards', appIds: ids);
      if (_disposed) {
        return;
      }
      final data = response['cards'] as Map<String, dynamic>;
      if (data['steamId'] != account) {
        throw const FormatException('account_mismatch');
      }
      final checked = DateTime.fromMillisecondsSinceEpoch((data['checkedAt'] as int) * 1000);
      final List<CardDrops> values = (data['games'] as List)
          .map((dynamic value) => CardDrops.fromJson(value as Map<String, dynamic>, checkedAt: checked))
          .toList();
      if (ids.isNotEmpty && !ids.every((id) => values.any((value) => value.appId == id && value.remaining != null))) {
        throw const FormatException('incomplete_card_check');
      }
      for (final value in values) {
        final CardDrops? previous = drops[value.appId];
        drops[value.appId] = ids.isNotEmpty && previous != null
            ? CardDrops(appId: value.appId, name: previous.name, remaining: value.remaining, checkedAt: value.checkedAt)
            : value;
      }
      if (ids.isEmpty) {
        partial = data['complete'] != true;
      }
      checkedAt = checked;
      failed = false;
      try {
        await _file.parent.create(recursive: true);
        final temporary = File('${_file.path}.tmp');
        await temporary.writeAsString(
          jsonEncode({
            'v': 1,
            'steamId': account,
            'partial': partial,
            'checkedAt': checked.millisecondsSinceEpoch ~/ 1000,
            'games': drops.values.map((game) => game.toJson()).toList(),
          }),
        );
        await temporary.rename(_file.path);
      } on Object {
        /* A disk error must not discard a successful server response. */
      }
    } on Object {
      failed = true;
      rethrow;
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> start(Iterable<LocalApp> apps) async {
    for (final app in apps) {
      if ((drops[app.appId]?.remaining ?? 0) > 0) {
        jobs[app.appId] = app;
      }
    }
    if (jobs.isEmpty || _disposed) {
      return;
    }
    if (active) {
      _wakeUp();
      _notify();
      return;
    }
    _running = true;
    _resume = true;
    paused = false;
    _operation = _runCards();
    _notify();
  }

  void remove(int appId) {
    jobs.remove(appId);
    _wakeUp();
    _notify();
  }

  void togglePause() {
    paused = !paused;
    _wakeUp();
    _notify();
  }

  void setMode(CardFarmingMode value) {
    if (mode != value) {
      mode = value;
      _wakeUp();
    }
  }

  Future<void> stop({bool resumeHours = true}) async {
    _resume = resumeHours;
    _running = false;
    jobs.clear();
    _wakeUp();
    service.cancelDataQueries();
    await _operation;
    try {
      await _refresh;
    } on Object {
      /* Cancellation is expected. */
    }
  }

  Future<void> _runCards() async {
    Future<void> Function()? release;
    var failures = 0;
    var tookControl = false;
    var prepared = false;
    try {
      final String? account = await repository.getCatalogSteamId();
      if (account == null) {
        throw StateError('account_required');
      }
      while (_running && jobs.isNotEmpty && !_disposed) {
        if (paused) {
          try {
            await launcher.stopExclusive();
          } on Object {
            failed = true;
          }
          phase = WorkPhase.waiting;
          _notify();
          await _wait(const Duration(days: 1));
          continue;
        }
        try {
          if (!prepared) {
            phase = WorkPhase.preparing;
            _notify();
            release ??= await service.holdSession(account);
            if (!_running || _disposed) {
              break;
            }
            tookControl = true;
            await launcher.suspendHours();
            prepared = true;
          }
          final List<int> all = jobs.keys.toList();
          final int offset = _rotation % all.length;
          final List<int> ids = [...all.skip(offset), ...all.take(offset)].take(launcher.maxRunningGames).toList();
          phase = WorkPhase.checking;
          _notify();
          await refresh(appIds: ids);
          for (final id in ids) {
            if (drops[id]?.remaining == 0) {
              jobs.remove(id);
            }
          }
          final List<int> eligible = ids.where(jobs.containsKey).toList();
          if (!_running || paused || eligible.isEmpty) {
            continue;
          }
          if (refreshHourly && _sinceSync >= refreshInterval) {
            await _syncMinutes(account);
          }
          if (!_running || paused) {
            continue;
          }
          final CardFarmingMode cycleMode = mode;
          switch (cycleMode) {
            case CardFarmingMode.fast:
              await _play(eligible, groupDuration, WorkPhase.group);
              if (!_canPlay || mode != cycleMode) {
                continue;
              }
              await _wait(settleDelay);
              for (final id in eligible) {
                if (!_canPlay || mode != cycleMode || !jobs.containsKey(id)) {
                  break;
                }
                await _play([id], soloDuration, WorkPhase.single);
              }
              _rotation += eligible.length;
            case CardFarmingMode.sequential:
              final int id = eligible.first;
              await _play([id], Duration(minutes: drops[id]?.remaining == 1 ? 5 : 15), WorkPhase.single);
            case CardFarmingMode.combined:
              final List<int> group = eligible.where((id) => (appById(id)?.playtimeMinutes ?? 0) < 120).toList();
              if (group.length > 1) {
                await _play(group, const Duration(minutes: 6), WorkPhase.group);
              } else {
                final int id = eligible.first;
                await _play([id], Duration(minutes: drops[id]?.remaining == 1 ? 5 : 15), WorkPhase.single);
              }
          }
          failures = 0;
        } on Object {
          failed = true;
          if (tookControl) {
            try {
              await launcher.stopExclusive();
            } on Object {
              paused = true;
            }
          }
          phase = WorkPhase.waiting;
          _notify();
          if (_running) {
            await _wait(Duration(seconds: min(300, 30 * (1 << min(failures++, 3)))));
          }
        }
      }
    } on Object {
      failed = true;
    } finally {
      try {
        if (tookControl) {
          await launcher.stopExclusive();
          if (_resume && !_disposed) {
            await launcher.resumeHours();
          }
        }
      } on Object {
        failed = true;
      }
      try {
        await release?.call();
      } on Object {
        failed = true;
      }
      _running = false;
      _operation = null;
      phase = WorkPhase.idle;
      _notify();
    }
  }

  bool get _canPlay => _running && !paused && !_disposed;

  Future<void> _play(List<int> ids, Duration duration, WorkPhase currentPhase) async {
    phase = currentPhase;
    _notify();
    for (final id in ids) {
      if (!_canPlay || !jobs.containsKey(id)) {
        break;
      }
      final LocalApp app = appById(id) ?? jobs[id]!;
      await launcher.launchExclusive(app);
      if (!launcher.launchedGames.any((game) => game.app.appId == id)) {
        throw StateError('launch_failed');
      }
    }
    if (_canPlay) {
      await _wait(duration);
    }
    await launcher.stopExclusive();
  }

  Future<void> _synchronize() async {
    Future<void> Function()? release;
    _resume = true;
    phase = WorkPhase.syncing;
    _notify();
    try {
      final String? account = await repository.getCatalogSteamId();
      if (account == null) {
        return;
      }
      release = await service.holdSession(account);
      await launcher.suspendHours();
      await _syncMinutes(account);
    } on Object {
      failed = true;
      _sinceSync = const Duration(minutes: 55);
    } finally {
      try {
        if (_resume && !_disposed) {
          await launcher.resumeHours();
        }
      } on Object {
        failed = true;
      }
      try {
        await release?.call();
      } on Object {
        failed = true;
      }
      _operation = null;
      phase = WorkPhase.idle;
      _notify();
      if (jobs.isNotEmpty && _resume && !_disposed) {
        unawaited(start(jobs.values.toList()));
      }
    }
  }

  Future<void> _syncMinutes(String account) async {
    phase = WorkPhase.syncing;
    _notify();
    await _wait(settleDelay);
    if (!_resume || _disposed) {
      return;
    }
    final Map<String, dynamic> response = await service.queryData(account, 'playtime');
    if (!_resume || _disposed) {
      return;
    }
    final raw = response['minutes'] as Map<String, dynamic>;
    final minutes = <int, int>{};
    for (final MapEntry<String, dynamic> entry in raw.entries) {
      final int id = int.parse(entry.key);
      final value = entry.value as int;
      if (id <= 0 || value < 0) {
        throw const FormatException('playtime');
      }
      minutes[id] = value;
    }
    await launcher.applyConfirmedMinutes(minutes);
    _sinceSync = Duration.zero;
  }

  Future<void> _wait(Duration duration) async {
    final Completer<void> wake = _wake = Completer<void>();
    _waitTimer = Timer(duration, () {
      if (!wake.isCompleted) {
        wake.complete();
      }
    });
    await wake.future;
    _waitTimer?.cancel();
    _waitTimer = null;
    if (identical(_wake, wake)) {
      _wake = null;
    }
  }

  void _wakeUp() {
    final Completer<void>? wake = _wake;
    if (wake != null && !wake.isCompleted) {
      wake.complete();
    }
  }

  void _notify() {
    service.processManager.updateActivity();
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _clock?.cancel();
    unawaited(stop(resumeHours: false));
    super.dispose();
  }
}
