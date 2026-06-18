import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';

part 'spend_event.dart';
part 'spend_state.dart';

/// Loads active trip context for the spend tab (budget UI wires up later).
class SpendBloc extends Bloc<SpendEvent, SpendState> {
  SpendBloc({required RoutineRepository repository})
      : _repository = repository,
        super(const SpendState()) {
    on<SpendLoaded>(_onLoaded);
    on<SpendReloadRequested>(_onReload);
  }

  final RoutineRepository _repository;

  void _onLoaded(SpendLoaded event, Emitter<SpendState> emit) {
    _emitFromRepository(emit);
  }

  void _onReload(SpendReloadRequested event, Emitter<SpendState> emit) {
    _emitFromRepository(emit);
  }

  void _emitFromRepository(Emitter<SpendState> emit) {
    final active = _repository.getActiveTrip();
    if (active == null) {
      emit(const SpendState(hasActiveTrip: false));
      return;
    }
    emit(SpendState(
      hasActiveTrip: true,
      tripName: active.trip.name.trim().isEmpty
          ? 'Untitled trip'
          : active.trip.name,
      daysRemaining: active.daysRemaining,
    ));
  }
}
