part of 'trip_list_bloc.dart';

sealed class TripListEvent extends Equatable {
  const TripListEvent();
  @override
  List<Object?> get props => [];
}

final class TripListLoadRequested extends TripListEvent {}

final class TripListTripCreated extends TripListEvent {
  final Trip trip;
  const TripListTripCreated({required this.trip});
  @override
  List<Object?> get props => [trip];
}

final class TripListTripUpdated extends TripListEvent {
  final Trip trip;
  const TripListTripUpdated({required this.trip});
  @override
  List<Object?> get props => [trip];
}

final class TripListTripDeleted extends TripListEvent {
  final String tripId;
  const TripListTripDeleted({required this.tripId});
  @override
  List<Object?> get props => [tripId];
}
