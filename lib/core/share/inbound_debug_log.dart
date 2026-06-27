import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../models/shared_place.dart';

/// Console filter — search for this in Xcode / `flutter run` output.
const inboundLogFilter = '📍 SHARE';

/// Kind of inbound-share log line (emoji prefix after [SHARE]).
enum InboundLogKind {
  info('·'),
  deepLink('🔗'),
  native('📱'),
  parse('🔍'),
  route('🧭'),
  flow('✈️'),
  suppress('⏭️'),
  success('✅'),
  error('❌');

  const InboundLogKind(this.glyph);
  final String glyph;
}

/// Debug-only inbound share / deep link tracing.
///
/// Example line:
/// `📍 SHARE 🔗 │ Map deep link (redirect) → staged · Test · fallback=/plan`
///
/// Filter console with: `📍 SHARE` or `SHARE │` or `[triftly.share]`
void inboundDebugLog(
  String message, {
  InboundLogKind kind = InboundLogKind.info,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;

  final line = '$inboundLogFilter ${kind.glyph} │ $message';
  debugPrint(line);
  developer.log(
    line,
    name: 'triftly.share',
    error: error,
    stackTrace: stackTrace,
  );
}

/// Short summary for logs — avoids dumping full Maps URLs repeatedly.
String inboundPlaceSummary(SharedPlace place) {
  final name = place.nameLine ?? '(no name)';
  final coords = place.latitude != null && place.longitude != null
      ? ' @${place.latitude},${place.longitude}'
      : '';
  return '$name · ${truncateInbound(place.addressLine, 80)}$coords';
}

String truncateInbound(String value, [int max = 120]) {
  final trimmed = value.trim();
  if (trimmed.length <= max) return trimmed;
  return '${trimmed.substring(0, max)}…';
}
