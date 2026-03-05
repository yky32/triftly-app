import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A point of interest / location that can be shown on the map and in the location-detail bottom sheet.
class MapLocation {
  const MapLocation({
    required this.id,
    required this.title,
    this.description,
    this.address,
    required this.position,
  });

  final String id;
  final String title;
  final String? description;
  final String? address;
  final LatLng position;

  LatLng get latLng => position;
}
