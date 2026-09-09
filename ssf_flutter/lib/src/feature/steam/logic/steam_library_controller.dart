import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';

enum SteamCatalogPhase() {
  idle,
  saving,
  updated,
  partiallyUpdated,
  saveFailed,
  signingOut,
  signedOut,
  signOutFailed,
}

enum SteamLibraryNotice() {
  syncFailed,
  updated,
  partiallyUpdated,
  saveFailed,
  signedOut,
  signOutFailed,
}

class SteamLibraryController({
  required final SteamLibrarySyncController sync,
  final IAppsRepository? repository,
  final Future<void> Function()? onLibraryUpdated,
}) extends ChangeNotifier {
  this {
    sync.addListener(_onSync);
  }

  SteamCatalogPhase phase = SteamCatalogPhase.idle;
  SteamLibraryNotice? notice;
  int noticeRevision = 0;
  int appCount = 0;
  bool switching = false;
  bool _disposed = false;
  bool _reportedFailure = false;
  SteamLibrarySnapshot? _handled;

  bool get saving => phase == SteamCatalogPhase.saving || phase == SteamCatalogPhase.signingOut;

  bool get credentialsEnabled =>
      !saving && !switching && (!sync.busy || (sync.method == SteamSignInMethod.qr && !sync.authenticated));

  void _changed() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _announce(SteamLibraryNotice value) {
    notice = value;
    noticeRevision++;
    _changed();
  }

  void _onSync() {
    if (sync.busy && !saving) {
      phase = SteamCatalogPhase.idle;
      _reportedFailure = false;
    }
    if (sync.failed && !sync.busy && !saving && !_reportedFailure) {
      _reportedFailure = true;
      _announce(SteamLibraryNotice.syncFailed);
    }
    final SteamLibrarySnapshot? library = sync.library;
    if (library != null && !identical(library, _handled) && repository != null && !saving) {
      _handled = library;
      unawaited(_import(library));
    }
    _changed();
  }

  Future<void> _import(SteamLibrarySnapshot library) async {
    phase = SteamCatalogPhase.saving;
    _changed();
    try {
      await repository!.importSteamLibrary(library);
      if (_disposed) {
        return;
      }
      await onLibraryUpdated?.call();
      appCount = library.apps.length;
      phase = library.partial ? SteamCatalogPhase.partiallyUpdated : SteamCatalogPhase.updated;
      _announce(library.partial ? SteamLibraryNotice.partiallyUpdated : SteamLibraryNotice.updated);
    } on Object {
      phase = SteamCatalogPhase.saveFailed;
      _announce(SteamLibraryNotice.saveFailed);
    }
  }

  Future<void> refresh() async {
    if (_disposed || saving || switching || sync.busy) {
      return;
    }
    await sync.restoreOrSignIn();
  }

  Future<void> refreshQr() async {
    if (_disposed || saving || switching || sync.busy) {
      return;
    }
    await sync.start(SteamSignInMethod.qr);
  }

  Future<void> signIn(String username, String password) async {
    if (_disposed || !credentialsEnabled || username.trim().isEmpty || password.isEmpty) {
      return;
    }
    switching = true;
    _changed();
    try {
      await sync.cancel();
      if (!_disposed && !sync.busy) {
        unawaited(sync.start(SteamSignInMethod.credentials, username: username.trim(), password: password));
      }
    } finally {
      switching = false;
      _changed();
    }
  }

  Future<void> logout() async {
    if (_disposed || saving || switching) {
      return;
    }
    phase = SteamCatalogPhase.signingOut;
    _changed();
    try {
      await sync.forgetSessions();
      await repository?.clearLibraryCache(forgetAccount: true);
      if (_disposed) {
        return;
      }
      sync.discardLibraryResult();
      await onLibraryUpdated?.call();
      phase = SteamCatalogPhase.signedOut;
      _announce(SteamLibraryNotice.signedOut);
      if (!_disposed) {
        unawaited(sync.start(SteamSignInMethod.qr));
      }
    } on Object {
      phase = SteamCatalogPhase.signOutFailed;
      _announce(SteamLibraryNotice.signOutFailed);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    sync.removeListener(_onSync);
    sync.dispose();
    super.dispose();
  }
}
