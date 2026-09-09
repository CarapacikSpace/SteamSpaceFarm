import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_controller.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_sync_status.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/widget/steam_qr_code.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_button.dart';
import 'package:ssf_flutter/src/ui_kit/layout/steam_surface_card.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_notice.dart';

class const SteamIntegrationView({
  final SteamLibrarySyncController? controller,
  final SteamProcessManager? processManager,
  final bool autoStartQr = true,
  final bool restoreSession = false,
  final bool embedded = false,
  final bool refreshExistingSession = false,
  final IAppsRepository? appsRepository,
  final Future<void> Function()? onLibraryUpdated,
  super.key,
}) extends StatefulWidget {
  this : assert(controller != null || processManager != null);

  @override
  State<SteamIntegrationView> createState() => _SteamIntegrationViewState();
}

class _SteamIntegrationViewState() extends State<SteamIntegrationView> {
  late final SteamLibrarySyncController _auth =
      widget.controller ?? SteamLibrarySyncController(processManager: widget.processManager!);
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  late final _libraryController = SteamLibraryController(
    sync: _auth,
    repository: widget.appsRepository,
    onLibraryUpdated: widget.onLibraryUpdated,
  );
  int _noticeRevision = 0;

  bool get _saving => _libraryController.saving;

  bool get _switching => _libraryController.switching;

  String get _authStatus => steamSyncStatus(_auth, GeneratedLocalizations.of(context));

  String? get _catalogStatus => steamCatalogStatus(_libraryController, GeneratedLocalizations.of(context));

  bool get _credentialsEnabled => _libraryController.credentialsEnabled;

  @override
  void initState() {
    super.initState();
    _libraryController.addListener(_handleNotice);
    if (widget.autoStartQr) {
      unawaited(
        widget.restoreSession
            ? _auth.restoreOrSignIn(refresh: widget.refreshExistingSession)
            : _auth.start(SteamSignInMethod.qr),
      );
    }
  }

  void _notifyUser(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showSteamNotice(context, message);
    });
  }

  void _handleNotice() {
    if (_noticeRevision == _libraryController.noticeRevision) {
      return;
    }
    _noticeRevision = _libraryController.noticeRevision;
    if (_libraryController.notice == SteamLibraryNotice.signedOut) {
      _login.clear();
      _password.clear();
      _code.clear();
    }
    _notifyUser(steamLibraryNotice(_libraryController, GeneratedLocalizations.of(context)));
  }

  Future<void> _leaveScreen() async {
    if (_saving || _switching) {
      return;
    }
    if (_auth.busy) {
      await _auth.cancel();
    }
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && !_auth.busy && !_saving) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _libraryController.removeListener(_handleNotice);
    _libraryController.dispose();
    _login.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_credentialsEnabled) {
      return;
    }
    if (_login.text.trim().isEmpty || _password.text.isEmpty) {
      showSteamNotice(context, GeneratedLocalizations.of(context).steamCredentialsRequired);
      return;
    }
    final Future<void> signIn = _libraryController.signIn(_login.text, _password.text);
    _password.clear();
    _code.clear();
    await signIn;
  }

  Widget _caption(String text, {bool accent = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: accent ? const Color(0xFF1A9FFF) : const Color(0xFFB9BDC5),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _credentials() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _caption(GeneratedLocalizations.of(context).steamCredentialsTitle, accent: true),
      TextField(
        key: const ValueKey('steam-login'),
        controller: _login,
        enabled: _credentialsEnabled,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: GeneratedLocalizations.of(context).steamAccountName,
          fillColor: const Color(0xFF32353C),
        ),
      ),
      const SizedBox(height: 16),
      _caption(GeneratedLocalizations.of(context).password),
      TextField(
        key: const ValueKey('steam-password'),
        controller: _password,
        enabled: _credentialsEnabled,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          hintText: GeneratedLocalizations.of(context).password,
          fillColor: const Color(0xFF32353C),
        ),
        onSubmitted: (_) => unawaited(_signIn()),
      ),
      const SizedBox(height: 22),
      Align(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Opacity(
            opacity: _credentialsEnabled ? 1 : .5,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                gradient: LinearGradient(colors: [Color(0xFF06BFFF), Color(0xFF2D73FF)]),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    maximumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: _credentialsEnabled ? () => unawaited(_signIn()) : null,
                  child: Text(GeneratedLocalizations.of(context).signIn, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ),
      ),
      if (_auth.inputKind != null) ...[
        const SizedBox(height: 20),
        _caption(
          _auth.inputKind == SteamAuthInputKind.emailCode
              ? GeneratedLocalizations.of(context).steamGuardEmailLabel
              : GeneratedLocalizations.of(context).steamGuardCode,
          accent: true,
        ),
        TextField(
          key: const ValueKey('steam-guard'),
          controller: _code,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            hintText: GeneratedLocalizations.of(context).enterCode,
            fillColor: const Color(0xFF32353C),
          ),
          onSubmitted: (_) => _submitCode(),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _submitCode, child: Text(GeneratedLocalizations.of(context).steamGuardSubmit)),
      ],
    ],
  );

  Widget _qr() => SizedBox(
    width: 208,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _caption(GeneratedLocalizations.of(context).steamQrTitle, accent: true),
        SteamQrPanel(
          data: _auth.qrUrl,
          active: _auth.busy && _auth.method == SteamSignInMethod.qr && !_auth.failed && !_auth.wasCancelled,
          onRefresh: !_auth.busy && !_saving && !_switching && !_auth.checkingSession
              ? () => unawaited(_libraryController.refreshQr())
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          GeneratedLocalizations.of(context).steamQrInstructions,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xFFB9BDC5)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Widget content = AnimatedBuilder(
      animation: _libraryController,
      builder: (context, _) {
        final bool active = _auth.hasSavedSession || _auth.authenticated;
        return PopScope<void>(
          canPop: !_auth.busy && !_saving,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              unawaited(_leaveScreen());
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_auth.checkingSession)
                      SteamSurfaceCard(
                        child: _progressStatus(GeneratedLocalizations.of(context).steamSessionChecking, running: true),
                      )
                    else if (active)
                      SteamSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'STEAM',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: Color(0xFFDCDEE2),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              GeneratedLocalizations.of(context).steamSessionActive,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SteamButton(
                                  variant: SteamButtonVariant.primary,
                                  height: 32,
                                  onPressed: _auth.busy || _saving
                                      ? null
                                      : () => unawaited(_libraryController.refresh()),
                                  icon: const Icon(Icons.sync),
                                  child: Text(GeneratedLocalizations.of(context).refreshLibrary),
                                ),
                                SteamButton(
                                  variant: SteamButtonVariant.shopping,
                                  height: 32,
                                  onPressed: _saving ? null : () => unawaited(_libraryController.logout()),
                                  icon: const Icon(Icons.logout),
                                  child: Text(GeneratedLocalizations.of(context).signOut),
                                ),
                              ],
                            ),
                            if (_auth.busy || _saving || _catalogStatus != null || _auth.state.isTerminal) ...[
                              const SizedBox(height: 24),
                              _progressStatus(_catalogStatus ?? _authStatus, running: _auth.showProgress || _saving),
                            ],
                          ],
                        ),
                      )
                    else ...[
                      SteamSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'STEAM',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: Color(0xFFDCDEE2),
                              ),
                            ),
                            const SizedBox(height: 30),
                            LayoutBuilder(
                              builder: (context, constraints) => constraints.maxWidth >= 570
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _credentials()),
                                        const SizedBox(width: 36),
                                        _qr(),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _credentials(),
                                        const SizedBox(height: 28),
                                        Center(child: _qr()),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 24),
                            if (_auth.busy) ...[
                              if (!_auth.awaitingQrScan) _progressStatus(_authStatus, running: _auth.showProgress),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => unawaited(_auth.cancel()),
                                  child: Text(GeneratedLocalizations.of(context).cancelAction),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        GeneratedLocalizations.of(context).steamSessionPrivacyHint,
                        style: const TextStyle(color: Color(0xFF8D929A), fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return widget.embedded
        ? content
        : Scaffold(
            appBar: AppBar(title: Text(GeneratedLocalizations.of(context).steamConnection)),
            body: content,
          );
  }

  void _submitCode() {
    unawaited(_auth.submitCode(_code.text));
    _code.clear();
  }

  Widget _progressStatus(String text, {required bool running}) => Semantics(
    liveRegion: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text,
          key: const ValueKey('steam-update-status'),
          style: const TextStyle(color: Color(0xFFB9BDC5), height: 1.4),
        ),
        if (running) ...[const SizedBox(height: 12), const LinearProgressIndicator(minHeight: 2)],
      ],
    ),
  );
}
