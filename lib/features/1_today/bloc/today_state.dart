part of 'today_bloc.dart';

class TodayState {
  const TodayState({
    this.isLoading = true,
    this.hasTrip = false,
    this.trip,
    this.selectedDayIndex = 0,
    this.daySpots = const [],
    this.completedDayCount = 0,
    this.totalDayCount = 0,
    this.totalTripCompleted = 0,
    this.totalTripSpots = 0,
    this.daysRemaining = 0,
    this.todayDayIndex,
  });

  final bool isLoading;
  final bool hasTrip;
  final SavedRoutine? trip;
  final int selectedDayIndex;
  final List<RoutineSpot> daySpots;
  final int completedDayCount;
  final int totalDayCount;
  final int totalTripCompleted;
  final int totalTripSpots;
  final int daysRemaining;
  final int? todayDayIndex;

  double get dayProgress =>
      totalDayCount > 0 ? completedDayCount / totalDayCount : 0.0;

  double get tripProgress =>
      totalTripSpots > 0 ? totalTripCompleted / totalTripSpots : 0.0;
}
