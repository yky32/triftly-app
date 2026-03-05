part of 'routine_builder_bloc.dart';

class RoutineBuilderState {
  const RoutineBuilderState({
    this.trip,
    this.currentDayPageIndex = 0,
  });

  final RoutineTripResult? trip;

  /// Current page index in the day carousel (0-based). Kept in bloc for stateless UI.
  final int currentDayPageIndex;

  int get pageCount => trip?.daysOfTrip ?? 0;

  RoutineBuilderState copyWith({
    RoutineTripResult? trip,
    int? currentDayPageIndex,
  }) {
    return RoutineBuilderState(
      trip: trip ?? this.trip,
      currentDayPageIndex: currentDayPageIndex ?? this.currentDayPageIndex,
    );
  }
}
