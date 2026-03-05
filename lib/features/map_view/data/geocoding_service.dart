import 'package:dio/dio.dart';
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

/// Calls Google Geocoding API (reverse) to get address and place_id from LatLng.
/// Enable "Geocoding API" in Google Cloud Console for the same project as Maps.
/// Set GOOGLE_MAPS_API_KEY in env (e.g. env/.env.dev) — can use same key as Maps.
class GeocodingService {
  GeocodingService._();

  static const _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  static String? get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'];

  /// Reverse geocode [latitude], [longitude]. Returns null if key missing or request fails.
  static Future<ReverseGeocodeResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) return null;

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
      if (response.statusCode != 200) return null;

      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK') return null;

      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final formattedAddress = first['formatted_address'] as String? ?? '';
      final placeId = first['place_id'] as String?;
      final types = (first['types'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      String? locality;
      final components = first['address_components'] as List<dynamic>?;
      if (components != null) {
        for (final c in components) {
          final map = c as Map<String, dynamic>;
          final typesList = map['types'] as List<dynamic>?;
          if (typesList != null &&
              (typesList.contains('locality') ||
                  typesList.contains('administrative_area_level_1'))) {
            locality = map['long_name'] as String?;
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
    } catch (_) {
      return null;
    }
  }
}
