part of 'today_bloc.dart';

class TodayState {
  const TodayState({
    this.isLoading = true,
    this.hasActiveTrip = false,
    this.activeTrip,
    this.todaySpots = const [],
    this.completedTodayCount = 0,
    this.totalTodayCount = 0,
    this.totalTripCompleted = 0,
    this.totalTripSpots = 0,
    this.daysRemaining = 0,
  });

  final bool isLoading;
  final bool hasActiveTrip;
  final SavedRoutine? activeTrip;
  final List<RoutineSpot> todaySpots;
  final int completedTodayCount;
  final int totalTodayCount;
  final int totalTripCompleted;
  final int totalTripSpots;
  final int daysRemaining;

  /// Progress fraction for today (0.0 to 1.0).
  double get todayProgress =>
      totalTodayCount > 0 ? completedTodayCount / totalTodayCount : 0.0;

  /// Progress fraction for the entire trip (0.0 to 1.0).
  double get tripProgress =>
      totalTripSpots > 0 ? totalTripCompleted / totalTripSpots : 0.0;

  TodayState copyWith({
    bool? isLoading,
    bool? hasActiveTrip,
    SavedRoutine? activeTrip,
    List<RoutineSpot>? todaySpots,
    int? completedTodayCount,
    int? totalTodayCount,
    int? totalTripCompleted,
    int? totalTripSpots,
    int? daysRemaining,
  }) {
    return TodayState(
      isLoading: isLoading ?? this.isLoading,
      hasActiveTrip: hasActiveTrip ?? this.hasActiveTrip,
      activeTrip: activeTrip ?? this.activeTrip,
      todaySpots: todaySpots ?? this.todaySpots,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      totalTodayCount: totalTodayCount ?? this.totalTodayCount,
      totalTripCompleted: totalTripCompleted ?? this.totalTripCompleted,
      totalTripSpots: totalTripSpots ?? this.totalTripSpots,
      daysRemaining: daysRemaining ?? this.daysRemaining,
    );
  }
}
