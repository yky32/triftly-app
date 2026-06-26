import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/repositories/hive_trip_repository.dart';
import '../../../../core/repositories/trip_repository.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc({
    TripRepository? repository,
    String? Function()? cloudUserId,
  })  : _repository = repository ?? HiveTripRepository.instance,
        _cloudUserId = cloudUserId,
        super(const TripListState()) {
    on<TripListLoadRequested>(_onLoadRequested);
    on<TripListTripCreated>(_onTripCreated);
    on<TripListTripUpdated>(_onTripUpdated);
    on<TripListTripDeleted>(_onTripDeleted);
  }

  final TripRepository _repository;
  final String? Function()? _cloudUserId;

  Future<void> _onLoadRequested(
    TripListLoadRequested event,
    Emitter<TripListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (event.syncCloud) {
      await _repository.pullFromCloud(_cloudUserId?.call());
    }
    emit(state.copyWith(isLoading: false, trips: _repository.allTrips()));
  }

  Future<void> _onTripCreated(
    TripListTripCreated event,
    Emitter<TripListState> emit,
  ) async {
    await _repository.upsertTrip(event.trip);
    emit(state.copyWith(trips: _repository.allTrips()));
  }

  Future<void> _onTripUpdated(
    TripListTripUpdated event,
    Emitter<TripListState> emit,
  ) async {
    await _repository.updateTrip(event.trip);
    emit(state.copyWith(trips: _repository.allTrips()));
  }

  Future<void> _onTripDeleted(
    TripListTripDeleted event,
    Emitter<TripListState> emit,
  ) async {
    await _repository.deactivateTrip(event.tripId);
    emit(state.copyWith(trips: _repository.allTrips()));
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
