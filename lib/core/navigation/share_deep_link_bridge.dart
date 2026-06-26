import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../utils/share_link.dart';

/// Routes `https://triftly.app/s/{token}` (and dev custom scheme) into go_router.
abstract final class ShareDeepLinkBridge {
  static String? _pendingShareToken;
  static StreamSubscription<Uri>? _subscription;

  static String? consumePendingShareToken() {
    final token = _pendingShareToken;
    _pendingShareToken = null;
    return token;
  }

  static Future<void> install(GoRouter router) async {
    await _subscription?.cancel();
    final appLinks = AppLinks();

    try {
      final initial = await appLinks.getInitialLink();
      _routeUri(initial, router, storePending: true);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('ShareDeepLinkBridge initial link failed: $error\n$stack');
      }
    }

    _subscription = appLinks.uriLinkStream.listen(
      (uri) => _routeUri(uri, router, storePending: false),
      onError: (Object error, StackTrace stack) {
        if (kDebugMode) {
          debugPrint('ShareDeepLinkBridge stream error: $error\n$stack');
        }
      },
    );
  }

  static void _routeUri(Uri? uri, GoRouter router, {required bool storePending}) {
    final token = ShareLink.tokenFromUri(uri);
    if (token == null || token.isEmpty) return;

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
