import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/steam/data/steam_helper_client.dart';
import 'package:ssf_flutter/src/feature/steam/data/steam_session_store.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_sync_state.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';

class SteamLibrarySyncController({
  required final SteamProcessManager processManager,
  SteamHelperClient? client,
  SteamSessionStore? sessions,
}) extends ChangeNotifier {
  this {
    _registration = processManager.register(isActive: () => busy, stop: () => cancel(force: true));
  }

  late final SteamProcessRegistration _registration;

  final SteamHelperClient _client = client ?? ProcessSteamHelperClient();
  final SteamSessionStore _sessions = sessions ?? SteamSessionStore();
  SteamSyncState _state = const SteamSyncState(phase: SteamSyncPhase.idle);
  SteamSignInMethod _method = SteamSignInMethod.qr;
  Future<void>? _operation;
  int _generation = 0;
  bool _disposed = false;
  bool _hasSavedSession = false;
  String? _steamId;
  String _username = '';
  String _password = '';
  SteamLibrarySnapshot? _library;

  SteamSyncState get state => _state;

  SteamSignInMethod get method => _method;

  bool get busy => _operation != null || _client.running || checkingSession;

  bool get checkingSession => state.phase == SteamSyncPhase.checkingSession;

  bool get authenticated => _steamId != null;

  bool get hasSavedSession => _hasSavedSession;

  bool get failed => state.phase == SteamSyncPhase.failed;

  bool get wasCancelled => state.phase == SteamSyncPhase.cancelled || state.phase == SteamSyncPhase.cancelling;

  bool get awaitingQrScan => state.phase == SteamSyncPhase.preparingQr || state.phase == SteamSyncPhase.awaitingQr;

  bool get showProgress => state.isWorking;

  String? get qrUrl => state.qrUrl;

  SteamAuthInputKind? get inputKind => state.input?.kind;

  SteamLibrarySnapshot? get library => _library;

  void _setState(SteamSyncState value) {
    _state = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> restoreOrSignIn({bool refresh = true}) async {
    if (busy || _disposed || !processManager.acceptingStarts) {
      return;
    }
    final int generation = ++_generation;
    _setState(const SteamSyncState(phase: SteamSyncPhase.checkingSession));
    try {
      final bool exists = await _sessions.exists();
      if (!_current(generation)) {
        return;
      }
      _hasSavedSession = exists;
      _setState(const SteamSyncState(phase: SteamSyncPhase.idle));
      if (!exists || refresh) {
        await start(exists ? SteamSignInMethod.session : SteamSignInMethod.qr);
      }
    } on Object {
      if (_current(generation)) {
        _fail(SteamSyncFailure.sessionRead);
      }
    }
  }

  Future<void> forgetSessions() async {
    await cancel();
    if (busy) {
      throw StateError('Steam process is still running');
    }
    await _sessions.forget();
    _hasSavedSession = false;
    _steamId = null;
    _library = null;
    _setState(const SteamSyncState(phase: SteamSyncPhase.signedOut));
  }

  void discardLibraryResult() {
    _library = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> start(SteamSignInMethod method, {String username = '', String password = ''}) {
    if (busy || _disposed || !processManager.acceptingStarts) {
      return Future<void>.value();
    }
    final int generation = ++_generation;
    final completion = Completer<void>();
    _operation = completion.future;
    _method = method;
    AppLogger.info('Starting ${method.name}', name: 'Steam');
    _username = username;
    _password = password;
    _steamId = null;
    _library = null;
    _setState(
      SteamSyncState(
        phase: switch (method) {
          SteamSignInMethod.qr => SteamSyncPhase.preparingQr,
          SteamSignInMethod.credentials => SteamSyncPhase.checkingCredentials,
          SteamSignInMethod.session => SteamSyncPhase.restoringSession,
        },
      ),
    );
    unawaited(_run(generation).whenComplete(completion.complete));
    return completion.future;
  }

  Future<void> _run(int generation) async {
    SteamLibrarySnapshot? pending;
    try {
      if (method == SteamSignInMethod.session && !await _sessions.exists()) {
        _hasSavedSession = false;
        throw const SteamHelperException(SteamHelperFailure.start);
      }
      if (!_current(generation)) {
        return;
      }
      final int code = await _client.run(
        method: method,
        sessionDirectory: _sessions.directory,
        onEvent: (event) {
          if (!_current(generation)) {
            return;
          }
          if (event case SteamLibraryResult(:final library)) {
            if (!authenticated || library.steamId != _steamId || state.isTerminal || pending != null) {
              throw const FormatException('Unexpected library account or result');
            }
            pending = library;
            _setState(const SteamSyncState(phase: SteamSyncPhase.finishing));
          } else {
            _handleEvent(event, generation);
          }
        },
      );
      if (!_current(generation) || failed || wasCancelled) {
        return;
      }
      if (pending != null && (code == 0 || code == 3)) {
        _library = pending;
        _setState(const SteamSyncState(phase: SteamSyncPhase.completed));
      } else if (code == 4) {
        _setState(const SteamSyncState(phase: SteamSyncPhase.cancelled));
      } else if (code == 5) {
        _fail(SteamSyncFailure.timeout);
      } else {
        _fail(SteamSyncFailure.exit, code: '$code');
      }
    } on SteamHelperException catch (error) {
      if (_current(generation)) {
        _fail(switch (error.failure) {
          SteamHelperFailure.start => SteamSyncFailure.helperStart,
          SteamHelperFailure.protocol => SteamSyncFailure.protocol,
          SteamHelperFailure.transport => SteamSyncFailure.transport,
          SteamHelperFailure.input => SteamSyncFailure.input,
          SteamHelperFailure.stop => SteamSyncFailure.stop,
          SteamHelperFailure.timeout => SteamSyncFailure.timeout,
        });
      }
    } on Object {
      if (_current(generation)) {
        _fail(SteamSyncFailure.helperStart);
      }
    } finally {
      _clearCredentials();
      _operation = null;
      if (_disposed && !_client.running) {
        _registration.release();
      }
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  void _handleEvent(SteamHelperEvent event, int generation) {
    if (state.isTerminal) {
      return;
    }
    switch (event) {
      case SteamQrChallenge(:final url):
        if (method != SteamSignInMethod.qr || authenticated) {
          throw const FormatException('Unexpected QR');
        }
        _setState(SteamSyncState(phase: SteamSyncPhase.awaitingQr, qrUrl: url));
      case SteamAuthInput(:final requestId, :final kind):
        if (authenticated) {
          throw const FormatException('Unexpected authentication input');
        }
        if (kind == SteamAuthInputKind.username || kind == SteamAuthInputKind.password) {
          if (method != SteamSignInMethod.credentials) {
            throw const FormatException('Unexpected credentials');
          }
          final String value = kind == SteamAuthInputKind.username ? _username : _password;
          if (kind == SteamAuthInputKind.username) {
            _username = '';
          } else {
            _password = '';
          }
          unawaited(_sendInput(requestId, value, generation));
          _setState(const SteamSyncState(phase: SteamSyncPhase.checkingCredentials));
        } else {
          _setState(SteamSyncState(phase: SteamSyncPhase.awaitingGuard, input: event));
        }
      case SteamDeviceConfirmation():
        if (method != SteamSignInMethod.qr && state.phase != SteamSyncPhase.awaitingGuard && !authenticated) {
          _setState(const SteamSyncState(phase: SteamSyncPhase.awaitingConfirmation));
        }
      case SteamAuthenticated(:final steamId):
        if (authenticated) {
          throw const FormatException('Duplicate authentication');
        }
        _steamId = steamId;
        _hasSavedSession = true;
        _clearCredentials();
        _setState(const SteamSyncState(phase: SteamSyncPhase.loadingLibrary));
      case SteamLibraryProgress(:final phase):
        if (!authenticated || state.phase == SteamSyncPhase.finishing) {
          throw const FormatException('Unexpected progress');
        }
        _setState(SteamSyncState(phase: SteamSyncPhase.loadingLibrary, libraryPhase: phase));
      case SteamOperationFailed(:final code):
        _fail(SteamSyncFailure.operation, code: code);
      case SteamOperationTimedOut():
        _fail(SteamSyncFailure.timeout);
      case SteamOperationCancelled():
        _clearCredentials();
        _setState(const SteamSyncState(phase: SteamSyncPhase.cancelled));
      case SteamLibraryResult():
        throw const FormatException('Unexpected result');
    }
  }

  Future<void> submitCode(String value) async {
    final SteamAuthInput? input = state.input;
    if (state.phase != SteamSyncPhase.awaitingGuard || input == null || value.trim().isEmpty) {
      return;
    }
    _setState(const SteamSyncState(phase: SteamSyncPhase.checkingGuard));
    await _sendInput(input.requestId, value.trim(), _generation);
  }

  Future<void> _sendInput(String id, String value, int generation) async {
    if (!_current(generation)) {
      return;
    }
    try {
      await _client.sendInput(id, value);
    } on Object {
      if (!_current(generation)) {
        return;
      }
      _fail(SteamSyncFailure.input);
      try {
        await _client.cancel();
      } on Object {
        if (_current(generation)) {
          _fail(SteamSyncFailure.stop);
        }
      }
    }
  }

  Future<void> cancel({bool force = false}) async {
    final int generation = ++_generation;
    final Future<void>? operation = _operation;
    _clearCredentials();
    _setState(const SteamSyncState(phase: SteamSyncPhase.cancelling));
    try {
      await _client.cancel(force: force);
      await operation;
      if (_generation == generation) {
        _setState(const SteamSyncState(phase: SteamSyncPhase.cancelled));
      }
      if (_disposed && !_client.running) {
        _registration.release();
      }
    } on Object {
      if (_generation == generation) {
        _fail(SteamSyncFailure.stop);
      }
    }
  }

  void _fail(SteamSyncFailure failure, {String? code}) {
    AppLogger.info('Failed: ${failure.name}', name: 'Steam');
    _clearCredentials();
    _setState(SteamSyncState(phase: SteamSyncPhase.failed, failure: failure, errorCode: code));
  }

  void _clearCredentials() {
    _username = '';
    _password = '';
  }

  bool _current(int generation) => !_disposed && generation == _generation && processManager.acceptingStarts;

  @override
  void dispose() {
    _disposed = true;
    unawaited(
      cancel().whenComplete(() {
        if (!_client.running) {
          _registration.release();
        }
      }),
    );
    super.dispose();
  }
}
