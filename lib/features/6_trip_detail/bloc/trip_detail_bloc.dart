import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/settlement_record.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/repositories/hive_trip_repository.dart';
import '../../../../core/repositories/trip_repository.dart';
import '../../../../core/utils/today_plan_utils.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  TripDetailBloc({
    required this.tripId,
    TripRepository? repository,
  })  : _repository = repository ?? HiveTripRepository.instance,
        super(const TripDetailState()) {
    on<TripDetailLoadRequested>(_onLoadRequested);
    on<TripDetailSpotAdded>(_onSpotAdded);
    on<TripDetailExpenseAdded>(_onExpenseAdded);
    on<TripDetailExpenseUpdated>(_onExpenseUpdated);
    on<TripDetailExpenseRemoved>(_onExpenseRemoved);
    on<TripDetailDaySelected>(_onDaySelected);
    on<TripDetailSpotVisitedToggled>(_onSpotVisitedToggled);
    on<TripDetailSpotsReordered>(_onSpotsReordered);
    on<TripDetailSpotUpdated>(_onSpotUpdated);
    on<TripDetailSpotRemoved>(_onSpotRemoved);
    on<TripDetailTripUpdated>(_onTripUpdated);
    on<TripDetailTripDeleted>(_onTripDeleted);
    on<TripDetailSettlementRecorded>(_onSettlementRecorded);
  }

  final String tripId;
  final TripRepository _repository;

  Future<void> _onLoadRequested(
    TripDetailLoadRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final detail = await _repository.loadDetail(tripId);
    if (detail == null) {
      emit(state.copyWith(isLoading: false, error: 'Trip not found'));
      return;
    }

    final trip = _repository.tripById(tripId);
    final dayIndex = TodayPlanUtils.initialDayIndex(trip, detail.days);

    emit(state.copyWith(
      isLoading: false,
      trip: trip,
      days: detail.days,
      spots: detail.spots.where((s) => s.isActive).toList(),
      expenses: detail.expenses.where((e) => e.isActive).toList(),
      settlements: detail.settlements.where((s) => s.isActive).toList(),
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
    _repository.addSpot(tripId, spot);
    emit(state.copyWith(spots: [...state.spots, spot]));
  }

  Future<void> _onExpenseAdded(
    TripDetailExpenseAdded event,
    Emitter<TripDetailState> emit,
  ) async {
    _repository.addExpense(tripId, event.expense);
    emit(state.copyWith(expenses: [...state.expenses, event.expense]));
  }

  void _onExpenseUpdated(
    TripDetailExpenseUpdated event,
    Emitter<TripDetailState> emit,
  ) {
    final index = state.expenses.indexWhere((e) => e.id == event.expense.id);
    if (index < 0) return;

    _repository.updateExpense(tripId, event.expense);
    final expenses = [...state.expenses];
    expenses[index] = event.expense;
    emit(state.copyWith(expenses: expenses));
  }

  void _onExpenseRemoved(
    TripDetailExpenseRemoved event,
    Emitter<TripDetailState> emit,
  ) {
    final index = state.expenses.indexWhere((e) => e.id == event.expenseId);
    if (index < 0) return;

    _repository.removeExpense(tripId, event.expenseId);
    emit(state.copyWith(
      expenses: state.expenses.where((e) => e.id != event.expenseId).toList(),
    ));
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
    _repository.updateSpot(tripId, updated);
    final spots = [...state.spots];
    spots[index] = updated;
    emit(state.copyWith(spots: spots));
  }

  void _onSpotsReordered(
    TripDetailSpotsReordered event,
    Emitter<TripDetailState> emit,
  ) {
    _repository.reorderSpotsInDay(tripId, event.dayId, event.oldIndex, event.newIndex);
    final detail = _repository.detailSync(tripId);
    if (detail == null) return;
    emit(state.copyWith(spots: detail.spots.where((s) => s.isActive).toList()));
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
    _repository.updateSpot(tripId, updated);
    final spots = [...state.spots];
    spots[index] = updated;
    emit(state.copyWith(spots: spots));
  }

  void _onSpotRemoved(
    TripDetailSpotRemoved event,
    Emitter<TripDetailState> emit,
  ) {
    _repository.removeSpot(tripId, event.spotId);
    emit(state.copyWith(
      spots: state.spots.where((s) => s.id != event.spotId).toList(),
    ));
  }

  Future<void> _onTripUpdated(
    TripDetailTripUpdated event,
    Emitter<TripDetailState> emit,
  ) async {
    await _repository.updateTrip(event.trip);
    emit(state.copyWith(trip: event.trip));
  }

  Future<void> _onTripDeleted(
    TripDetailTripDeleted event,
    Emitter<TripDetailState> emit,
  ) async {
    await _repository.deactivateTrip(tripId);
    emit(state.copyWith(deleted: true));
  }

  void _onSettlementRecorded(
    TripDetailSettlementRecorded event,
    Emitter<TripDetailState> emit,
  ) {
    _repository.addSettlement(tripId, event.record);
    emit(state.copyWith(settlements: [...state.settlements, event.record]));
  }
}
