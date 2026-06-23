import 'package:flutter/material.dart';
import '../models/trip_models.dart';
import 'spot_time_utils.dart';

/// Today-mode helpers for trip execution on the Plan tab.
abstract final class TodayPlanUtils {
  static int initialDayIndex(Trip? trip, List<TripDay> days) {
    if (trip == null || days.isEmpty) return 0;
    final current = trip.currentDayNumber;
    if (current != null && current > 0 && current <= days.length) {
      return current - 1;
    }
    return 0;
  }

  static bool isSelectedDayToday(Trip trip, List<TripDay> days, int selectedDayIndex) {
    final current = trip.currentDayNumber;
    if (current == null || days.isEmpty) return false;
    if (selectedDayIndex < 0 || selectedDayIndex >= days.length) return false;
    return days[selectedDayIndex].dayNumber == current;
  }

  static int? todayDayIndex(Trip trip, List<TripDay> days) {
    final current = trip.currentDayNumber;
    if (current == null || days.isEmpty) return null;
    final index = current - 1;
    if (index < 0 || index >= days.length) return null;
    return index;
  }

  /// Next unvisited spot on [daySpots] by planned start time; falls back to first unvisited.
  static Spot? nextSpotNow(List<Spot> daySpots, {TimeOfDay? now}) {
    final clock = now ?? TimeOfDay.now();
    final nowMinutes = clock.hour * 60 + clock.minute;
    final unvisited = daySpots.where((s) => !s.visited).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (unvisited.isEmpty) return null;

    Spot? upcoming;
    int? upcomingMinutes;

    for (final spot in unvisited) {
      final start = SpotTimeUtils.parseStartTime(spot.openingHours);
      if (start == null) continue;
      final startMinutes = start.hour * 60 + start.minute;
      if (startMinutes >= nowMinutes) {
        if (upcomingMinutes == null || startMinutes < upcomingMinutes) {
          upcoming = spot;
          upcomingMinutes = startMinutes;
        }
      }
    }

    return upcoming ?? unvisited.first;
  }
}
