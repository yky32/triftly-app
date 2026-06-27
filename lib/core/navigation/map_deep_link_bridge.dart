import 'dart:async';

import 'package:app_links/app_links.dart';

import '../share/inbound_debug_log.dart';
import 'shared_map_redirect.dart';

/// Backup path for `triftly://map?url=…` when the native channel fires late.
abstract final class MapDeepLinkBridge {
  static StreamSubscription<Uri>? _subscription;

  static Future<void> install() async {
    await _subscription?.cancel();
    final appLinks = AppLinks();
    inboundDebugLog('Map deep link bridge installed', kind: InboundLogKind.deepLink);

    try {
      final initial = await appLinks.getInitialLink();
      _handleUri(initial, source: 'initial');
    } catch (error, stack) {
      inboundDebugLog(
        'Initial map deep link failed',
        kind: InboundLogKind.error,
        error: error,
        stackTrace: stack,
      );
    }

    _subscription = appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, source: 'stream'),
      onError: (Object error, StackTrace stack) {
        inboundDebugLog(
          'Map deep link stream error',
          kind: InboundLogKind.error,
          error: error,
          stackTrace: stack,
        );
      },
    );
  }

  static void _handleUri(Uri? uri, {required String source}) {
    if (uri == null || !SharedMapRedirect.isMapInbound(uri)) return;
    SharedMapRedirect.redirectPath(uri, fallbackPath: '/plan');
    inboundDebugLog(
      'Map link ($source) staged via app_links',
      kind: InboundLogKind.deepLink,
    );
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
