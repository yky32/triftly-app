part of 'routine_builder_bloc.dart';

abstract class RoutineBuilderEvent {}

class TripSelected extends RoutineBuilderEvent {
  final RoutineTripResult trip;

  TripSelected(this.trip);
}

class TripCleared extends RoutineBuilderEvent {}

class CarouselPageChanged extends RoutineBuilderEvent {
  final int index;

  CarouselPageChanged(this.index);
}

class SpotAdded extends RoutineBuilderEvent {
  final int dayIndex;
  final RoutineSpot spot;

  SpotAdded({required this.dayIndex, required this.spot});
}

/// Replace an existing spot at [spotIndex] in the day's added list.
class SpotUpdated extends RoutineBuilderEvent {
  final int dayIndex;
  final int spotIndex;
  final RoutineSpot spot;

  SpotUpdated({
    required this.dayIndex,
    required this.spotIndex,
    required this.spot,
  });
}

/// After the add-spot sheet (opened for [pendingSpotToAddFromMap]) is closed.
class PendingSpotFromMapConsumed extends RoutineBuilderEvent {}
