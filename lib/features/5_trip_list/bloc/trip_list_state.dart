part of 'trip_list_bloc.dart';

class TripListState extends Equatable {
  final List<Trip> trips;
  final bool isLoading;
  final String? error;

  const TripListState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
  });

  TripListState copyWith({
    List<Trip>? trips,
    bool? isLoading,
    String? error,
  }) =>
      TripListState(
        trips: trips ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [trips, isLoading, error];
}
