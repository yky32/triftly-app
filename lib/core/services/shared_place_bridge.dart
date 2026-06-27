import 'package:flutter/services.dart';

import '../share/inbound_debug_log.dart';

/// Native bridge for inbound share payloads (`app/share` channel).
abstract final class SharedPlaceBridge {
  static const _channel = MethodChannel('app/share');

  static Future<void> install({required Future<void> Function() onSharedUrlReady}) async {
    inboundDebugLog('Native share bridge installed', kind: InboundLogKind.native);
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSharedUrlReady') {
        inboundDebugLog('iOS onSharedUrlReady — polling Flutter', kind: InboundLogKind.native);
        await onSharedUrlReady();
      }
    });
  }

  static Future<String?> consumePending() async {
    try {
      final result = await _channel.invokeMethod<String>('getPendingSharedUrl');
      final value = result?.trim();
      if (value == null || value.isEmpty) return null;
      inboundDebugLog(
        'Native pending URL consumed · ${truncateInbound(value)}',
        kind: InboundLogKind.native,
      );
      return value;
    } on PlatformException catch (e, st) {
      inboundDebugLog(
        'Native getPendingSharedUrl failed',
        kind: InboundLogKind.error,
        error: e,
        stackTrace: st,
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
