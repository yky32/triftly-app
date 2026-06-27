part of 'trip_list_bloc.dart';

sealed class TripListEvent extends Equatable {
  const TripListEvent();
  @override
  List<Object?> get props => [];
}

final class TripListLoadRequested extends TripListEvent {
  const TripListLoadRequested({this.syncCloud = true});

  /// When true, pull latest trips from Supabase for the signed-in user.
  final bool syncCloud;

  @override
  List<Object?> get props => [syncCloud];
}

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

final class TripListTripLeft extends TripListEvent {
  final String tripId;
  const TripListTripLeft({required this.tripId});
  @override
  List<Object?> get props => [tripId];
}
