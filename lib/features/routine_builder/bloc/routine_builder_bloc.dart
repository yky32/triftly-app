import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/features/routine_builder/data/routine_repository.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

part 'routine_builder_event.dart';
part 'routine_builder_state.dart';

class RoutineBuilderBloc
    extends Bloc<RoutineBuilderEvent, RoutineBuilderState> {
  RoutineBuilderBloc({
    required RoutineRepository repository,
    RoutineSpot? pendingSpotFromMap,
  })  : _repository = repository,
        super(RoutineBuilderState(
          pendingSpotToAddFromMap: pendingSpotFromMap,
        )) {
    on<TripSelected>(_onTripSelected);
    on<TripCleared>(_onTripCleared);
    on<CarouselPageChanged>(_onCarouselPageChanged);
    on<SpotAdded>(_onSpotAdded);
    on<SpotUpdated>(_onSpotUpdated);
    on<SpotRemoved>(_onSpotRemoved);
    on<PendingSpotFromMapConsumed>(_onPendingSpotFromMapConsumed);
    on<SpotsClearedForDay>(_onSpotsClearedForDay);
    on<DayLabelUpdated>(_onDayLabelUpdated);
    on<SaveRoutine>(_onSaveRoutine);
  }

  final RoutineRepository _repository;

  void _onPendingSpotFromMapConsumed(
    PendingSpotFromMapConsumed event,
    Emitter<RoutineBuilderState> emit,
  ) {
    emit(state.copyWith(clearPendingSpotToAddFromMap: true));
  }

  void _onTripSelected(TripSelected event, Emitter<RoutineBuilderState> emit) {
    final days = event.trip.daysOfTrip;
    final spotsByDay = <int, List<RoutineSpot>>{
      for (var d = 0; d < days; d++) d: <RoutineSpot>[],
    };
    emit(state.copyWith(
      trip: event.trip,
      currentDayPageIndex: 0,
      spotsByDay: spotsByDay,
      dayLabels: const {},
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
    final list = state.spotsForDay(event.dayIndex);
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

  void _onSpotsClearedForDay(
    SpotsClearedForDay event,
    Emitter<RoutineBuilderState> emit,
  ) {
    final updated = Map<int, List<RoutineSpot>>.from(state.spotsByDay)
      ..[event.dayIndex] = <RoutineSpot>[];
    emit(state.copyWith(spotsByDay: updated));
  }

  void _onDayLabelUpdated(
    DayLabelUpdated event,
    Emitter<RoutineBuilderState> emit,
  ) {
    final updated = Map<int, String>.from(state.dayLabels);
    if (event.label == null || event.label!.trim().isEmpty) {
      updated.remove(event.dayIndex);
    } else {
      updated[event.dayIndex] = event.label!.trim();
    }
    emit(state.copyWith(dayLabels: updated));
  }

  Future<void> _onSaveRoutine(
    SaveRoutine event,
    Emitter<RoutineBuilderState> emit,
  ) async {
    await _repository.save(
      trip: state.trip,
      spotsByDay: state.spotsByDay,
      dayLabels: state.dayLabels,
    );
    emit(state.copyWith(lastSavedAt: DateTime.now()));
  }
}
