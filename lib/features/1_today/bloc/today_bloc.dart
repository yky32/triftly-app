import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/features/3_routine_builder/models/routine_spot.dart';

part 'today_event.dart';
part 'today_state.dart';

/// Manages the Today page: loads the active trip, shows today's spots,
/// and handles spot completion toggling.
class TodayBloc extends Bloc<TodayEvent, TodayState> {
  TodayBloc({required RoutineRepository repository})
      : _repository = repository,
        super(const TodayState()) {
    on<TodayLoaded>(_onTodayLoaded);
    on<TodaySpotToggled>(_onTodaySpotToggled);
  }

  final RoutineRepository _repository;

  void _onTodayLoaded(TodayLoaded event, Emitter<TodayState> emit) {
    final activeTrip = _repository.getActiveTrip();
    if (activeTrip == null) {
      emit(const TodayState(isLoading: false, hasActiveTrip: false));
      return;
    }

    final todaySpots = activeTrip.todaySpots;
    final completedToday = todaySpots.where((s) => s.isCompleted).length;
    final totalToday = todaySpots.length;

    emit(TodayState(
      isLoading: false,
      hasActiveTrip: true,
      activeTrip: activeTrip,
      todaySpots: todaySpots,
      completedTodayCount: completedToday,
      totalTodayCount: totalToday,
      totalTripCompleted: activeTrip.completedSpotCount,
      totalTripSpots: activeTrip.totalSpotCount,
      daysRemaining: activeTrip.daysRemaining,
    ));
  }

  Future<void> _onTodaySpotToggled(
    TodaySpotToggled event,
    Emitter<TodayState> emit,
  ) async {
    if (state.activeTrip == null) return;

    final dayIndex = state.activeTrip!.todayDayIndex;
    if (dayIndex == null) return;

    try {
      final updatedRoutine = await _repository.toggleSpotCompletion(
        dayIndex: dayIndex,
        spotIndex: event.spotIndex,
      );

      final newSpots = updatedRoutine.todaySpots;
      final completedToday = newSpots.where((s) => s.isCompleted).length;

      emit(state.copyWith(
        activeTrip: updatedRoutine,
        todaySpots: newSpots,
        completedTodayCount: completedToday,
        totalTripCompleted: updatedRoutine.completedSpotCount,
      ));
    } catch (_) {
      // Silently ignore toggle failures — state remains unchanged
    }
  }
}
