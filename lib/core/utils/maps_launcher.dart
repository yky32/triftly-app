import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import '../models/trip_models.dart';

/// Opens a spot in the platform maps app.
abstract final class MapsLauncher {
  static Future<bool> openSpot(Spot spot) async {
    final lat = spot.latitude;
    final lng = spot.longitude;
    if (lat != null && lng != null) {
      return _tryLaunch(_pinUrl(lat, lng, spot.name));
    }

    final query = spot.address ?? spot.name;
    if (query.isEmpty) return false;
    return _tryLaunch(_searchUrl(query));
  }

  static Uri _pinUrl(double lat, double lng, String label) {
    final encoded = Uri.encodeComponent(label);
    if (Platform.isIOS) {
      return Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$encoded');
    }
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  }

  static Uri _searchUrl(String query) {
    final encoded = Uri.encodeComponent(query);
    if (Platform.isIOS) {
      return Uri.parse('https://maps.apple.com/?q=$encoded');
    }
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
