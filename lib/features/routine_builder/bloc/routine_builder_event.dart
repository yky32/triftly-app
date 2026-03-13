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

/// Remove the spot at [spotIndex] for the day (e.g. after long-press and confirm).
class SpotRemoved extends RoutineBuilderEvent {
  final int dayIndex;
  final int spotIndex;

  SpotRemoved({required this.dayIndex, required this.spotIndex});
}

/// After the add-spot sheet (opened for [pendingSpotToAddFromMap]) is closed.
class PendingSpotFromMapConsumed extends RoutineBuilderEvent {}

/// Remove all spots for the given day (e.g. from day "More" → Delete All).
class SpotsClearedForDay extends RoutineBuilderEvent {
  final int dayIndex;

  SpotsClearedForDay(this.dayIndex);
}

/// Set or clear the custom label for a day (e.g. "Arrival", "Beach day").
class DayLabelUpdated extends RoutineBuilderEvent {
  final int dayIndex;

  /// Null or empty to clear the label and show "Day N" again.
  final String? label;

  DayLabelUpdated({required this.dayIndex, this.label});
}

/// Persist current trip, spots, and day labels to local storage. Emits [lastSavedAt] on success.
class SaveRoutine extends RoutineBuilderEvent {}
