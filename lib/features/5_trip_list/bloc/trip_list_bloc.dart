import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc() : super(const TripListState()) {
    on<TripListLoadRequested>(_onLoadRequested);
    on<TripListTripCreated>(_onTripCreated);
  }

  Future<void> _onLoadRequested(
    TripListLoadRequested event,
    Emitter<TripListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    // TODO: Load from Supabase + Hive cache
    // For now, use mock data
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(isLoading: false, trips: _mockTrips()));
  }

  Future<void> _onTripCreated(
    TripListTripCreated event,
    Emitter<TripListState> emit,
  ) async {
    // TODO: Save to Supabase + Hive cache
    emit(state.copyWith(trips: [event.trip, ...state.trips]));
  }

  List<Trip> _mockTrips() {
    final now = DateTime.now();
    return [
      Trip(
        id: '1',
        name: 'Tokyo 2026',
        destination: 'Tokyo, Japan',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 14)),
        defaultCurrency: 'JPY',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Alice'),
          Buddy.create(name: 'Bob'),
          Buddy.create(name: 'Dave'),
        ],
        createdAt: now,
      ),
      Trip(
        id: '2',
        name: 'Seoul Weekend',
        destination: 'Seoul, Korea',
        startDate: now.add(const Duration(days: 24)),
        endDate: now.add(const Duration(days: 26)),
        defaultCurrency: 'KRW',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Alice'),
          Buddy.create(name: 'Carol'),
        ],
        createdAt: now,
      ),
    ];
  }
}
