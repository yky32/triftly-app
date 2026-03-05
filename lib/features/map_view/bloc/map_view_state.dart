part of 'map_view_bloc.dart';

class MapViewState {
  const MapViewState({
    required this.locations,
    this.isSearching = false,
    this.searchQuery = '',
    this.cameraShouldFitResults = false,
  });

  final List<MapLocation> locations;
  final bool isSearching;
  final String searchQuery;
  final bool cameraShouldFitResults;

  MapViewState copyWith({
    List<MapLocation>? locations,
    bool? isSearching,
    String? searchQuery,
    bool? cameraShouldFitResults,
  }) {
    return MapViewState(
      locations: locations ?? this.locations,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      cameraShouldFitResults: cameraShouldFitResults ?? this.cameraShouldFitResults,
    );
  }
}
