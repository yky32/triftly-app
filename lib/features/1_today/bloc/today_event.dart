part of 'today_bloc.dart';

sealed class TodayEvent {
  const TodayEvent();
}

/// Triggered when the Today page is first built — loads the active trip.
class TodayLoaded extends TodayEvent {
  const TodayLoaded();
}

/// Triggered when the user taps a spot to mark it complete/incomplete.
class TodaySpotToggled extends TodayEvent {
  const TodaySpotToggled({required this.spotIndex});

  final int spotIndex;
}
