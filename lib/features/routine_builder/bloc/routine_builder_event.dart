part of 'routine_builder_bloc.dart';

abstract class RoutineBuilderEvent {}

class TripSelected extends RoutineBuilderEvent {
  final RoutineTripResult trip;

  TripSelected(this.trip);
}

class TripCleared extends RoutineBuilderEvent {}

class CarouselPageChanged extends RoutineBuilderEvent {
  final int index;

  CarouselPageChanged(this.index);
}
