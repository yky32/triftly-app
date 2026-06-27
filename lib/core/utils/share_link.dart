import '../models/trip_models.dart';

/// Public trip share URLs (universal links target this path).
abstract final class ShareLink {
  static const baseHost = 'https://triftly.app';

  static String forTrip(Trip trip) {
    final token = trip.shareToken ?? trip.id;
    return '$baseHost/s/$token';
  }

  /// Play Store listing for buddies without the app installed.
  static const androidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.triftly';

  /// App Store listing — set [iosAppStoreId] when the public listing is live.
  static const iosAppStoreId = String.fromEnvironment('IOS_APP_STORE_ID');

  static String get iosAppStoreUrl => iosAppStoreId.isEmpty
      ? 'https://apps.apple.com/us/search?term=triftly'
      : 'https://apps.apple.com/app/id$iosAppStoreId';

  static String storeUrlForUserAgent(String userAgent) {
    final ua = userAgent.toLowerCase();
    if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod')) {
      return iosAppStoreUrl;
    }
    if (ua.contains('android')) {
      return androidPlayStoreUrl;
    }
    return baseHost;
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
