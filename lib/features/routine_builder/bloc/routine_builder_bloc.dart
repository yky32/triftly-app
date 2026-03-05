import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

part 'routine_builder_event.dart';
part 'routine_builder_state.dart';

class RoutineBuilderBloc
    extends Bloc<RoutineBuilderEvent, RoutineBuilderState> {
  RoutineBuilderBloc() : super(const RoutineBuilderState()) {
    on<TripSelected>(_onTripSelected);
    on<TripCleared>(_onTripCleared);
    on<CarouselPageChanged>(_onCarouselPageChanged);
  }

  void _onTripSelected(TripSelected event, Emitter<RoutineBuilderState> emit) {
    emit(state.copyWith(trip: event.trip, currentDayPageIndex: 0));
  }

  void _onTripCleared(TripCleared event, Emitter<RoutineBuilderState> emit) {
    emit(const RoutineBuilderState());
  }

  void _onCarouselPageChanged(
    CarouselPageChanged event,
    Emitter<RoutineBuilderState> emit,
  ) {
    emit(state.copyWith(currentDayPageIndex: event.index));
  }
}
