import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

part 'routine_builder_event.dart';
part 'routine_builder_state.dart';

class RoutineBuilderBloc
    extends Bloc<RoutineBuilderEvent, RoutineBuilderState> {
  RoutineBuilderBloc() : super(const RoutineBuilderState()) {
    on<TripSelected>(_onTripSelected);
    on<TripCleared>(_onTripCleared);
    on<CarouselPageChanged>(_onCarouselPageChanged);
    on<SpotAdded>(_onSpotAdded);
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

  void _onSpotAdded(SpotAdded event, Emitter<RoutineBuilderState> emit) {
    final list = List<RoutineSpot>.from(state.spotsForDay(event.dayIndex))
      ..add(event.spot);
    final updated = Map<int, List<RoutineSpot>>.from(state.spotsByDay)
      ..[event.dayIndex] = list;
    emit(state.copyWith(spotsByDay: updated));
  }
}
