import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'auth_debug_log.dart';

/// User dismissed the in-app OAuth sheet before completing sign-in.
class OAuthSignInCanceled implements Exception {
  const OAuthSignInCanceled();

  @override
  String toString() => 'Sign-in canceled';
}

/// In-app OAuth on iOS via [ASWebAuthenticationSession].
///
/// Unlike external Safari or SFSafariViewController, this captures
/// `triftly://login-callback` inside the app and dismisses automatically.
class AuthOAuthSession {
  AuthOAuthSession._();

  static const _channel = MethodChannel('com.triftly/auth');

  /// Opens Google OAuth in an in-app auth sheet (iOS only).
  ///
  /// Returns the callback [Uri] on success, or `null` when the user cancels.
  static Future<Uri?> launch({
    required Uri oauthUrl,
    required String callbackScheme,
  }) async {
    if (!Platform.isIOS) return null;

    authDebugLog(
      'Starting in-app OAuth session → $callbackScheme callback',
      kind: AuthLogKind.oauth,
    );

    try {
      final result = await _channel.invokeMethod<String>('startOAuthSession', {
        'url': oauthUrl.toString(),
        'callbackScheme': callbackScheme,
      });
      if (result == null || result.isEmpty) return null;
      return Uri.parse(result);
    } on PlatformException catch (e, st) {
      if (e.code == 'canceled') {
        authDebugLog('OAuth session canceled by user', kind: AuthLogKind.oauth);
        return null;
      }
      authDebugLog(
        'OAuth session failed',
        kind: AuthLogKind.error,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
