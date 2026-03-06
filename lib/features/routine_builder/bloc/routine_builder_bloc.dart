import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/routine_builder/data/default_spots.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

part 'routine_builder_event.dart';
part 'routine_builder_state.dart';

class RoutineBuilderBloc
    extends Bloc<RoutineBuilderEvent, RoutineBuilderState> {
  RoutineBuilderBloc({RoutineSpot? pendingSpotFromMap})
      : super(RoutineBuilderState(
          pendingSpotToAddFromMap: pendingSpotFromMap,
        )) {
    on<TripSelected>(_onTripSelected);
    on<TripCleared>(_onTripCleared);
    on<CarouselPageChanged>(_onCarouselPageChanged);
    on<SpotAdded>(_onSpotAdded);
    on<SpotUpdated>(_onSpotUpdated);
    on<SpotRemoved>(_onSpotRemoved);
    on<PendingSpotFromMapConsumed>(_onPendingSpotFromMapConsumed);
  }

  void _onPendingSpotFromMapConsumed(
    PendingSpotFromMapConsumed event,
    Emitter<RoutineBuilderState> emit,
  ) {
    emit(state.copyWith(clearPendingSpotToAddFromMap: true));
  }

  void _onTripSelected(TripSelected event, Emitter<RoutineBuilderState> emit) {
    final days = event.trip.daysOfTrip;
    final spotsByDay = <int, List<RoutineSpot>>{
      for (var d = 0; d < days; d++) d: List<RoutineSpot>.from(kDefaultRoutineSpots),
    };
    emit(state.copyWith(
      trip: event.trip,
      currentDayPageIndex: 0,
      spotsByDay: spotsByDay,
    ));
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

  void _onSpotUpdated(SpotUpdated event, Emitter<RoutineBuilderState> emit) {
    var list = state.spotsForDay(event.dayIndex);
    if (list.isEmpty && state.trip != null) {
      list = List<RoutineSpot>.from(kDefaultRoutineSpots);
    }
    if (event.spotIndex < 0 || event.spotIndex >= list.length) return;
    final newList = List<RoutineSpot>.from(list)
      ..[event.spotIndex] = event.spot;
    final updated = Map<int, List<RoutineSpot>>.from(state.spotsByDay)
      ..[event.dayIndex] = newList;
    emit(state.copyWith(spotsByDay: updated));
  }

  void _onSpotRemoved(SpotRemoved event, Emitter<RoutineBuilderState> emit) {
    final list = state.spotsForDay(event.dayIndex);
    if (event.spotIndex < 0 || event.spotIndex >= list.length) return;
    final newList = List<RoutineSpot>.from(list)..removeAt(event.spotIndex);
    final updated = Map<int, List<RoutineSpot>>.from(state.spotsByDay)
      ..[event.dayIndex] = newList;
    emit(state.copyWith(spotsByDay: updated));
  }
}
