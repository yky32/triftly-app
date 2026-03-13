import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Result of reverse geocoding: formatted address, place ID, and optional locality.
class ReverseGeocodeResult {
  const ReverseGeocodeResult({
    required this.formattedAddress,
    this.placeId,
    this.locality,
    this.types,
  });

  final String formattedAddress;
  final String? placeId;
  final String? locality;
  final List<String>? types;
}

/// One result from forward geocoding (address/place name → coordinates).
class ForwardGeocodeResult {
  const ForwardGeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.placeId,
    this.locality,
    this.types,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? placeId;
  final String? locality;
  final List<String>? types;
}

/// Calls Google Geocoding API (reverse) to get address and place_id from LatLng.
/// Enable "Geocoding API" in Google Cloud Console for the same project as Maps.
/// Set GOOGLE_MAPS_API_KEY in env (e.g. env/.env.dev) — can use same key as Maps.
class GeocodingService {
  GeocodingService._();

  static const _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  static String? get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'];

  /// Place types that represent "famous" or notable destinations (prioritized first).
  static const _famousTypes = {
    'tourist_attraction',
    'museum',
    'art_gallery',
    'restaurant',
    'cafe',
    'bar',
    'store',
    'shopping_mall',
    'lodging',
    'park',
    'stadium',
    'aquarium',
    'zoo',
  };

  /// Score for ordering: 2 = famous POI, 1 = other POI, 0 = address-only.
  static int _scoreResult(Map<String, dynamic> result) {
    final types = result['types'] as List<dynamic>?;
    if (types == null || types.isEmpty) return 0;
    final typeSet = types.map((e) => e.toString()).toSet();
    final hasFamous = typeSet.any((t) => _famousTypes.contains(t));
    final hasPoi = typeSet.contains('establishment') ||
        typeSet.contains('point_of_interest');
    if (hasFamous) return 2;
    if (hasPoi) return 1;
    return 0;
  }

  /// Sort geocode results so POIs come first, famous places first among POIs.
  static List<Map<String, dynamic>> _sortResultsPoiFirst(
      List<dynamic> results) {
    final list = results.map((e) => e as Map<String, dynamic>).toList();
    list.sort((a, b) => _scoreResult(b).compareTo(_scoreResult(a)));
    return list;
  }

  /// Reverse geocode [latitude], [longitude]. Returns null if key missing or request fails.
  static Future<ReverseGeocodeResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            '[GeocodingService] reverseGeocode: GOOGLE_MAPS_API_KEY missing or empty. '
            'Check env file is loaded (Environment.load) and key is set for this build (ENV=dev/stag/prod).');
      }
      return null;
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latlng': '$latitude,$longitude',
        'key': key,
      },
    );

    try {
      final response = await Dio().getUri(uri).timeout(
            const Duration(seconds: 5),
          );
      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
              '[GeocodingService] reverseGeocode: HTTP ${response.statusCode}');
        }
        return null;
      }

      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK') {
        if (kDebugMode) {
          final errorMessage = json['error_message'] as String?;
          debugPrint(
              '[GeocodingService] reverseGeocode: status=$status error_message=$errorMessage. '
              'On real device: ensure Geocoding API is enabled and API key has no app restriction blocking this app (iOS bundle ID / Android package name).');
        }
        return null;
      }

      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      // POI first, famous places first (tourist_attraction, museum, restaurant, etc.).
      final sorted = _sortResultsPoiFirst(results);
      final chosen = sorted.first;

      final formattedAddress = chosen['formatted_address'] as String? ?? '';
      final placeId = chosen['place_id'] as String?;
      final types = (chosen['types'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      String? locality;
      final components = chosen['address_components'] as List<dynamic>?;
      if (components != null) {
        for (final c in components) {
          final comp = c as Map<String, dynamic>;
          final typesList = comp['types'] as List<dynamic>?;
          if (typesList != null &&
              (typesList.contains('locality') ||
                  typesList.contains('administrative_area_level_1'))) {
            locality = comp['long_name'] as String?;
            break;
          }
        }
      }

      return ReverseGeocodeResult(
        formattedAddress: formattedAddress,
        placeId: placeId,
        locality: locality,
        types: types,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[GeocodingService] reverseGeocode exception: $e');
        debugPrint('[GeocodingService] $st');
      }
      return null;
    }
  }

  /// Forward geocode: [query] (address or place name) → list of candidates with coordinates.
  /// Returns empty list if key missing or request fails.
  static Future<List<ForwardGeocodeResult>> forwardGeocode(String query) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) return [];

    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'address': trimmed,
        'key': key,
      },
    );

    try {
      final response = await Dio().getUri(uri).timeout(
            const Duration(seconds: 5),
          );
      if (response.statusCode != 200) return [];

      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') return [];

      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return [];

      // POI first, famous places first so map shows notable places before generic addresses.
      final sorted = _sortResultsPoiFirst(results);

      final list = <ForwardGeocodeResult>[];
      for (final map in sorted) {
        final geometry = map['geometry'] as Map<String, dynamic>?;
        final location = geometry?['location'] as Map<String, dynamic>?;
        if (location == null) continue;
        final lat = (location['lat'] as num?)?.toDouble();
        final lng = (location['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final formattedAddress = map['formatted_address'] as String? ?? '';
        final placeId = map['place_id'] as String?;
        final types =
            (map['types'] as List<dynamic>?)?.map((e) => e.toString()).toList();

        String? locality;
        final components = map['address_components'] as List<dynamic>?;
        if (components != null) {
          for (final c in components) {
            final comp = c as Map<String, dynamic>;
            final typesList = comp['types'] as List<dynamic>?;
            if (typesList != null &&
                (typesList.contains('locality') ||
                    typesList.contains('administrative_area_level_1'))) {
              locality = comp['long_name'] as String?;
              break;
            }
          }
        }

        list.add(ForwardGeocodeResult(
          latitude: lat,
          longitude: lng,
          formattedAddress: formattedAddress,
          placeId: placeId,
          locality: locality,
          types: types,
        ));
      }
      return list;
    } catch (_) {
      return [];
    }
  }
}
