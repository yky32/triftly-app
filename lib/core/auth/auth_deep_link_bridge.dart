import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../environment.dart';
import 'auth_debug_log.dart';
import 'auth_redirect.dart';

/// Completes Supabase OAuth when the app receives `triftly://login-callback`.
///
/// iOS: native [AppDelegate] forwards the URL via method channel (app_links alone
/// can miss warm-resume callbacks). All platforms also listen to [AppLinks].
class AuthDeepLinkBridge {
  AuthDeepLinkBridge._();

  static const _channel = MethodChannel('com.triftly/auth');

  static StreamSubscription<Uri>? _appLinksSub;
  static bool _installed = false;

  /// Last OAuth URL handled — avoids duplicate [getSessionFromUrl] calls.
  static String? _lastHandledUrl;

  static Future<void> install() async {
    if (_installed || !Environment.hasSupabase) return;
    _installed = true;

    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_onMethodCall);
      try {
        final pending = await _channel.invokeMethod<String>('getPendingOAuthCallback');
        if (pending != null && pending.isNotEmpty) {
          await _handleOAuthUri(Uri.parse(pending), source: 'ios-pending');
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

    final appLinks = AppLinks();
    await _appLinksSub?.cancel();
    _appLinksSub = appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handleOAuthUri(uri, source: 'app_links')),
      onError: (Object e, StackTrace st) {
        authDebugLog(
          'app_links stream error',
          kind: AuthLogKind.error,
          error: e,
          stackTrace: st,
        );
      },
    );
    authDebugLog('Auth deep link bridge installed', kind: AuthLogKind.deepLink);
  }

  static Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'onOAuthCallback') {
      final raw = call.arguments;
      if (raw is String && raw.isNotEmpty) {
        await _handleOAuthUri(Uri.parse(raw), source: 'ios-channel');
      }
    }
  }

  static bool _isOAuthCallback(Uri uri) {
    if (uri.scheme != 'triftly') return false;
    final host = uri.host;
    if (host == 'login-callback') return true;
    // Some launchers omit host: triftly:///login-callback or path-only.
    if (host.isEmpty && uri.path.contains('login-callback')) return true;
    return false;
  }

  static Future<void> _handleOAuthUri(Uri uri, {required String source}) async {
    if (!_isOAuthCallback(uri)) return;

    final raw = uri.toString();
    if (_lastHandledUrl == raw) {
      authDebugLog('Skipping duplicate OAuth URL ($source)', kind: AuthLogKind.deepLink);
      return;
    }

    authDebugLog('OAuth callback ($source): $uri', kind: AuthLogKind.deepLink);

    if (uri.queryParameters.containsKey('error')) {
      authDebugLog(
        'OAuth error in callback: ${uri.queryParameters['error']} '
        '${uri.queryParameters['error_description'] ?? ''}',
        kind: AuthLogKind.error,
      );
      return;
    }

    final hasCode = uri.queryParameters.containsKey('code');
    final hasToken = uri.fragment.contains('access_token');
    if (!hasCode && !hasToken) {
      authDebugLog('OAuth callback missing code/token', kind: AuthLogKind.error);
      return;
    }

    if (!Supabase.instance.isInitialized) {
      authDebugLog('Supabase not initialized — cannot complete OAuth', kind: AuthLogKind.error);
      return;
    }

    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      _lastHandledUrl = raw;
      authDebugLog('getSessionFromUrl succeeded ($source)', kind: AuthLogKind.success);
    } catch (e, st) {
      authDebugLog(
        'getSessionFromUrl failed ($source)',
        kind: AuthLogKind.error,
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Parses [AuthRedirect.url] for native iOS host matching.
  static String get loginCallbackHost {
    final uri = Uri.parse(AuthRedirect.url);
    return uri.host.isNotEmpty ? uri.host : 'login-callback';
  }
}
