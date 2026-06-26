import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/session/session_bloc.dart';
import '../../../core/models/spend_overview_models.dart';
import '../../../core/repositories/hive_trip_repository.dart';
import '../../../core/services/spend_ledger_service.dart';

part 'spend_overview_event.dart';
part 'spend_overview_state.dart';

class SpendOverviewBloc extends Bloc<SpendOverviewEvent, SpendOverviewState> {
  SpendOverviewBloc({
    SpendLedgerService? ledger,
    HiveTripRepository? repository,
    SessionBloc? sessionBloc,
  })  : _ledger = ledger ?? SpendLedgerService(repository: repository),
        _repository = repository ?? HiveTripRepository.instance,
        _sessionBloc = sessionBloc,
        super(const SpendOverviewState()) {
    on<SpendOverviewLoadRequested>(_onLoad);
    on<SpendOverviewReloadRequested>(_onLoad);
    _repository.addListener(_onRepoChanged);
    _sessionSubscription = _sessionBloc?.stream.listen((_) {
      add(const SpendOverviewReloadRequested());
    });
  }

  final SpendLedgerService _ledger;
  final HiveTripRepository _repository;
  final SessionBloc? _sessionBloc;
  StreamSubscription<SessionState>? _sessionSubscription;

  void _onRepoChanged() => add(const SpendOverviewReloadRequested());

  Future<void> _onLoad(
    SpendOverviewEvent event,
    Emitter<SpendOverviewState> emit,
  ) async {
    final keepShowingData = state.overview != null;
    if (!keepShowingData) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final overview = await _ledger.loadGlobalOverview(
        user: _sessionBloc?.state.user,
      );
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _repository.removeListener(_onRepoChanged);
    _sessionSubscription?.cancel();
    return super.close();
  }
}
