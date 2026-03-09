part of 'routine_builder_bloc.dart';

class RoutineBuilderState {
  const RoutineBuilderState({
    this.trip,
    this.currentDayPageIndex = 0,
    this.spotsByDay = const {},
    this.dayLabels = const {},
    this.pendingSpotToAddFromMap,
    this.lastSavedAt,
  });

  final RoutineTripResult? trip;

  /// Current page index in the day carousel (0-based). Kept in bloc for stateless UI.
  final int currentDayPageIndex;

  /// Spots added by the user per day (dayIndex -> list of [RoutineSpot]).
  final Map<int, List<RoutineSpot>> spotsByDay;

  /// Optional custom label per day (e.g. "Arrival", "Beach day"). When null or missing, header shows "Day N".
  final Map<int, String> dayLabels;

  /// When non-null, UI should open add-spot sheet with this as initial, then dispatch [PendingSpotFromMapConsumed].
  final RoutineSpot? pendingSpotToAddFromMap;

  /// Set when [SaveRoutine] completes; UI shows "Saved" and dispatches [ClearSaveStatus].
  final DateTime? lastSavedAt;

  int get pageCount => trip?.daysOfTrip ?? 0;

  List<RoutineSpot> spotsForDay(int dayIndex) =>
      spotsByDay[dayIndex] ?? const [];

  String? labelForDay(int dayIndex) {
    final s = dayLabels[dayIndex];
    return (s != null && s.trim().isNotEmpty) ? s.trim() : null;
  }

  RoutineBuilderState copyWith({
    RoutineTripResult? trip,
    int? currentDayPageIndex,
    Map<int, List<RoutineSpot>>? spotsByDay,
    Map<int, String>? dayLabels,
    RoutineSpot? pendingSpotToAddFromMap,
    bool clearPendingSpotToAddFromMap = false,
    DateTime? lastSavedAt,
    bool clearLastSavedAt = false,
  }) {
    return RoutineBuilderState(
      trip: trip ?? this.trip,
      currentDayPageIndex: currentDayPageIndex ?? this.currentDayPageIndex,
      spotsByDay: spotsByDay ?? this.spotsByDay,
      dayLabels: dayLabels ?? this.dayLabels,
      pendingSpotToAddFromMap: clearPendingSpotToAddFromMap
          ? null
          : (pendingSpotToAddFromMap ?? this.pendingSpotToAddFromMap),
      lastSavedAt: clearLastSavedAt ? null : (lastSavedAt ?? this.lastSavedAt),
    );
  }
}
