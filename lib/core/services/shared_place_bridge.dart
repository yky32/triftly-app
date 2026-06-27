import 'package:flutter/services.dart';

/// Native bridge for inbound share payloads (`app/share` channel).
abstract final class SharedPlaceBridge {
  static const _channel = MethodChannel('app/share');

  static Future<String?> consumePending() async {
    try {
      final result = await _channel.invokeMethod<String>('getPendingSharedUrl');
      final value = result?.trim();
      if (value == null || value.isEmpty) return null;
      return value;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
