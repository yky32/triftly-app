import '../models/shared_place.dart';
import '../navigation/shared_place_flow.dart';
import '../share/inbound_debug_log.dart';
import '../utils/shared_map_parser.dart';

/// Handles `triftly://map?url=…` deep links (simulator, share extension).
abstract final class SharedMapRedirect {
  static bool isMapInbound(Uri uri) => uri.scheme == 'triftly' && uri.host == 'map';

  /// Stages shared place for [SharedPlaceListener] when not suppressed.
  /// Always returns [fallbackPath] — listener owns trip pick + navigation.
  static String redirectPath(Uri uri, {required String fallbackPath}) {
    final payload = uri.queryParameters['url']?.trim();
    if (payload == null || payload.isEmpty) {
      inboundDebugLog(
        'Map deep link (router) — missing url param → fallback=$fallbackPath',
        kind: InboundLogKind.deepLink,
      );
      return fallbackPath;
    }

    if (SharedPlaceFlow.shouldSuppress(payload)) {
      inboundDebugLog(
        'Map deep link (router) — duplicate suppressed → fallback=$fallbackPath · '
        '${truncateInbound(payload)}',
        kind: InboundLogKind.suppress,
      );
      return fallbackPath;
    }

    final place =
        SharedMapParser.parse(payload) ?? SharedPlace(raw: payload, address: payload);
    SharedPlaceFlow.stage(place);
    inboundDebugLog(
      'Map deep link (router) — staged → ${inboundPlaceSummary(place)} · fallback=$fallbackPath',
      kind: InboundLogKind.deepLink,
    );
    return fallbackPath;
  }

  /// Used from go_router redirect / errorBuilder.
  static String? redirectFromRouter(Uri uri, {required String fallbackPath}) {
    if (!isMapInbound(uri)) return null;
    return redirectPath(uri, fallbackPath: fallbackPath);
  }
}
