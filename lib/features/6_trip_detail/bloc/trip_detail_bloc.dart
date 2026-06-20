import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/trip_models.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  final String tripId;

  TripDetailBloc({required this.tripId}) : super(const TripDetailState()) {
    on<TripDetailLoadRequested>(_onLoadRequested);
    on<TripDetailSpotAdded>(_onSpotAdded);
    on<TripDetailExpenseAdded>(_onExpenseAdded);
    on<TripDetailDaySelected>(_onDaySelected);
  }

  Future<void> _onLoadRequested(
    TripDetailLoadRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 300));

    final trip = Trip(
      id: tripId,
      name: 'Tokyo 2026',
      destination: 'Tokyo, Japan',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      defaultCurrency: 'JPY',
      buddies: [
        Buddy(id: 'b1', name: 'Wayne', avatarColor: '007AFF'),
        Buddy(id: 'b2', name: 'Alice', avatarColor: 'FF6B6B'),
        Buddy(id: 'b3', name: 'Bob', avatarColor: '4ECDC4'),
        Buddy(id: 'b4', name: 'Dave', avatarColor: '45B7D1'),
      ],
      createdAt: DateTime.now(),
    );

    final days = List.generate(trip.numberOfDays, (i) {
      return TripDay(
        id: 'd${i + 1}',
        tripId: tripId,
        dayNumber: i + 1,
        title: i == 0 ? 'Arrival' : null,
        date: trip.startDate.add(Duration(days: i)),
      );
    });

    final spots = [
      Spot(id: 's1', dayId: 'd1', tripId: tripId, name: 'Ichiran Ramen', address: '1-22-7 Shibuya', area: 'Shibuya', category: 'food', openingHours: '09:00-22:00', estimatedDuration: '1h', estimatedCost: Decimal.parse('1290'), costCurrency: 'JPY', orderIndex: 0),
      Spot(id: 's2', dayId: 'd1', tripId: tripId, name: 'Meiji Shrine', address: '1-1 Harajuku', area: 'Harajuku', category: 'attraction', openingHours: 'Sunrise-16:30', estimatedDuration: '2h', orderIndex: 1),
      Spot(id: 's3', dayId: 'd1', tripId: tripId, name: 'Sushi Zanmai', address: '4-11-9 Ginza', area: 'Ginza', category: 'food', openingHours: '11:00-22:30', estimatedDuration: '1.5h', estimatedCost: Decimal.parse('4800'), costCurrency: 'JPY', orderIndex: 2),
    ];

    emit(state.copyWith(
      isLoading: false,
      trip: trip,
      days: days,
      spots: spots,
      expenses: [],
      selectedDayIndex: 0,
    ));
  }

  Future<void> _onSpotAdded(
    TripDetailSpotAdded event,
    Emitter<TripDetailState> emit,
  ) async {
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
    emit(state.copyWith(spots: [...state.spots, spot]));
  }

  Future<void> _onExpenseAdded(
    TripDetailExpenseAdded event,
    Emitter<TripDetailState> emit,
  ) async {
    emit(state.copyWith(expenses: [...state.expenses, event.expense]));
  }

  void _onDaySelected(
    TripDetailDaySelected event,
    Emitter<TripDetailState> emit,
  ) {
    emit(state.copyWith(selectedDayIndex: event.index));
  }
}
