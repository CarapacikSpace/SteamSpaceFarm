import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';

class SteamProcessManager() extends ChangeNotifier {
  bool _lastGameActivity = false;

  void updateActivity() {
    final bool active = hasActiveGames;
    if (active != _lastGameActivity) {
      _lastGameActivity = active;
      notifyListeners();
    }
  }

  final _registrations = <SteamProcessRegistration>{};
  Future<void>? _stopping;
  bool _closing = false;

  bool get acceptingStarts => !_closing && _stopping == null;

  bool get hasActiveGames => _registrations.any((entry) => entry._game && entry._isActive());

  bool get hasActiveHelpers => _registrations.any((entry) => !entry._game && entry._isActive());

  bool get acceptingGameStarts => acceptingStarts && !hasActiveHelpers;

  SteamProcessRegistration register({
    required bool Function() isActive,
    required Future<void> Function() stop,
    bool game = false,
  }) {
    final registration = SteamProcessRegistration._(this, isActive, stop, game);
    _registrations.add(registration);
    return registration;
  }

  Future<void> stopAll() {
    final Future<void>? pending = _stopping;
    if (pending != null) {
      return pending;
    }
    final completion = Completer<void>();
    _stopping = completion.future;
    AppLogger.info('Stopping all processes', name: 'Processes');
    unawaited(_stopAll().then(completion.complete, onError: completion.completeError));
    return completion.future;
  }

  Future<void> _stopAll() async {
    try {
      await Future.wait(
        _registrations.toList().where((entry) => entry._isActive()).map((entry) async {
          await entry._stop();
          if (entry._isActive()) {
            throw StateError('Steam process stop not confirmed');
          }
        }),
      );
    } finally {
      _registrations.removeWhere((entry) => entry._released && !entry._isActive());
      _stopping = null;
    }
  }

  Future<void> shutdown() async {
    _closing = true;
    try {
      await stopAll();
    } on Object {
      _closing = false;
      rethrow;
    }
  }
}

class SteamProcessRegistration._(
  final SteamProcessManager _manager,
  final bool Function() _isActive,
  final Future<void> Function() _stop,
  final bool _game,
) {
  bool _released = false;

  void release() {
    _released = true;
    if (!_isActive()) {
      _manager._registrations.remove(this);
    }
  }
}
