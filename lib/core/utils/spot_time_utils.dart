import 'package:flutter/material.dart';

/// Start/end time + duration helpers for the add-spot sheet.
abstract final class SpotTimeUtils {
  static const durationMinutes = {
    '30m': 30,
    '1h': 60,
    '1.5h': 90,
    '2h': 120,
    '2.5h': 150,
    '3h': 180,
    '4h': 240,
    '5h+': 300,
  };

  static int? durationToMinutes(String duration) => durationMinutes[duration];

  static TimeOfDay addMinutes(TimeOfDay time, int minutes) {
    final total = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  static TimeOfDay subtractMinutes(TimeOfDay time, int minutes) {
    var total = time.hour * 60 + time.minute - minutes;
    while (total < 0) {
      total += 24 * 60;
    }
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  static int minutesBetween(TimeOfDay start, TimeOfDay end) {
    var startMinutes = start.hour * 60 + start.minute;
    var endMinutes = end.hour * 60 + end.minute;
    if (endMinutes < startMinutes) endMinutes += 24 * 60;
    return endMinutes - startMinutes;
  }

  static String? minutesToDurationChip(int minutes, List<String> options) {
    String? closest;
    var closestDiff = 999999;

    for (final option in options) {
      final optionMinutes = durationToMinutes(option);
      if (optionMinutes == null) continue;
      if (optionMinutes == minutes) return option;
      final diff = (optionMinutes - minutes).abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        closest = option;
      }
    }

    return closest;
  }

  static String format24(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String? openingHoursLabel(TimeOfDay? start, TimeOfDay? end) {
    if (start == null && end == null) return null;
    if (start != null && end != null) return '${format24(start)}-${format24(end)}';
    return start != null ? format24(start) : format24(end!);
  }
}
