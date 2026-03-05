part of 'routine_builder_bloc.dart';

class RoutineBuilderState {
  const RoutineBuilderState({
    this.trip,
    this.currentDayPageIndex = 0,
    this.spotsByDay = const {},
    this.pendingSpotToAddFromMap,
  });

  final RoutineTripResult? trip;

  /// Current page index in the day carousel (0-based). Kept in bloc for stateless UI.
  final int currentDayPageIndex;

  /// Spots added by the user per day (dayIndex -> list of [RoutineSpot]).
  final Map<int, List<RoutineSpot>> spotsByDay;

  /// When non-null, UI should open add-spot sheet with this as initial, then dispatch [PendingSpotFromMapConsumed].
  final RoutineSpot? pendingSpotToAddFromMap;

  int get pageCount => trip?.daysOfTrip ?? 0;

  List<RoutineSpot> spotsForDay(int dayIndex) =>
      spotsByDay[dayIndex] ?? const [];

  RoutineBuilderState copyWith({
    RoutineTripResult? trip,
    int? currentDayPageIndex,
    Map<int, List<RoutineSpot>>? spotsByDay,
    RoutineSpot? pendingSpotToAddFromMap,
    bool clearPendingSpotToAddFromMap = false,
  }) {
    return RoutineBuilderState(
      trip: trip ?? this.trip,
      currentDayPageIndex: currentDayPageIndex ?? this.currentDayPageIndex,
      spotsByDay: spotsByDay ?? this.spotsByDay,
      pendingSpotToAddFromMap: clearPendingSpotToAddFromMap
          ? null
          : (pendingSpotToAddFromMap ?? this.pendingSpotToAddFromMap),
    );
  }
}
