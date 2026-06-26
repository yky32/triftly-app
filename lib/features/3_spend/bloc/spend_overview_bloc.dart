import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/spend_overview_models.dart';
import '../../../core/repositories/hive_trip_repository.dart';
import '../../../core/services/spend_ledger_service.dart';
import '../../../core/services/user_session.dart';

part 'spend_overview_event.dart';
part 'spend_overview_state.dart';

class SpendOverviewBloc extends Bloc<SpendOverviewEvent, SpendOverviewState> {
  SpendOverviewBloc({
    SpendLedgerService? ledger,
    HiveTripRepository? repository,
    UserSession? session,
  })  : _ledger = ledger ?? SpendLedgerService(repository: repository),
        _repository = repository ?? HiveTripRepository.instance,
        _session = session,
        super(const SpendOverviewState()) {
    on<SpendOverviewLoadRequested>(_onLoad);
    on<SpendOverviewReloadRequested>(_onLoad);
    _repository.addListener(_onRepoChanged);
    _session?.addListener(_onSessionChanged);
  }

  final SpendLedgerService _ledger;
  final HiveTripRepository _repository;
  final UserSession? _session;

  void _onRepoChanged() => add(const SpendOverviewReloadRequested());
  void _onSessionChanged() => add(const SpendOverviewReloadRequested());

  Future<void> _onLoad(
    SpendOverviewEvent event,
    Emitter<SpendOverviewState> emit,
  ) async {
    final keepShowingData = state.overview != null;
    if (!keepShowingData) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final overview = await _ledger.loadGlobalOverview(user: _session?.currentUser);
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _repository.removeListener(_onRepoChanged);
    _session?.removeListener(_onSessionChanged);
    return super.close();
  }
}
