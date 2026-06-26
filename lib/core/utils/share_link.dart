import '../models/trip_models.dart';

/// Public trip share URLs (universal links target this path).
abstract final class ShareLink {
  static const baseHost = 'https://triftly.app';

  static String forTrip(Trip trip) {
    final token = trip.shareToken ?? trip.id;
    return '$baseHost/s/$token';
  }

  static String? tokenFromUri(Uri? uri) {
    if (uri == null) return null;

    if (uri.scheme == 'triftly' && uri.host == 's' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    final host = uri.host.toLowerCase();
    if (host == 'triftly.app' || host.endsWith('.triftly.app')) {
      if (uri.pathSegments.length == 2 && uri.pathSegments.first == 's') {
        return uri.pathSegments[1];
      }
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 's') {
      return uri.pathSegments[1];
    }

    return null;
  }
}
