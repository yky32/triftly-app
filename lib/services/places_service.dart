import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Place details from Google Places API (Place Details). Used to enrich [MapLocation].
class PlaceDetailsResult {
  const PlaceDetailsResult({
    this.name,
    this.formattedAddress,
    this.rating,
    this.types,
    this.weekdayText,
    this.photoReference,
    this.website,
    this.formattedPhoneNumber,
  });

  final String? name;
  final String? formattedAddress;
  final double? rating;
  final List<String>? types;
  final List<String>? weekdayText;
  final String? photoReference;
  final String? website;
  final String? formattedPhoneNumber;

  /// Build a single-line opening hours summary (e.g. "Open · Closes 9 PM" or weekday list).
  String? get openingHoursSummary {
    if (weekdayText == null || weekdayText!.isEmpty) return null;
    return weekdayText!.join('  ·  ');
  }
}

/// Calls Google Places API (Place Details) to get rating, opening hours, photo, website, phone.
/// Enable "Places API" in Google Cloud Console. Uses same key as Maps/Geocoding.
class PlacesService {
  PlacesService._();

  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const _photoBaseUrl =
      'https://maps.googleapis.com/maps/api/place/photo';

  static String? get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'];

  /// Fetch place details by [placeId]. Returns null if key missing or request fails.
  static Future<PlaceDetailsResult?> getPlaceDetails(String placeId) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            '[PlacesService] getPlaceDetails: GOOGLE_MAPS_API_KEY missing or empty.');
      }
      return null;
    }

    final uri = Uri.parse(_detailsUrl).replace(
      queryParameters: {
        'place_id': placeId,
        'fields':
            'name,formatted_address,rating,opening_hours,photos,website,formatted_phone_number,types',
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
              '[PlacesService] getPlaceDetails: HTTP ${response.statusCode}');
        }
        return null;
      }

      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK') {
        if (kDebugMode) {
          final errorMessage = json['error_message'] as String?;
          debugPrint(
              '[PlacesService] getPlaceDetails: status=$status error_message=$errorMessage. '
              'Ensure Places API is enabled and API key allows this app (iOS bundle ID / Android package).');
        }
        return null;
      }

      final result = json['result'] as Map<String, dynamic>?;
      if (result == null) return null;

      final name = result['name'] as String?;
      final formattedAddress = result['formatted_address'] as String?;
      final rating = (result['rating'] as num?)?.toDouble();
      final types = (result['types'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      List<String>? weekdayText;
      final openingHours = result['opening_hours'] as Map<String, dynamic>?;
      if (openingHours != null) {
        weekdayText = (openingHours['weekday_text'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
      }

      String? photoReference;
      final photos = result['photos'] as List<dynamic>?;
      if (photos != null && photos.isNotEmpty) {
        final first = photos.first as Map<String, dynamic>?;
        photoReference = first?['photo_reference'] as String?;
      }

      final website = result['website'] as String?;
      final formattedPhoneNumber = result['formatted_phone_number'] as String?;

      return PlaceDetailsResult(
        name: name,
        formattedAddress: formattedAddress,
        rating: rating,
        types: types,
        weekdayText: weekdayText,
        photoReference: photoReference,
        website: website,
        formattedPhoneNumber: formattedPhoneNumber,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PlacesService] getPlaceDetails exception: $e');
        debugPrint('[PlacesService] $st');
      }
      return null;
    }
  }

  /// Build a direct photo URL for the place photo. Use in Image.network().
  static String? photoUrl(String photoReference, {int maxWidth = 400}) {
    final key = _apiKey;
    if (key == null || key.isEmpty) return null;
    return '$_photoBaseUrl?maxwidth=$maxWidth&photo_reference=$photoReference&key=$key';
  }
}
