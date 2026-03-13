import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/services/geocoding_service.dart';
import 'package:triftly/features/4_map_view/models/map_location.dart';

part 'map_view_event.dart';
part 'map_view_state.dart';

/// Default POIs shown when no search is active.
final List<MapLocation> _sampleLocationsList = [
  MapLocation(
    id: 'sensoji',
    title: 'Sensō-ji',
    description:
        'Ancient Buddhist temple in Asakusa, Tokyo. The oldest temple in Tokyo.',
    address: '2 Chome-3-1 Asakusa, Taitō City, Tokyo',
    position: LatLng(35.7148, 139.7967),
  ),
  MapLocation(
    id: 'shibuya',
    title: 'Shibuya Crossing',
    description: 'Famous scramble crossing and commercial district.',
    address: 'Shibuya City, Tokyo',
    position: LatLng(35.6595, 139.7004),
  ),
  MapLocation(
    id: 'skytree',
    title: 'Tokyo Skytree',
    description: 'Tall broadcasting and observation tower in Sumida.',
    address: '1 Chome-1-2 Oshiage, Sumida City, Tokyo',
    position: LatLng(35.7101, 139.8107),
  ),
];

class MapViewBloc extends Bloc<MapViewEvent, MapViewState> {
  MapViewBloc() : super(MapViewState(locations: _sampleLocationsList)) {
    on<MapSearchQueryChanged>(_onSearchQueryChanged);
    on<MapSearchQuerySubmitted>(_onSearchQuerySubmitted);
    on<MapSearchCleared>(_onSearchCleared);
    on<MapCameraFitted>(_onCameraFitted);
  }

  void _onSearchQueryChanged(
      MapSearchQueryChanged event, Emitter<MapViewState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onSearchQuerySubmitted(
    MapSearchQuerySubmitted event,
    Emitter<MapViewState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    emit(state.copyWith(isSearching: true));
    final results = await GeocodingService.forwardGeocode(query);
    final locations = results.asMap().entries.map((e) {
      final r = e.value;
      return MapLocation(
        id: 'search_${e.key}_${r.placeId ?? r.latitude}',
        title: r.locality ?? r.formattedAddress,
        address: r.formattedAddress,
        position: LatLng(r.latitude, r.longitude),
        placeId: r.placeId,
        locality: r.locality,
        types: r.types,
      );
    }).toList();

    emit(state.copyWith(
      locations: locations.isEmpty ? _sampleLocationsList : locations,
      isSearching: false,
      searchQuery: query,
      cameraShouldFitResults: locations.isNotEmpty,
    ));
  }

  void _onSearchCleared(MapSearchCleared event, Emitter<MapViewState> emit) {
    emit(MapViewState(locations: _sampleLocationsList));
  }

  void _onCameraFitted(MapCameraFitted event, Emitter<MapViewState> emit) {
    emit(state.copyWith(cameraShouldFitResults: false));
  }
}
