import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';

enum SteamSyncPhase() {
  idle,
  checkingSession,
  preparingQr,
  awaitingQr,
  checkingCredentials,
  awaitingGuard,
  awaitingConfirmation,
  restoringSession,
  checkingGuard,
  loadingLibrary,
  finishing,
  cancelling,
  completed,
  failed,
  cancelled,
  signedOut,
}

enum SteamSyncFailure() {
  sessionRead,
  helperStart,
  protocol,
  transport,
  input,
  stop,
  timeout,
  operation,
  exit,
}

class const SteamSyncState({
  required final SteamSyncPhase phase,
  final String? qrUrl,
  final SteamAuthInput? input,
  final SteamLibraryPhase? libraryPhase,
  final SteamSyncFailure? failure,
  final String? errorCode,
}) {
  bool get isTerminal => switch (phase) {
    SteamSyncPhase.completed || SteamSyncPhase.failed || SteamSyncPhase.cancelled => true,
    _ => false,
  };

  bool get isWorking => switch (phase) {
    SteamSyncPhase.checkingSession ||
    SteamSyncPhase.checkingCredentials ||
    SteamSyncPhase.restoringSession ||
    SteamSyncPhase.checkingGuard ||
    SteamSyncPhase.loadingLibrary ||
    SteamSyncPhase.finishing ||
    SteamSyncPhase.cancelling => true,
    _ => false,
  };
}
