part of 'routine_builder_bloc.dart';

class RoutineBuilderState {
  const RoutineBuilderState({this.trip});

  final RoutineTripResult? trip;

  int get pageCount => trip?.daysOfTrip ?? 0;
}
