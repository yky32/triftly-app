import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A point of interest / location for the map and location-detail bottom sheet.
/// Supports data from our markers, from Geocoding (address), and later from Places API
/// (rating, opening hours, photo, etc.) so users get enough info to browse and add to routine.
class MapLocation {
  const MapLocation({
    required this.id,
    required this.title,
    this.description,
    this.address,
    required this.position,
    this.placeId,
    this.rating,
    this.types,
    this.openingHoursText,
    this.photoUrl,
    this.website,
    this.phoneNumber,
    this.locality,
  });

  final String id;
  final String title;
  final String? description;
  final String? address;
  final LatLng position;

  /// Google Place ID — use for Place Details API later (e.g. when adding to routine_builder).
  final String? placeId;

  /// 1–5 rating from Places (when available).
  final double? rating;

  /// Place types (e.g. restaurant, tourist_attraction). From Geocoding or Places.
  final List<String>? types;

  /// Human-readable opening hours (e.g. "Open until 9 PM").
  final String? openingHoursText;

  /// Photo URL for the place (when available from Places).
  final String? photoUrl;

  final String? website;
  final String? phoneNumber;

  /// Short locality label (e.g. "Shibuya, Tokyo") from Geocoding.
  final String? locality;

  LatLng get latLng => position;

  MapLocation copyWith({
    String? id,
    String? title,
    String? description,
    String? address,
    LatLng? position,
    String? placeId,
    double? rating,
    List<String>? types,
    String? openingHoursText,
    String? photoUrl,
    String? website,
    String? phoneNumber,
    String? locality,
  }) {
    return MapLocation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      position: position ?? this.position,
      placeId: placeId ?? this.placeId,
      rating: rating ?? this.rating,
      types: types ?? this.types,
      openingHoursText: openingHoursText ?? this.openingHoursText,
      photoUrl: photoUrl ?? this.photoUrl,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      locality: locality ?? this.locality,
    );
  }
}
