import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_store.dart';
import '../../../../core/utils/today_plan_utils.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  TripDetailBloc({required this.tripId}) : super(const TripDetailState()) {
    on<TripDetailLoadRequested>(_onLoadRequested);
    on<TripDetailSpotAdded>(_onSpotAdded);
    on<TripDetailExpenseAdded>(_onExpenseAdded);
    on<TripDetailDaySelected>(_onDaySelected);
    on<TripDetailSpotVisitedToggled>(_onSpotVisitedToggled);
    on<TripDetailSpotsReordered>(_onSpotsReordered);
    on<TripDetailSpotUpdated>(_onSpotUpdated);
  }

  final String tripId;
  final _store = TripStore.instance;

  Future<void> _onLoadRequested(
    TripDetailLoadRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final detail = await _store.loadDetail(tripId);
    if (detail == null) {
      emit(state.copyWith(isLoading: false, error: 'Trip not found'));
      return;
    }

    final trip = _store.tripById(tripId);
    final dayIndex = TodayPlanUtils.initialDayIndex(trip, detail.days);

    emit(state.copyWith(
      isLoading: false,
      trip: trip,
      days: detail.days,
      spots: detail.spots,
      expenses: detail.expenses,
      selectedDayIndex: dayIndex,
    ));
  }

  Future<void> _onSpotAdded(
    TripDetailSpotAdded event,
    Emitter<TripDetailState> emit,
  ) async {
    if (state.days.isEmpty) return;
    final dayId = state.days[state.selectedDayIndex].id;
    final spot = Spot(
      id: const Uuid().v4(),
      dayId: dayId,
      tripId: tripId,
      name: event.name,
      address: event.address,
      category: event.category,
      openingHours: event.openingHours,
      estimatedDuration: event.estimatedDuration,
      notes: event.notes,
      orderIndex: state.spots.where((s) => s.dayId == dayId).length,
    );
    _store.addSpot(tripId, spot);
    emit(state.copyWith(spots: [...state.spots, spot]));
  }

  Future<void> _onExpenseAdded(
    TripDetailExpenseAdded event,
    Emitter<TripDetailState> emit,
  ) async {
    _store.addExpense(tripId, event.expense);
    emit(state.copyWith(expenses: [...state.expenses, event.expense]));
  }

  void _onDaySelected(
    TripDetailDaySelected event,
    Emitter<TripDetailState> emit,
  ) {
    emit(state.copyWith(selectedDayIndex: event.index));
  }

  void _onSpotVisitedToggled(
    TripDetailSpotVisitedToggled event,
    Emitter<TripDetailState> emit,
  ) {
    final index = state.spots.indexWhere((s) => s.id == event.spotId);
    if (index < 0) return;

    final updated = state.spots[index].copyWith(visited: !state.spots[index].visited);
    _store.updateSpot(tripId, updated);
    final spots = [...state.spots];
    spots[index] = updated;
    emit(state.copyWith(spots: spots));
  }

  void _onSpotsReordered(
    TripDetailSpotsReordered event,
    Emitter<TripDetailState> emit,
  ) {
    _store.reorderSpotsInDay(tripId, event.dayId, event.oldIndex, event.newIndex);
    final detail = _store.detailSync(tripId);
    if (detail == null) return;
    emit(state.copyWith(spots: detail.spots));
  }

  void _onSpotUpdated(
    TripDetailSpotUpdated event,
    Emitter<TripDetailState> emit,
  ) {
    final index = state.spots.indexWhere((s) => s.id == event.spotId);
    if (index < 0) return;

    final updated = state.spots[index].copyWith(
      name: event.name,
      address: event.address,
      category: event.category,
      openingHours: event.openingHours,
      estimatedDuration: event.estimatedDuration,
      notes: event.notes,
    );
    _store.updateSpot(tripId, updated);
    final spots = [...state.spots];
    spots[index] = updated;
    emit(state.copyWith(spots: spots));
  }
}
