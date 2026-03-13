import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Result of parsing a Google Maps share URL (from native Share sheet).
class GoogleMapsShareResult {
  const GoogleMapsShareResult({required this.position, this.placeName});

  final LatLng position;
  final String? placeName;
}

/// Parses URLs shared from the Google Maps app (Share → Triftly).
/// Supports common formats so we can show the location in [MapViewPage].
///
/// Supported patterns:
/// - `?q=lat,lng` or `?q=lat,lng,zoom`
/// - `?query=lat,lng`
/// - `/@lat,lng,zoom` (e.g. .../maps/@22.3193,114.1694,17z)
/// - `/place/.../@lat,lng,zoom`
/// - Text that is only "lat,lng" or "lat, lng"
class GoogleMapsShareParser {
  GoogleMapsShareParser._();

  static final RegExp _latLngOnly = RegExp(
    r'^\s*(-?\d{1,3}\.?\d*)\s*[,，]\s*(-?\d{1,3}\.?\d*)\s*$',
  );
  static final RegExp _qParam = RegExp(
    r'[?&]q=([^&]+)',
    caseSensitive: false,
  );
  static final RegExp _queryParam = RegExp(
    r'[?&]query=([^&]+)',
    caseSensitive: false,
  );
  static final RegExp _atCoords = RegExp(
    r'/@(-?\d{1,3}\.?\d*),(-?\d{1,3}\.?\d*)(?:,\d+z?)?',
  );
  static final RegExp _latLngPair = RegExp(
    r'(-?\d{1,3}\.?\d*)\s*[,，]\s*(-?\d{1,3}\.?\d*)',
  );

  /// Returns a [GoogleMapsShareResult] if the [urlOrText] contains parseable coordinates, otherwise null.
  static GoogleMapsShareResult? parse(String? urlOrText) {
    if (urlOrText == null || urlOrText.trim().isEmpty) return null;
    final s = urlOrText.trim();

    // Plain "lat,lng" text
    final onlyMatch = _latLngOnly.firstMatch(s);
    if (onlyMatch != null) {
      final lat = double.tryParse(onlyMatch.group(1)!);
      final lng = double.tryParse(onlyMatch.group(2)!);
      if (lat != null && lng != null && _isValidLatLng(lat, lng)) {
        return GoogleMapsShareResult(position: LatLng(lat, lng));
      }
    }

    // URL: ?q=lat,lng or ?q=place+name+lat,lng (we try to extract last lat,lng)
    final qMatch = _qParam.firstMatch(s);
    if (qMatch != null) {
      final decoded =
          Uri.decodeComponent(qMatch.group(1)!.replaceAll('+', ' '));
      final result = _parseLatLngFromQuery(decoded);
      if (result != null) return result;
    }

    // URL: ?query=lat,lng
    final queryMatch = _queryParam.firstMatch(s);
    if (queryMatch != null) {
      final decoded =
          Uri.decodeComponent(queryMatch.group(1)!.replaceAll('+', ' '));
      final result = _parseLatLngFromQuery(decoded);
      if (result != null) return result;
    }

    // URL: /@lat,lng,zoom
    final atMatch = _atCoords.firstMatch(s);
    if (atMatch != null) {
      final lat = double.tryParse(atMatch.group(1)!);
      final lng = double.tryParse(atMatch.group(2)!);
      if (lat != null && lng != null && _isValidLatLng(lat, lng)) {
        return GoogleMapsShareResult(position: LatLng(lat, lng));
      }
    }

    // Fallback: any lat,lng pair in the string (e.g. in place URLs)
    final pairMatch = _latLngPair.firstMatch(s);
    if (pairMatch != null) {
      final lat = double.tryParse(pairMatch.group(1)!);
      final lng = double.tryParse(pairMatch.group(2)!);
      if (lat != null && lng != null && _isValidLatLng(lat, lng)) {
        return GoogleMapsShareResult(position: LatLng(lat, lng));
      }
    }

    return null;
  }

  static bool _isValidLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  static GoogleMapsShareResult? _parseLatLngFromQuery(String decoded) {
    // Try "lat,lng" or "lat,lng,zoom" or "Place Name lat,lng"
    final pair = _latLngPair.firstMatch(decoded);
    if (pair != null) {
      final lat = double.tryParse(pair.group(1)!);
      final lng = double.tryParse(pair.group(2)!);
      if (lat != null && lng != null && _isValidLatLng(lat, lng)) {
        final before = decoded.substring(0, pair.start).trim();
        final placeName = before.isNotEmpty ? before : null;
        return GoogleMapsShareResult(
          position: LatLng(lat, lng),
          placeName: placeName,
        );
      }
    }
    return null;
  }
}
