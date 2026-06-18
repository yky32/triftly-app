part of 'spend_bloc.dart';

class SpendState {
  const SpendState({
    this.hasActiveTrip = false,
    this.tripName,
    this.daysRemaining = 0,
  });

  final bool hasActiveTrip;
  final String? tripName;
  final int daysRemaining;
}
