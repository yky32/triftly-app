import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Console filter — search for this in Xcode / `flutter run` output.
const authLogFilter = '🔐 AUTH';

/// Kind of auth log line (emoji prefix after [AUTH]).
enum AuthLogKind {
  info('·'),
  oauth('🌐'),
  deepLink('🔗'),
  session('👤'),
  sync('☁️'),
  success('✅'),
  error('❌');

  const AuthLogKind(this.glyph);
  final String glyph;
}

/// Debug-only auth tracing.
///
/// Example line:
/// `🔐 AUTH 🌐 │ Launching Google OAuth → redirectTo=triftly://login-callback`
///
/// Filter console with: `🔐 AUTH` or `AUTH │`
void authDebugLog(
  String message, {
  AuthLogKind kind = AuthLogKind.info,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;

  final line = '$authLogFilter ${kind.glyph} │ $message';
  debugPrint(line);
  developer.log(
    line,
    name: 'triftly.auth',
    error: error,
    stackTrace: stackTrace,
  );
}
