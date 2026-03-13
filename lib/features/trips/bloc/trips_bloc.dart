import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/routine_builder/data/routine_repository.dart';

class TripsBloc extends Bloc<TripsEvent, TripsState> {
  TripsBloc({required RoutineRepository repository})
      : _repository = repository,
        super(const TripsState()) {
    on<_TripsUpdated>(_onTripsUpdated);

    _subscription = _repository.watchSavedTrips().listen((trips) {
      add(_TripsUpdated(trips));
    });
  }

  final RoutineRepository _repository;
  StreamSubscription<List<SavedTripSummary>>? _subscription;

  void _onTripsUpdated(_TripsUpdated event, Emitter<TripsState> emit) {
    emit(TripsState(isLoading: false, trips: event.trips));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

abstract class TripsEvent {
  const TripsEvent();
}

class _TripsUpdated extends TripsEvent {
  const _TripsUpdated(this.trips);

  final List<SavedTripSummary> trips;
}

class TripsState {
  const TripsState({
    this.isLoading = true,
    this.trips = const [],
  });

  final bool isLoading;
  final List<SavedTripSummary> trips;
}
