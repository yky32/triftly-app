import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../environment.dart';
import 'auth_debug_log.dart';

/// Logs OAuth deep links on iOS and ensures native forwards reach Flutter.
///
/// Session exchange is handled solely by `supabase_flutter` via `app_links`
/// (after [AppDelegate] calls `super.application`). Do not call
/// [getSessionFromUrl] here — duplicate calls cause `flow_state_not_found`.
class AuthDeepLinkBridge {
  AuthDeepLinkBridge._();

  static const _channel = MethodChannel('com.triftly/auth');

  static bool _installed = false;
  static String? _lastLoggedUrl;

  static Future<void> install() async {
    if (_installed || !Environment.hasSupabase) return;
    _installed = true;

    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_onMethodCall);
      try {
        final pending = await _channel.invokeMethod<String>('getPendingOAuthCallback');
        if (pending != null && pending.isNotEmpty) {
          _logOAuthUri(Uri.parse(pending), source: 'ios-pending');
        }
      } catch (e, st) {
        authDebugLog(
          'Could not read pending OAuth callback from iOS',
          kind: AuthLogKind.error,
          error: e,
          stackTrace: st,
        );
      }
    }

    authDebugLog('Auth deep link bridge installed', kind: AuthLogKind.deepLink);
  }

  static Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'onOAuthCallback') {
      final raw = call.arguments;
      if (raw is String && raw.isNotEmpty) {
        _logOAuthUri(Uri.parse(raw), source: 'ios-channel');
      }
    }
  }

  static void _logOAuthUri(Uri uri, {required String source}) {
    if (uri.scheme != 'triftly' || uri.host != 'login-callback') return;

    final raw = uri.toString();
    if (_lastLoggedUrl == raw) return;
    _lastLoggedUrl = raw;

    if (uri.queryParameters.containsKey('error')) {
      authDebugLog(
        'OAuth error ($source): ${uri.queryParameters['error']} '
        '${uri.queryParameters['error_description'] ?? ''}',
        kind: AuthLogKind.error,
      );
      return;
    }

    authDebugLog(
      'OAuth callback ($source) — Supabase will exchange code',
      kind: AuthLogKind.deepLink,
    );
  }
}
