import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only auth tracing — search console for `[triftly.auth]`.
void authDebugLog(
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  debugPrint('[triftly.auth] $message');
  developer.log(
    message,
    name: 'triftly.auth',
    error: error,
    stackTrace: stackTrace,
  );
}
