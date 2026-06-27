import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

import '../share/inbound_debug_log.dart';
import '../utils/share_link.dart';

/// Routes `https://triftly.app/s/{token}` (and dev custom scheme) into go_router.
abstract final class ShareDeepLinkBridge {
  static String? _pendingShareToken;
  static StreamSubscription<Uri>? _subscription;

  static String? consumePendingShareToken() {
    final token = _pendingShareToken;
    _pendingShareToken = null;
    if (token != null) {
      inboundDebugLog('Trip share token consumed → $token', kind: InboundLogKind.flow);
    }
    return token;
  }

  static Future<void> install(GoRouter router) async {
    await _subscription?.cancel();
    final appLinks = AppLinks();
    inboundDebugLog('Trip share deep link bridge installed', kind: InboundLogKind.deepLink);

    try {
      final initial = await appLinks.getInitialLink();
      _routeUri(initial, router, storePending: true, source: 'initial');
    } catch (error, stack) {
      inboundDebugLog(
        'Initial trip share link failed',
        kind: InboundLogKind.error,
        error: error,
        stackTrace: stack,
      );
    }

    _subscription = appLinks.uriLinkStream.listen(
      (uri) => _routeUri(uri, router, storePending: false, source: 'stream'),
      onError: (Object error, StackTrace stack) {
        inboundDebugLog(
          'Trip share link stream error',
          kind: InboundLogKind.error,
          error: error,
          stackTrace: stack,
        );
      },
    );
  }

  static void _routeUri(
    Uri? uri,
    GoRouter router, {
    required bool storePending,
    required String source,
  }) {
    if (uri == null) return;

    final token = ShareLink.tokenFromUri(uri);
    if (token == null || token.isEmpty) return;

    inboundDebugLog(
      'Trip share link ($source) → token=$token · ${truncateInbound(uri.toString())}',
      kind: InboundLogKind.deepLink,
    );

    if (storePending) {
      _pendingShareToken = token;
    }

    router.go('/s/$token');
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
