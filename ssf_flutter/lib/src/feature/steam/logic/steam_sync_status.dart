import 'package:ssf_flutter/src/feature/steam/logic/steam_library_controller.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_sync_state.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

String? steamCatalogStatus(SteamLibraryController controller, GeneratedLocalizations l10n) =>
    switch (controller.phase) {
      SteamCatalogPhase.idle => null,
      SteamCatalogPhase.saving => l10n.librarySaving,
      SteamCatalogPhase.updated => l10n.libraryUpdated(controller.appCount),
      SteamCatalogPhase.partiallyUpdated => l10n.libraryUpdatedPartially(controller.appCount),
      SteamCatalogPhase.saveFailed => l10n.librarySaveFailed,
      SteamCatalogPhase.signingOut => l10n.steamSigningOut,
      SteamCatalogPhase.signedOut => l10n.steamSignedOutCacheCleared,
      SteamCatalogPhase.signOutFailed => l10n.steamSignOutFailed,
    };

String steamLibraryNotice(SteamLibraryController controller, GeneratedLocalizations l10n) =>
    switch (controller.notice) {
      SteamLibraryNotice.updated => l10n.libraryUpdated(controller.appCount),
      SteamLibraryNotice.partiallyUpdated => l10n.libraryUpdatedPartially(controller.appCount),
      SteamLibraryNotice.saveFailed => l10n.librarySaveFailed,
      SteamLibraryNotice.signedOut => l10n.steamSignedOutCacheCleared,
      SteamLibraryNotice.signOutFailed => l10n.steamSignOutFailed,
      SteamLibraryNotice.syncFailed || null => steamSyncStatus(controller.sync, l10n),
    };

String steamSyncStatus(SteamLibrarySyncController controller, GeneratedLocalizations l10n) {
  final SteamSyncState state = controller.state;
  return switch (state.phase) {
    SteamSyncPhase.idle => l10n.steamSignInMethodPrompt,
    SteamSyncPhase.checkingSession => l10n.steamSessionChecking,
    SteamSyncPhase.preparingQr || SteamSyncPhase.restoringSession => l10n.steamConnecting,
    SteamSyncPhase.awaitingQr => l10n.steamQrScanPrompt,
    SteamSyncPhase.checkingCredentials => l10n.steamCredentialsChecking,
    SteamSyncPhase.awaitingGuard =>
      state.input?.kind == SteamAuthInputKind.emailCode ? l10n.steamGuardEmailPrompt : l10n.steamGuardAppPrompt,
    SteamSyncPhase.awaitingConfirmation => l10n.steamMobileConfirmationPrompt,
    SteamSyncPhase.checkingGuard => l10n.steamGuardChecking,
    SteamSyncPhase.loadingLibrary => switch (state.libraryPhase) {
      null => l10n.steamLibraryLoading,
      SteamLibraryPhase.personal => l10n.steamPersonalLibraryLoading,
      SteamLibraryPhase.private => l10n.steamPrivateAppsChecking,
      SteamLibraryPhase.family => l10n.steamFamilyLibraryLoading,
      SteamLibraryPhase.hours => l10n.steamPlaytimeUpdating,
      SteamLibraryPhase.metadata => l10n.steamMetadataLoading,
      SteamLibraryPhase.merging => l10n.steamLibraryMerging,
    },
    SteamSyncPhase.finishing => l10n.steamLibraryMerging,
    SteamSyncPhase.cancelling => l10n.steamSignInCancelling,
    SteamSyncPhase.completed =>
      controller.library?.partial ?? false ? l10n.steamLibraryPartialStatus : l10n.steamLibraryReceived,
    SteamSyncPhase.cancelled => l10n.steamSignInCancelled,
    SteamSyncPhase.signedOut => l10n.steamSignedOutStatus,
    SteamSyncPhase.failed => switch (state.failure) {
      SteamSyncFailure.sessionRead => l10n.steamSessionReadFailed,
      SteamSyncFailure.helperStart => l10n.steamHelperStartFailed,
      SteamSyncFailure.protocol => l10n.steamHelperProtocolError,
      SteamSyncFailure.transport => l10n.steamHelperReadFailed,
      SteamSyncFailure.input => l10n.steamAuthInputFailed,
      SteamSyncFailure.stop => l10n.steamHelperStopUnconfirmed,
      SteamSyncFailure.timeout => controller.authenticated ? l10n.steamLibraryTimeout : l10n.steamSignInTimeout,
      SteamSyncFailure.exit =>
        controller.authenticated
            ? l10n.steamLibraryFailedWithCode(state.errorCode ?? '?')
            : l10n.steamSignInFailedWithCode(state.errorCode ?? '?'),
      SteamSyncFailure.operation || null => l10n.steamSyncFailed(state.errorCode ?? 'unknown'),
    },
  };
}
