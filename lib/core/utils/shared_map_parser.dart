import '../models/shared_place.dart';

/// Parses Google Maps / Apple Maps share URLs and companion text.
abstract final class SharedMapParser {
  static SharedPlace? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final url = _extractUrl(trimmed);
    if (url != null) {
      final fromUrl = _parseUrl(url);
      if (fromUrl != null) {
        return _mergeTextHints(trimmed, fromUrl, url);
      }
    }

    return SharedPlace(raw: trimmed, address: trimmed);
  }

  static String? _extractUrl(String text) {
    final match = RegExp(r'https?://[^\s\]]+', caseSensitive: false).firstMatch(text);
    return match?.group(0);
  }

  static SharedPlace? _parseUrl(String urlString) {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    final isMapsHost = host.contains('google') && host.contains('map') ||
        host == 'maps.app.goo.gl' ||
        host == 'goo.gl' ||
        host.contains('maps.apple.com');

    if (!isMapsHost && !urlString.contains('maps')) {
      return SharedPlace(raw: urlString, address: urlString);
    }

    final pathPlace = _placeFromPath(uri);
    final coords = _coordsFromUri(uri);
    final queryLabel = uri.queryParameters['q'] ?? uri.queryParameters['query'];

    String? name = pathPlace;
    String? address = urlString;

    if (name == null && queryLabel != null && !_looksLikeCoords(queryLabel)) {
      name = Uri.decodeComponent(queryLabel.replaceAll('+', ' '));
      address = name;
    }

    return SharedPlace(
      raw: urlString,
      name: name,
      address: address,
      latitude: coords?.$1,
      longitude: coords?.$2,
    );
  }

  static String? _placeFromPath(Uri uri) {
    final segments = uri.pathSegments;
    final placeIndex = segments.indexOf('place');
    if (placeIndex >= 0 && placeIndex + 1 < segments.length) {
      return segments[placeIndex + 1].replaceAll('+', ' ');
    }
    return null;
  }

  static (double, double)? _coordsFromUri(Uri uri) {
    final atMatch = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(uri.path);
    if (atMatch != null) {
      return (double.parse(atMatch.group(1)!), double.parse(atMatch.group(2)!));
    }

    final q = uri.queryParameters['q'];
    if (q != null && _looksLikeCoords(q)) {
      final parts = q.split(',');
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) return (lat, lng);
      }
    }
    return null;
  }

  static bool _looksLikeCoords(String value) {
    final parts = value.split(',');
    if (parts.length < 2) return false;
    return double.tryParse(parts[0].trim()) != null && double.tryParse(parts[1].trim()) != null;
  }

  static SharedPlace _mergeTextHints(String fullText, SharedPlace fromUrl, String url) {
    final withoutUrl = fullText.replaceAll(url, '').trim();
    final lines = withoutUrl
        .split(RegExp(r'[\n\r]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    var name = fromUrl.name;
    if (name == null && lines.isNotEmpty) {
      name = lines.first.replaceAll(RegExp(r'\s*·\s*.*$'), '').trim();
    }

    return SharedPlace(
      raw: fullText,
      name: name?.isNotEmpty == true ? name : fromUrl.name,
      address: fromUrl.address ?? url,
      latitude: fromUrl.latitude,
      longitude: fromUrl.longitude,
    );
  }
}
