import 'dart:convert';

import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';

enum SteamSignInMethod() {
  qr,
  credentials,
  session,
}

enum SteamAuthInputKind() {
  username,
  password,
  emailCode,
  deviceCode,
}

enum SteamLibraryPhase() {
  personal,
  private,
  family,
  hours,
  metadata,
  merging,
}

sealed class const SteamHelperEvent() {
  static SteamHelperEvent parse(String line) {
    final Object? json = jsonDecode(line);
    if (json is! Map<String, dynamic> || json['v'] != 1 || json['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid helper event');
    }
    final data = json['data'] as Map<String, dynamic>;
    return switch (json['event']) {
      'auth.qr' => SteamQrChallenge(_string(data, 'challengeUrl')),
      'auth.input' => SteamAuthInput(
        requestId: _string(data, 'requestId'),
        kind: switch (data['kind']) {
          'username' => SteamAuthInputKind.username,
          'password' => SteamAuthInputKind.password,
          'email_code' => SteamAuthInputKind.emailCode,
          'totp_code' || 'device_code' => SteamAuthInputKind.deviceCode,
          _ => throw const FormatException('Unknown authentication input'),
        },
      ),
      'auth.confirmation' when data['kind'] == 'steam_mobile' => const SteamDeviceConfirmation(),
      'auth.authenticated' => SteamAuthenticated(_string(data, 'steamId')),
      'library.progress' => SteamLibraryProgress(switch (data['phase']) {
        'personal' => SteamLibraryPhase.personal,
        'private' => SteamLibraryPhase.private,
        'family' => SteamLibraryPhase.family,
        'hours' => SteamLibraryPhase.hours,
        'metadata' => SteamLibraryPhase.metadata,
        'merging' => SteamLibraryPhase.merging,
        _ => throw const FormatException('Unknown library phase'),
      }),
      'library.result' => SteamLibraryResult(SteamLibrarySnapshot.fromJson(data)),
      'operation.failed' || 'operation.input_failed' => SteamOperationFailed(_string(data, 'code')),
      'operation.timeout' => const SteamOperationTimedOut(),
      'operation.cancelled' => const SteamOperationCancelled(),
      _ => throw const FormatException('Unknown helper event'),
    };
  }

  static String _string(Map<String, dynamic> data, String key) {
    final Object? value = data[key];
    if (value is! String || value.isEmpty) {
      throw const FormatException('Missing event value');
    }
    return value;
  }
}

final class const SteamQrChallenge(final String url) extends SteamHelperEvent;

final class const SteamAuthInput({required final String requestId, required final SteamAuthInputKind kind})
    extends SteamHelperEvent;

final class const SteamDeviceConfirmation() extends SteamHelperEvent;

final class const SteamAuthenticated(final String steamId) extends SteamHelperEvent;

final class const SteamLibraryProgress(final SteamLibraryPhase phase) extends SteamHelperEvent;

final class const SteamLibraryResult(final SteamLibrarySnapshot library) extends SteamHelperEvent;

final class const SteamOperationFailed(final String code) extends SteamHelperEvent;

final class const SteamOperationTimedOut() extends SteamHelperEvent;

final class const SteamOperationCancelled() extends SteamHelperEvent;
