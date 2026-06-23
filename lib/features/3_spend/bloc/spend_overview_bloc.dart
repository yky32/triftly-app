import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/spend_overview_models.dart';
import '../../../core/services/spend_ledger_service.dart';

part 'spend_overview_event.dart';
part 'spend_overview_state.dart';

class SpendOverviewBloc extends Bloc<SpendOverviewEvent, SpendOverviewState> {
  SpendOverviewBloc({SpendLedgerService? ledger})
      : _ledger = ledger ?? SpendLedgerService(),
        super(const SpendOverviewState()) {
    on<SpendOverviewLoadRequested>(_onLoad);
    on<SpendOverviewReloadRequested>(_onLoad);
  }

  final SpendLedgerService _ledger;

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
}
