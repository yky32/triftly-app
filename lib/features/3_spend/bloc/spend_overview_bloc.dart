import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/spend_overview_models.dart';
import '../../../core/services/spend_ledger_service.dart';
import '../../../core/services/trip_store.dart';

part 'spend_overview_event.dart';
part 'spend_overview_state.dart';

class SpendOverviewBloc extends Bloc<SpendOverviewEvent, SpendOverviewState> {
  SpendOverviewBloc({
    SpendLedgerService? ledger,
    TripStore? store,
  })  : _ledger = ledger ?? SpendLedgerService(),
        _store = store ?? TripStore.instance,
        super(const SpendOverviewState()) {
    on<SpendOverviewLoadRequested>(_onLoad);
    on<SpendOverviewReloadRequested>(_onLoad);
    _store.addListener(_onStoreChanged);
  }

  final SpendLedgerService _ledger;
  final TripStore _store;

  void _onStoreChanged() => add(const SpendOverviewReloadRequested());

  Future<void> _onLoad(
    SpendOverviewEvent event,
    Emitter<SpendOverviewState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final overview = await _ledger.loadGlobalOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _store.removeListener(_onStoreChanged);
    return super.close();
  }
}
