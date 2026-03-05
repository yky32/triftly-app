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
