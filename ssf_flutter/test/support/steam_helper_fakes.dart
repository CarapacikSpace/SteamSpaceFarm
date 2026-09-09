import 'dart:async';
import 'dart:io';

import 'package:ssf_flutter/src/feature/steam/data/steam_helper_client.dart';
import 'package:ssf_flutter/src/feature/steam/data/steam_session_store.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';

class MemorySteamSessionStore() extends SteamSessionStore {
  this : super(directory: Directory('unused-test-session'));
  bool saved = false;
  bool forgotten = false;

  @override
  Future<bool> exists() async => saved;

  @override
  Future<void> forget() async {
    saved = false;
    forgotten = true;
  }
}

class FakeSteamHelperClient() implements SteamHelperClient {
  Completer<int>? _exit;
  void Function(SteamHelperEvent)? listener;
  SteamSignInMethod? method;
  int starts = 0;
  bool autoEvents = false;
  bool failCancel = false;
  final inputs = <(String, String)>[];

  @override
  bool get running => _exit != null && !_exit!.isCompleted;

  @override
  Future<int> run({
    required SteamSignInMethod method,
    required Directory sessionDirectory,
    required void Function(SteamHelperEvent) onEvent,
  }) {
    starts++;
    this.method = method;
    listener = onEvent;
    _exit = Completer<int>();
    if (autoEvents) {
      if (method == SteamSignInMethod.qr) {
        emit(const SteamQrChallenge('https://s.team/q/synthetic'));
      }
      if (method == SteamSignInMethod.credentials) {
        emit(const SteamAuthInput(requestId: 'guard', kind: SteamAuthInputKind.deviceCode));
      }
    }
    return _exit!.future;
  }

  void emit(SteamHelperEvent event) {
    try {
      listener?.call(event);
    } on Object {
      _exit?.completeError(const SteamHelperException(SteamHelperFailure.protocol));
    }
  }

  void finish([int code = 0]) {
    if (running) {
      _exit!.complete(code);
    }
  }

  @override
  Future<void> sendInput(String requestId, String value) async {
    inputs.add((requestId, value));
  }

  @override
  Future<void> cancel({bool force = false}) async {
    if (failCancel) {
      throw const SteamHelperException(SteamHelperFailure.stop);
    }
    finish(4);
  }
}
