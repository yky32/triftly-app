import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/features/4_map_view/bloc/map_view_bloc.dart';
import 'package:triftly/services/geocoding_service.dart';
import 'package:triftly/services/places_service.dart';
import 'package:triftly/features/4_map_view/models/map_location.dart';
import 'package:triftly/features/4_map_view/presentation/widgets/bottom_sheets/location_detail_bottom_sheet.dart';
import 'package:triftly/features/4_map_view/utils/location_from_tap.dart';

/// Approximate height of the floating bottom nav bar so the map content (e.g. my-location dot)
/// stays fully visible above it.
const double _kBottomNavBarHeight = 88;

/// Fallback center when location is unavailable (e.g. permission denied). Hong Kong.
const LatLng _fallbackCenter = LatLng(22.3193, 114.1694);

/// Map tab: full-screen Google Map with search bar. State is in [MapViewBloc]; UI is stateless.
/// When [onLocationPicked] is non-null, the page is in "pick mode" (e.g. pushed from add-spot sheet):
/// search bar is hidden, tap on map fetches location and shows a confirm card; "Use this location" calls the callback (caller typically pops with the location).
class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key, this.onLocationPicked, this.sharedLocation});

  /// If set, page is used for picking a location (tap map → confirm → callback with [MapLocation]).
  final void Function(MapLocation)? onLocationPicked;

  /// When set (e.g. from Share → Triftly from Google Maps), map centers here and shows location detail.
  final LatLng? sharedLocation;

  /// Pushes this page in pick mode and returns the selected [MapLocation] or null if dismissed.
  static Future<MapLocation?> pickLocation(BuildContext context) {
    return Navigator.of(context).push<MapLocation>(
      MaterialPageRoute(
        builder: (ctx) => MapViewPage(
          onLocationPicked: (loc) => Navigator.of(ctx).pop(loc),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapViewBloc(),
      child: _MapViewContent(
        onLocationPicked: onLocationPicked,
        sharedLocation: sharedLocation,
      ),
    );
  }
}

class _MapViewContent extends StatelessWidget {
  const _MapViewContent({this.onLocationPicked, this.sharedLocation});

  final void Function(MapLocation)? onLocationPicked;
  final LatLng? sharedLocation;

  bool get _isPickMode => onLocationPicked != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _isPickMode
          ? AppBar(
              title: const Text('Pick location'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Stack(
        children: [
          _MapBody(
            onLocationPicked: onLocationPicked,
            sharedLocation: sharedLocation,
          ),
          if (!_isPickMode)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surface,
                      child: const _SearchBar(),
                    ),
                    BlocBuilder<MapViewBloc, MapViewState>(
                      buildWhen: (prev, curr) =>
                          prev.isSearching != curr.isSearching ||
                          prev.locations != curr.locations ||
                          prev.searchQuery != curr.searchQuery,
                      builder: (context, state) {
                        if (state.isSearching) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 4, right: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Searching...',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state.searchQuery.isNotEmpty &&
                            state.locations.isNotEmpty) {
                          final count = state.locations.length;
                          final label =
                              count == 1 ? '1 result' : '$count results';
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, left: 4, right: 4),
                                child: Text(
                                  label,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 88,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  itemCount: state.locations.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final loc = state.locations[index];
                                    return _SearchResultChip(
                                      location: loc,
                                      onTap: () =>
                                          context.read<MapViewBloc>().add(
                                                MapFocusOnLocation(loc),
                                              ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        if (state.searchQuery.isNotEmpty &&
                            state.locations.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 4, right: 4),
                            child: Text(
                              'No results',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Search bar driven by [MapViewBloc]. Uses a [TextEditingController] synced with
/// [MapViewState.searchQuery] so that clearing the bloc clears the field.
class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<MapViewBloc, MapViewState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (context, state) {
        if (_controller.text != state.searchQuery) {
          _controller.text = state.searchQuery;
          _controller.selection =
              TextSelection.collapsed(offset: _controller.text.length);
        }
      },
      buildWhen: (prev, curr) =>
          prev.searchQuery != curr.searchQuery ||
          prev.isSearching != curr.isSearching,
      builder: (context, state) {
        return TextField(
          controller: _controller,
          onChanged: (value) =>
              context.read<MapViewBloc>().add(MapSearchQueryChanged(value)),
          onSubmitted: (query) =>
              context.read<MapViewBloc>().add(MapSearchQuerySubmitted(query)),
          decoration: InputDecoration(
            hintText: 'Search places or address',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            suffixIcon: state.isSearching
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                : state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            context.read<MapViewBloc>().add(MapSearchCleared()),
                      )
                    : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          textInputAction: TextInputAction.search,
        );
      },
    );
  }
}

/// Map type selector (Map / Satellite / Hybrid), similar to Google Maps layer control.
class _MapTypeSelector extends StatelessWidget {
  const _MapTypeSelector({required this.current, required this.onChanged});

  final MapType current;
  final void Function(MapType) onChanged;

  static const _options = [
    (MapType.normal, 'Map'),
    (MapType.satellite, 'Satellite'),
    (MapType.hybrid, 'Hybrid'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _options.map((option) {
            final (type, label) = option;
            final selected = current == type;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: selected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => onChanged(type),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Tappable search result chip (Google Maps–style horizontal list).
class _SearchResultChip extends StatelessWidget {
  const _SearchResultChip({required this.location, required this.onTap});

  final MapLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.place_outlined,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.address != null &&
                          location.address!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location.address!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Holds [GoogleMapController] and reacts to bloc state (camera fit, move to user location).
/// When [onLocationPicked] is non-null, tap fetches location and shows confirm card; "Use this location" calls the callback.
class _MapBody extends StatefulWidget {
  const _MapBody({this.onLocationPicked, this.sharedLocation});

  final void Function(MapLocation)? onLocationPicked;
  final LatLng? sharedLocation;

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  GoogleMapController? _mapController;
  bool _locationRequested = false;

  /// Exact position the user tapped; a pin is shown here so they see what they clicked.
  LatLng? _tappedPosition;

  /// In pick mode: location fetched after tap, shown in confirm card.
  MapLocation? _pickedLocation;
  bool _loading = false;
  bool _hasHandledSharedLocation = false;
  MapType _mapType = MapType.normal;

  Future<void> _handleSharedLocation(LatLng position) async {
    if (_hasHandledSharedLocation || widget.onLocationPicked != null) return;
    _hasHandledSharedLocation = true;
    if (!mounted) return;
    setState(() => _tappedPosition = position);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
    if (!mounted) return;
    final id = 'shared_${position.latitude}_${position.longitude}';
    final locationFuture = _fetchLocationForTap(id: id, position: position);
    // ignore: use_build_context_synchronously -- mounted checked above
    LocationDetailBottomSheet.showWithFuture(
      context,
      locationFuture: locationFuture,
    );
  }

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
    } on PlatformException {
      // Location service disabled or permission denied.
    } catch (_) {}
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
    return buildMapLocationFromTap(
      id: id,
      position: position,
      geocode: geocode,
      placeDetails: placeDetails,
    );
  }

  LatLngBounds _boundsFromLocations(List<MapLocation> list) {
    double minLat = list.first.position.latitude;
    double maxLat = minLat;
    double minLng = list.first.position.longitude;
    double maxLng = minLng;
    for (final loc in list) {
      minLat = math.min(minLat, loc.position.latitude);
      maxLat = math.max(maxLat, loc.position.latitude);
      minLng = math.min(minLng, loc.position.longitude);
      maxLng = math.max(maxLng, loc.position.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _onMapTap(LatLng position) async {
    final onPicked = widget.onLocationPicked;
    if (onPicked != null) {
      if (!mounted) return;
      setState(() {
        _tappedPosition = position;
        _pickedLocation = null;
        _loading = true;
      });
      final id = 'pick_${position.latitude}_${position.longitude}';
      final location = await _fetchLocationForTap(id: id, position: position);
      if (!mounted) return;
      setState(() {
        _pickedLocation = location;
        _loading = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
      return;
    }
    // Normal mode: show location detail sheet.
    if (!context.mounted) return;
    setState(() => _tappedPosition = position);
    final controller = _mapController;
    if (controller != null) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
    }
    if (!mounted) return;
    final id = 'tapped_${position.latitude}_${position.longitude}';
    final locationFuture = _fetchLocationForTap(id: id, position: position);
    // ignore: use_build_context_synchronously -- mounted checked above
    LocationDetailBottomSheet.showWithFuture(
      context,
      locationFuture: locationFuture,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final mapBottomPadding = bottomSafe + _kBottomNavBarHeight;
    final isPickMode = widget.onLocationPicked != null;

    return BlocConsumer<MapViewBloc, MapViewState>(
      listenWhen: (prev, curr) {
        if (curr.cameraShouldFitResults && curr.locations.isNotEmpty) {
          return true;
        }
        if (curr.focusOnLocation != prev.focusOnLocation &&
            curr.focusOnLocation != null) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.focusOnLocation != null) {
          final loc = state.focusOnLocation!;
          _mapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(loc.position, 16));
          LocationDetailBottomSheet.show(context, location: loc);
          context.read<MapViewBloc>().add(MapFocusHandled());
          return;
        }
        if (!state.cameraShouldFitResults || state.locations.isEmpty) return;
        final controller = _mapController;
        if (controller == null) return;
        if (state.locations.length == 1) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(state.locations.single.position, 14),
          );
        } else {
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLocations(state.locations),
              48,
            ),
          );
        }
        context.read<MapViewBloc>().add(MapCameraFitted());
      },
      buildWhen: (prev, curr) =>
          prev.locations != curr.locations ||
          prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        // Clear dropped pin when user searches so the map shows only search results (normal mode only).
        if (!isPickMode &&
            state.searchQuery.isNotEmpty &&
            _tappedPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _tappedPosition = null);
          });
        }
        final markers = <String, Marker>{
          if (!isPickMode)
            for (final loc in state.locations)
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
        // Pin at exact tap position so the user sees what they clicked.
        if (_tappedPosition != null) {
          markers['_dropped_pin'] = Marker(
            markerId: const MarkerId('_dropped_pin'),
            position: _tappedPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            infoWindow: const InfoWindow(
                title: 'Selected location', snippet: 'Tap elsewhere to move'),
            zIndexInt: 1,
          );
        }

        final initialTarget = widget.sharedLocation ?? _fallbackCenter;
        final mapWidget = GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: widget.sharedLocation != null ? 17 : 15,
          ),
          mapType: _mapType,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          padding: EdgeInsets.only(
            bottom: mapBottomPadding +
                (isPickMode && _pickedLocation != null ? 200 : 0),
            right: 16,
          ),
          markers: Set<Marker>.from(markers.values),
          onTap: _onMapTap,
          onMapCreated: (controller) {
            _mapController = controller;
            final shared = widget.sharedLocation;
            if (shared != null) {
              _handleSharedLocation(shared);
            } else {
              _moveToUserLocation();
            }
          },
        );

        return Stack(
          children: [
            mapWidget,
            if (!isPickMode)
              Positioned(
                left: 16,
                bottom: mapBottomPadding + 8,
                child: _MapTypeSelector(
                  current: _mapType,
                  onChanged: (type) => setState(() => _mapType = type),
                ),
              ),
            if (isPickMode && _loading)
              const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Getting address…'),
                      ],
                    ),
                  ),
                ),
              ),
            if (_pickedLocation != null && !_loading)
              Positioned(
                left: 16,
                right: 16,
                bottom: bottomSafe + 16,
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _pickedLocation!.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (_pickedLocation!.address != null &&
                            _pickedLocation!.address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _pickedLocation!.address!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => setState(() {
                                _pickedLocation = null;
                                _tappedPosition = null;
                              }),
                              child: const Text('Choose another'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () =>
                                  widget.onLocationPicked!(_pickedLocation!),
                              child: const Text('Use this location'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
