part of 'map_view_bloc.dart';

class MapViewState {
  const MapViewState({
    required this.locations,
    this.isSearching = false,
    this.searchQuery = '',
    this.cameraShouldFitResults = false,
    this.focusOnLocation,
  });

  final List<MapLocation> locations;
  final bool isSearching;
  final String searchQuery;
  final bool cameraShouldFitResults;

  /// When set, map should center on this location and show detail sheet (then clear).
  final MapLocation? focusOnLocation;

  MapViewState copyWith({
    List<MapLocation>? locations,
    bool? isSearching,
    String? searchQuery,
    bool? cameraShouldFitResults,
    MapLocation? focusOnLocation,
    bool clearFocusOnLocation = false,
  }) {
    return MapViewState(
      locations: locations ?? this.locations,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      cameraShouldFitResults:
          cameraShouldFitResults ?? this.cameraShouldFitResults,
      focusOnLocation: clearFocusOnLocation
          ? null
          : (focusOnLocation ?? this.focusOnLocation),
    );
  }
}
