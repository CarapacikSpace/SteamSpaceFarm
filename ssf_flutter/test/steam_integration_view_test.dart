import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/steam_process_manager.dart';
import 'package:ssf_flutter/src/feature/catalog/data/apps_repository.dart';
import 'package:ssf_flutter/src/feature/steam/logic/steam_library_sync_controller.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_helper_event.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';
import 'package:ssf_flutter/src/feature/steam/widget/steam_integration_view.dart';
import 'package:ssf_flutter/src/feature/steam/widget/steam_qr_code.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/ui_kit/controls/steam_button.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

import 'support/steam_helper_fakes.dart';

Locale testLocale = const Locale('ru');

void main() {
  setUp(() {
    testLocale = const Locale('ru');
    return GeneratedLocalizations.load(testLocale);
  });
  for (final language in ['ru', 'en']) {
    testWidgets('opening a saved session checks status and waits for explicit refresh ($language)', (tester) async {
      testLocale = Locale(language);
      await GeneratedLocalizations.load(testLocale);
      final client = FakeSteamHelperClient();
      final auth = SteamLibrarySyncController(
        processManager: SteamProcessManager(),
        client: client,
        sessions: MemorySteamSessionStore()..saved = true,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          locale: testLocale,
          theme: buildSteamTheme(),
          home: SteamIntegrationView(controller: auth, restoreSession: true),
        ),
      );
      await tester.pump();
      expect(client.starts, 0);
      expect(find.text(GeneratedLocalizations.current.steamSessionActive), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.tap(find.text(GeneratedLocalizations.current.refreshLibrary));
      await tester.pump();
      expect(client.starts, 1);
      expect(client.method, SteamSignInMethod.session);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('explicit refresh on entry still starts a saved session ($language)', (tester) async {
      testLocale = Locale(language);
      await GeneratedLocalizations.load(testLocale);
      final client = FakeSteamHelperClient();
      final auth = SteamLibrarySyncController(
        processManager: SteamProcessManager(),
        client: client,
        sessions: MemorySteamSessionStore()..saved = true,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          locale: testLocale,
          theme: buildSteamTheme(),
          home: SteamIntegrationView(controller: auth, restoreSession: true, refreshExistingSession: true),
        ),
      );
      await tester.pump();
      expect(client.starts, 1);
      expect(client.method, SteamSignInMethod.session);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expired QR blurs the square and refreshes from its center ($language)', (tester) async {
      testLocale = Locale(language);
      await GeneratedLocalizations.load(testLocale);
      final auth = FakeAuth();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          locale: testLocale,
          theme: buildSteamTheme(),
          home: SteamIntegrationView(controller: auth),
        ),
      );
      await tester.pump();
      final Finder panel = find.byType(SteamQrPanel);
      final Size originalSize = tester.getSize(panel);
      expect(find.byType(SteamQrCode), findsOneWidget);
      auth
        ..handleHelperEvent({'v': 1, 'event': 'operation.timeout', 'data': <String, dynamic>{}})
        ..finish(5);
      await tester.pump();
      final Finder refresh = find.byKey(const ValueKey('steam-refresh-qr'));
      expect(find.byType(SteamQrCode), findsNothing);
      expect(find.descendant(of: panel, matching: find.byType(ImageFiltered)), findsOneWidget);
      expect(tester.getSize(panel), originalSize);
      expect(tester.getCenter(refresh), tester.getCenter(panel));
      expect(find.byTooltip(GeneratedLocalizations.current.refreshQrCode), findsOneWidget);
      expect(find.text(language == 'ru' ? 'Получить QR-код' : 'Get QR code'), findsNothing);
      await tester.tap(refresh);
      await tester.pump();
      expect(auth.selectedMethod, 'qr');
      expect(find.byType(SteamQrCode), findsOneWidget);
      expect(refresh, findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('QR preparation and waiting for a scan do not show loading ($language)', (tester) async {
      testLocale = Locale(language);
      await GeneratedLocalizations.load(testLocale);
      final auth = FakeAuth()..prepare(SteamSignInMethod.qr);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          locale: testLocale,
          theme: buildSteamTheme(),
          home: SteamIntegrationView(controller: auth, autoStartQr: false),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      auth
        ..handleHelperEvent({
          'v': 1,
          'event': 'auth.qr',
          'data': {'challengeUrl': 'https://s.team/q/synthetic'},
        })
        ..handleHelperEvent({
          'v': 1,
          'event': 'auth.confirmation',
          'data': {'kind': 'steam_mobile'},
        });
      await tester.pump();
      expect(find.byType(SteamQrCode), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(GeneratedLocalizations.current.steamMobileConfirmationPrompt), findsNothing);
      expect(tester.widget<TextField>(find.byKey(const ValueKey('steam-login'))).enabled, isTrue);

      auth.handleHelperEvent({
        'v': 1,
        'event': 'auth.authenticated',
        'data': {'steamId': '76561198000000001'},
      });
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text(GeneratedLocalizations.current.steamLibraryLoading), findsOneWidget);
      expect(find.byType(SteamQrCode), findsNothing);
    });

    for (final kind in ['email_code', 'device_code', 'totp_code']) {
      testWidgets('Steam Guard $kind waits for input and supports a new request ($language)', (tester) async {
        testLocale = Locale(language);
        await GeneratedLocalizations.load(testLocale);
        final auth = FakeAuth()..prepare(SteamSignInMethod.credentials);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: Localization.localizationDelegates,
            supportedLocales: Localization.supportedLocales,
            locale: testLocale,
            theme: buildSteamTheme(),
            home: SteamIntegrationView(controller: auth, autoStartQr: false),
          ),
        );
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        auth.handleHelperEvent({
          'v': 1,
          'event': 'auth.confirmation',
          'data': {'kind': 'steam_mobile'},
        });
        await tester.pump();
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text(GeneratedLocalizations.current.steamMobileConfirmationPrompt), findsOneWidget);
        for (final requestId in ['first', 'retry']) {
          auth
            ..handleHelperEvent({
              'v': 1,
              'event': 'auth.input',
              'data': {'requestId': requestId, 'kind': kind},
            })
            ..handleHelperEvent({
              'v': 1,
              'event': 'auth.confirmation',
              'data': {'kind': 'steam_mobile'},
            });
          await tester.pump();
          expect(find.byType(LinearProgressIndicator), findsNothing);
          expect(find.byKey(const ValueKey('steam-guard')), findsOneWidget);
          expect(
            find.text(
              kind == 'email_code'
                  ? GeneratedLocalizations.current.steamGuardEmailPrompt
                  : GeneratedLocalizations.current.steamGuardAppPrompt,
            ),
            findsOneWidget,
          );
          await tester.ensureVisible(find.byKey(const ValueKey('steam-guard')));
          await tester.enterText(find.byKey(const ValueKey('steam-guard')), 'ABCDE');
          await tester.ensureVisible(find.text(GeneratedLocalizations.current.steamGuardSubmit));
          await tester.tap(find.text(GeneratedLocalizations.current.steamGuardSubmit));
          await tester.pump();
          expect(auth.codeReceived, 'ABCDE');
          expect(find.byKey(const ValueKey('steam-guard')), findsNothing);
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
          expect(find.text(GeneratedLocalizations.current.steamGuardChecking), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('refresh button displays progress and prevents duplicate requests ($language)', (tester) async {
      testLocale = Locale(language);
      await GeneratedLocalizations.load(testLocale);
      final auth = FakeAuth()..hasSavedSession = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          locale: testLocale,
          theme: buildSteamTheme(),
          home: SteamIntegrationView(controller: auth, autoStartQr: false),
        ),
      );
      final refresh = language == 'ru' ? 'Обновить библиотеку' : 'Refresh library';
      await tester.tap(find.text(refresh));
      await tester.pump();
      expect(auth.selectedMethod, 'auto');
      expect(auth.refreshCalls, 1);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester.widget<SteamButton>(find.ancestor(of: find.text(refresh), matching: find.byType(SteamButton))).onPressed,
        isNull,
      );
      final phase = language == 'ru' ? 'Обновляем время в играх…' : 'Updating playtime…';
      auth
        ..handleHelperEvent({
          'v': 1,
          'event': 'auth.authenticated',
          'data': {'steamId': '76561198000000001'},
        })
        ..handleHelperEvent({
          'v': 1,
          'event': 'library.progress',
          'data': {'phase': 'hours'},
        });
      await tester.pump();
      expect(find.text(phase), findsOneWidget);
      expect(find.byKey(const ValueKey('steam-update-status')), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Steam import hides the form, notifies below and offers refresh and logout', (tester) async {
    tester.view.physicalSize = const Size(1100, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = FakeAuth();
    final repository = CatalogRepository();
    var refreshes = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: testLocale,
        theme: buildSteamTheme(),
        home: SteamIntegrationView(
          controller: auth,
          appsRepository: repository,
          onLibraryUpdated: () async {
            refreshes++;
          },
        ),
      ),
    );
    auth.completeLibrary();
    await tester.pumpAndSettle();
    expect(repository.imported!.apps.single.name, 'Synthetic');
    expect(refreshes, 1);
    expect(find.text('Уже есть активная сессия'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(SteamQrCode), findsNothing);
    expect(find.text('Очистить кеш игр'), findsNothing);
    expect(find.text('Обновить библиотеку'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(auth.forgotSession, isFalse);
    await tester.tap(find.text('Выйти из аккаунта'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.forgotAccount, isTrue);
    expect(auth.forgotSession, isTrue);
    expect(refreshes, 2);
    expect(find.byKey(const ValueKey('steam-login')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved session replaces embedded form without another page', (tester) async {
    final auth = FakeAuth()..hasSavedSession = true;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: testLocale,
        theme: buildSteamTheme(),
        home: Scaffold(body: SteamIntegrationView(controller: auth, embedded: true, autoStartQr: false)),
      ),
    );
    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Уже есть активная сессия'), findsOneWidget);
    expect(find.text('Выйти из аккаунта'), findsOneWidget);
  });

  testWidgets('changing locale updates the existing Steam tab', (tester) async {
    final auth = FakeAuth()..hasSavedSession = true;
    final tab = SteamIntegrationView(controller: auth, autoStartQr: false);
    Widget localized(Locale locale) => MaterialApp(
      localizationsDelegates: Localization.localizationDelegates,
      supportedLocales: Localization.supportedLocales,
      locale: locale,
      theme: buildSteamTheme(),
      home: tab,
    );
    await tester.pumpWidget(localized(const Locale('ru')));
    await tester.pumpAndSettle();
    expect(find.text('Уже есть активная сессия'), findsOneWidget);
    await tester.pumpWidget(localized(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('You already have an active session'), findsOneWidget);
    expect(find.text('Refresh library'), findsOneWidget);
    expect(find.text('Выйти из аккаунта'), findsNothing);
  });

  testWidgets('failed update shows a bottom notification', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: testLocale,
        theme: buildSteamTheme(),
        home: SteamIntegrationView(controller: auth),
      ),
    );
    auth
      ..handleHelperEvent({
        'v': 1,
        'event': 'operation.failed',
        'data': {'code': 'synthetic'},
      })
      ..finish(1);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(GeneratedLocalizations.current.steamSyncFailed('synthetic')), findsOneWidget);
  });

  testWidgets('auth form stays usable on wide and narrow windows', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    if (const bool.fromEnvironment('SSF_AUTH_GOLDEN')) {
      await tester.runAsync(() async {
        final Uint8List font = await File('C:/Windows/Fonts/segoeui.ttf').readAsBytes();
        for (final family in ['Roboto', 'Segoe UI', 'Ahem']) {
          final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(font)));
          await loader.load();
        }
      });
    }
    for (final size in [const Size(1000, 700), const Size(380, 760)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          locale: testLocale,
          theme: buildSteamTheme(),
          home: SteamIntegrationView(key: ValueKey(size), controller: FakeAuth()),
        ),
      );
      await tester.pump();
      for (final TextField field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.decoration?.labelText, isNull);
        expect(field.decoration?.label, isNull);
      }
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('SSF_AUTH_GOLDEN')) {
        await expectLater(
          find.byType(SteamIntegrationView),
          matchesGoldenFile('../../docs_new/validation/steam-auth-${size.width.toInt()}.png'),
        );
      }
    }
  });

  testWidgets('QR is rendered locally and cancellation removes the challenge', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: testLocale,
        theme: buildSteamTheme(),
        home: SteamIntegrationView(controller: auth),
      ),
    );
    await tester.pump();
    expect(find.byType(SteamQrCode), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(SteamQrCode)).dx,
      greaterThan(tester.getTopRight(find.byKey(const ValueKey('steam-login'))).dx),
    );
    expect(tester.getSize(find.byKey(const ValueKey('steam-login'))).height, greaterThanOrEqualTo(48));
    expect(auth.selectedMethod, 'qr');
    await tester.ensureVisible(find.text('Отменить'));
    await tester.tap(find.text('Отменить'));
    await tester.pump();
    expect(find.byType(SteamQrCode), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('credentials and Guard are entered in Flutter without preserving password in the field', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: testLocale,
        theme: buildSteamTheme(),
        home: SteamIntegrationView(controller: auth),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), 'synthetic-account');
    await tester.enterText(find.byType(TextField).at(1), 'synthetic-password');
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(auth.usernameReceived, 'synthetic-account');
    expect(auth.passwordReceived, 'synthetic-password');
    expect(find.text('synthetic-password'), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('steam-guard')));
    await tester.enterText(find.byKey(const ValueKey('steam-guard')), 'ABCDE');
    await tester.ensureVisible(find.text('Подтвердить код'));
    await tester.tap(find.text('Подтвердить код'));
    await tester.pump();
    expect(auth.codeReceived, 'ABCDE');
    expect(tester.takeException(), isNull);
  });
}

class FakeAuth._(final FakeSteamHelperClient helper, final MemorySteamSessionStore sessions)
    extends SteamLibrarySyncController {
  factory() => FakeAuth._(FakeSteamHelperClient()..autoEvents = true, MemorySteamSessionStore());

  this : super(processManager: SteamProcessManager(), client: helper, sessions: sessions);
  int refreshCalls = 0;

  bool get forgotSession => sessions.forgotten;

  @override
  bool get hasSavedSession => super.hasSavedSession || sessions.saved;

  set hasSavedSession(bool value) => sessions.saved = value;
  String? selectedMethod;
  String? usernameReceived;
  String? passwordReceived;

  String? get codeReceived => helper.inputs.isEmpty ? null : helper.inputs.last.$2;

  void prepare(SteamSignInMethod method) {
    helper.autoEvents = false;
    unawaited(start(method));
  }

  void handleHelperEvent(Map<String, dynamic> event) => helper.emit(SteamHelperEvent.parse(jsonEncode(event)));

  void finish([int code = 0]) => helper.finish(code);

  @override
  Future<void> restoreOrSignIn({bool refresh = true}) async {
    if (refresh) {
      refreshCalls++;
      await start(SteamSignInMethod.session);
    }
  }

  @override
  Future<void> start(SteamSignInMethod method, {String username = '', String password = ''}) async {
    selectedMethod = method == SteamSignInMethod.session ? 'auto' : method.name;
    usernameReceived = username;
    passwordReceived = password;
    unawaited(super.start(method, username: username, password: password));
  }

  void completeLibrary() {
    helper
      ..emit(const SteamAuthenticated('76561198000000001'))
      ..emit(
        SteamLibraryResult(
          SteamLibrarySnapshot.fromJson({
            'schemaVersion': 1,
            'steamId': '76561198000000001',
            'partial': false,
            'apps': [
              {'appId': 480, 'name': 'Synthetic', 'hours': 1, 'ownership': 'personal', 'type': 'game'},
            ],
          }),
        ),
      )
      ..finish();
  }
}

class CatalogRepository() implements IAppsRepository {
  SteamLibrarySnapshot? imported;
  bool? forgotAccount;

  @override
  Future<void> importSteamLibrary(SteamLibrarySnapshot snapshot) async {
    imported = snapshot;
  }

  @override
  Future<void> clearLibraryCache({bool forgetAccount = false}) async {
    forgotAccount = forgetAccount;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
