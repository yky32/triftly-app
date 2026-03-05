import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/features/map_view/data/geocoding_service.dart';
import 'package:triftly/features/map_view/data/places_service.dart';
import 'package:triftly/features/map_view/models/map_location.dart';
import 'package:triftly/features/map_view/presentation/widgets/bottom_sheets/location_detail_bottom_sheet.dart';

/// Approximate height of the floating bottom nav bar so the map content (e.g. my-location dot)
/// stays fully visible above it.
const double _kBottomNavBarHeight = 88;

/// Fallback center when location is unavailable (e.g. permission denied). Hong Kong.
const LatLng _fallbackCenter = LatLng(22.3193, 114.1694);

/// Sample map locations (POIs) for the simple map. Tap a marker to open its detail bottom sheet.
final List<MapLocation> _sampleLocations = [
  const MapLocation(
    id: 'sensoji',
    title: 'Sensō-ji',
    description:
        'Ancient Buddhist temple in Asakusa, Tokyo. The oldest temple in Tokyo.',
    address: '2 Chome-3-1 Asakusa, Taitō City, Tokyo',
    position: LatLng(35.7148, 139.7967),
  ),
  const MapLocation(
    id: 'shibuya',
    title: 'Shibuya Crossing',
    description: 'Famous scramble crossing and commercial district.',
    address: 'Shibuya City, Tokyo',
    position: LatLng(35.6595, 139.7004),
  ),
  const MapLocation(
    id: 'skytree',
    title: 'Tokyo Skytree',
    description: 'Tall broadcasting and observation tower in Sumida.',
    address: '1 Chome-1-2 Oshiage, Sumida City, Tokyo',
    position: LatLng(35.7101, 139.8107),
  ),
];

/// Map tab: full-screen Google Map. Centers on your current location when available.
/// Tap any marker to see location details in a bottom sheet.
class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  GoogleMapController? _mapController;
  bool _locationRequested = false;

  Future<void> _moveToUserLocation() async {
    if (_locationRequested || !mounted) return;
    _locationRequested = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted || _mapController == null) return;
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    } on MissingPluginException {
      // Native geolocator plugin not registered (e.g. after hot restart).
      // Do a full stop and run to get location. Map stays at fallback center.
    } on PlatformException {
      // Location service disabled or permission denied. Map stays at fallback.
    } catch (_) {
      // Any other error. Map stays at fallback center (Hong Kong).
    }
  }

  Future<MapLocation> _fetchLocationForTap({
    required String id,
    required LatLng position,
  }) async {
    final geocode = await GeocodingService.reverseGeocode(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    PlaceDetailsResult? placeDetails;
    if (geocode?.placeId != null) {
      placeDetails = await PlacesService.getPlaceDetails(geocode!.placeId!);
    }
    return _buildMapLocationFromTap(
      id: id,
      position: position,
      geocode: geocode,
      placeDetails: placeDetails,
    );
  }

  MapLocation _buildMapLocationFromTap({
    required String id,
    required LatLng position,
    ReverseGeocodeResult? geocode,
    PlaceDetailsResult? placeDetails,
  }) {
    final title = placeDetails?.name ??
        geocode?.locality ??
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

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final mapBottomPadding = bottomSafe + _kBottomNavBarHeight;

    final markers = {
      for (final loc in _sampleLocations)
        loc.id: Marker(
          markerId: MarkerId(loc.id),
          position: loc.position,
          infoWindow: InfoWindow(title: loc.title, snippet: loc.address),
          onTap: () {
            if (context.mounted) {
              LocationDetailBottomSheet.show(context, location: loc);
            }
          },
        ),
    };

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _fallbackCenter,
              zoom: 12,
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            padding: EdgeInsets.only(bottom: mapBottomPadding, right: 16),
            markers: Set<Marker>.from(markers.values),
            onTap: (LatLng position) {
              if (!context.mounted) return;
              final id = 'tapped_${position.latitude}_${position.longitude}';
              final locationFuture = _fetchLocationForTap(id: id, position: position);
              LocationDetailBottomSheet.showWithFuture(context, locationFuture: locationFuture);
            },
            onMapCreated: (controller) {
              _mapController = controller;
              _moveToUserLocation();
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                context.l10n.page_map,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
