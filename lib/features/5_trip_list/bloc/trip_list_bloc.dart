import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_store.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc() : super(const TripListState()) {
    on<TripListLoadRequested>(_onLoadRequested);
    on<TripListTripCreated>(_onTripCreated);
  }

  final _store = TripStore.instance;

  Future<void> _onLoadRequested(
    TripListLoadRequested event,
    Emitter<TripListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    // TODO: Load from Supabase + Hive cache, merge with TripStore
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(isLoading: false, trips: _store.allTrips()));
  }

  Future<void> _onTripCreated(
    TripListTripCreated event,
    Emitter<TripListState> emit,
  ) async {
    // TODO: Save to Supabase + Hive cache
    _store.upsertCreatedTrip(event.trip);
    emit(state.copyWith(trips: _store.allTrips()));
  }
}

/// Group and sort trips for the Trips tab sections.
class TripListSections {
  const TripListSections({
    required this.inProgress,
    required this.upcoming,
    required this.completed,
  });

  final List<Trip> inProgress;
  final List<Trip> upcoming;
  final List<Trip> completed;

  factory TripListSections.from(List<Trip> trips) {
    final inProgress = trips.where((t) => t.isInProgress).toList()
      ..sort((a, b) => a.endDay.compareTo(b.endDay));

    final upcoming = trips.where((t) => t.isUpcoming).toList()
      ..sort((a, b) => a.startDay.compareTo(b.startDay));

    final completed = trips.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.endDay.compareTo(a.endDay));

    return TripListSections(
      inProgress: inProgress,
      upcoming: upcoming,
      completed: completed,
    );
  }

  bool get isEmpty => inProgress.isEmpty && upcoming.isEmpty && completed.isEmpty;
}
