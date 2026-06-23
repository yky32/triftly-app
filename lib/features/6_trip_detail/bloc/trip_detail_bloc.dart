import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_store.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  TripDetailBloc({required this.tripId}) : super(const TripDetailState()) {
    on<TripDetailLoadRequested>(_onLoadRequested);
    on<TripDetailSpotAdded>(_onSpotAdded);
    on<TripDetailExpenseAdded>(_onExpenseAdded);
    on<TripDetailDaySelected>(_onDaySelected);
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

    emit(state.copyWith(
      isLoading: false,
      trip: _store.tripById(tripId),
      days: detail.days,
      spots: detail.spots,
      expenses: detail.expenses,
      selectedDayIndex: 0,
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
}
