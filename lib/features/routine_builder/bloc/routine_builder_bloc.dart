import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/widgets/bottom_sheets/routine_builder_bottom_sheet/routine_builder_bottom_sheet.dart';

part 'routine_builder_event.dart';
part 'routine_builder_state.dart';

class RoutineBuilderBloc extends Bloc<RoutineBuilderEvent, RoutineBuilderState> {
  RoutineBuilderBloc() : super(const RoutineBuilderState()) {
    on<TripSelected>(_onTripSelected);
    on<TripCleared>(_onTripCleared);
  }

  void _onTripSelected(TripSelected event, Emitter<RoutineBuilderState> emit) {
    emit(RoutineBuilderState(trip: event.trip));
  }

  void _onTripCleared(TripCleared event, Emitter<RoutineBuilderState> emit) {
    emit(const RoutineBuilderState());
  }
}
