import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/features/4_map_view/models/map_location.dart';
import 'package:triftly/services/geocoding_service.dart';
import 'package:triftly/services/places_service.dart';

/// Builds a [MapLocation] from a map tap using reverse geocode and optional place details.
/// Shared by [MapViewPage] (tap to show detail, and pick mode for routine).
MapLocation buildMapLocationFromTap({
  required String id,
  required LatLng position,
  ReverseGeocodeResult? geocode,
  PlaceDetailsResult? placeDetails,
}) {
  final title = placeDetails?.name ??
      geocode?.locality ??
      geocode?.formattedAddress ??
      'Dropped pin';
  final address = placeDetails?.formattedAddress ?? geocode?.formattedAddress;
  final placeId = geocode?.placeId;
  final locality = geocode?.locality;
  final types = placeDetails?.types ?? geocode?.types;
  final rating = placeDetails?.rating;
  final openingHoursText = placeDetails?.openingHoursSummary;
  final photoUrl = placeDetails?.photoReference != null
      ? PlacesService.photoUrl(placeDetails!.photoReference!)
      : null;
  final website = placeDetails?.website;
  final phoneNumber = placeDetails?.formattedPhoneNumber;

  return MapLocation(
    id: id,
    title: title,
    address: address,
    position: position,
    placeId: placeId,
    locality: locality,
    types: types,
    rating: rating,
    openingHoursText: openingHoursText,
    photoUrl: photoUrl,
    website: website,
    phoneNumber: phoneNumber,
  );
}
