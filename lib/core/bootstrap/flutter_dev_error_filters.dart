import 'package:flutter/foundation.dart';

/// Hot restart on iOS Simulator + Mac keyboard can deliver a Meta (⌘) [KeyUpEvent]
/// after Flutter resets keyboard state — a known framework/engine desync.
///
/// See https://github.com/flutter/flutter/issues/160062
bool isKnownSimulatorKeyboardSyncNoise(Object error) {
  if (!kDebugMode) return false;

  final text = error.toString();
  return text.contains('KeyUpEvent is dispatched') &&
      text.contains('physical key is not pressed');
}
