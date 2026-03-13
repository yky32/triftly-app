part of 'map_view_bloc.dart';

abstract class MapViewEvent {}

class MapSearchQueryChanged extends MapViewEvent {
  final String query;

  MapSearchQueryChanged(this.query);
}

class MapSearchQuerySubmitted extends MapViewEvent {
  final String query;

  MapSearchQuerySubmitted(this.query);
}

class MapSearchCleared extends MapViewEvent {}

/// Notifies the bloc that the map has finished animating to search results.
class MapCameraFitted extends MapViewEvent {}

/// Request the map to focus (center) on a location and show detail; cleared after handling.
class MapFocusOnLocation extends MapViewEvent {
  final MapLocation location;

  MapFocusOnLocation(this.location);
}

/// Called after the map has focused on [focusOnLocation] so the bloc clears it.
class MapFocusHandled extends MapViewEvent {}
