import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/features/3_routine_builder/models/routine_spot.dart';

part 'today_event.dart';
part 'today_state.dart';

/// Day tab: browse any day of the saved trip and check off spots.
class TodayBloc extends Bloc<TodayEvent, TodayState> {
  TodayBloc({required RoutineRepository repository})
      : _repository = repository,
        super(const TodayState()) {
    on<TodayLoaded>(_onTodayLoaded);
    on<TodayDaySelected>(_onDaySelected);
    on<TodaySpotToggled>(_onTodaySpotToggled);
  }

  final RoutineRepository _repository;

  void _onTodayLoaded(TodayLoaded event, Emitter<TodayState> emit) {
    final routine = _repository.getActiveTrip() ?? _repository.load();
    if (routine == null) {
      emit(const TodayState(isLoading: false, hasTrip: false));
      return;
    }

    final dayCount = routine.trip.daysOfTrip;
    final initialDay = routine.todayDayIndex ?? 0;
    _emitForDay(emit, routine, initialDay.clamp(0, dayCount > 0 ? dayCount - 1 : 0));
  }

  void _onDaySelected(TodayDaySelected event, Emitter<TodayState> emit) {
    if (state.trip == null) return;
    _emitForDay(emit, state.trip!, event.dayIndex);
  }

  Future<void> _onTodaySpotToggled(
    TodaySpotToggled event,
    Emitter<TodayState> emit,
  ) async {
    if (state.trip == null) return;

    try {
      final updated = await _repository.toggleSpotCompletion(
        dayIndex: state.selectedDayIndex,
        spotIndex: event.spotIndex,
      );
      _emitForDay(emit, updated, state.selectedDayIndex);
    } catch (_) {}
  }

  void _emitForDay(
    Emitter<TodayState> emit,
    SavedRoutine routine,
    int dayIndex,
  ) {
    final dayCount = routine.trip.daysOfTrip;
    final safeIndex = dayCount == 0 ? 0 : dayIndex.clamp(0, dayCount - 1);
    final daySpots = routine.spotsByDay[safeIndex] ?? const <RoutineSpot>[];
    final completedDay = daySpots.where((s) => s.isCompleted).length;

    emit(TodayState(
      isLoading: false,
      hasTrip: true,
      trip: routine,
      selectedDayIndex: safeIndex,
      daySpots: daySpots,
      completedDayCount: completedDay,
      totalDayCount: daySpots.length,
      totalTripCompleted: routine.completedSpotCount,
      totalTripSpots: routine.totalSpotCount,
      daysRemaining: routine.daysRemaining,
      todayDayIndex: routine.todayDayIndex,
    ));
  }
}
