import 'package:intl/intl.dart';

/// Single source of truth for date-related logic used across widgets and pages.
class DateHelpers {
  DateHelpers._();

  // ---------------------------------------------------------------------------
  // Calendar math
  // ---------------------------------------------------------------------------

  /// Last calendar day of the month (28, 29, 30, or 31).
  /// Handles February and leap years (e.g. Feb 2024 → 29, Feb 2023 → 28).
  static int lastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Number of calendar days between [start] and [end] inclusive.
  /// Uses date-only (no time), so correct across month boundaries and leap years.
  static int calendarDaysBetween(DateTime start, DateTime end) {
    final s = dateOnly(start);
    final e = dateOnly(end);
    return e.difference(s).inDays + 1;
  }

  /// Returns a [DateTime] with the same date and time zeroed (00:00:00.000).
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// True if [a] and [b] represent the same calendar day (ignoring time).
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// True if [date] is today (same calendar day as [DateTime.now()]).
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // Formatting (locale-aware via [DateFormat] when used in context with locale)
  // ---------------------------------------------------------------------------

  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _weekdayShort = DateFormat('EEE');
  static final DateFormat _dateShort = DateFormat('MMM d, yyyy');

  /// Format as full month + year (e.g. "March 2026").
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Format as short weekday (e.g. "Mon", "Tue").
  static String formatWeekdayShort(DateTime date) {
    return _weekdayShort.format(date);
  }

  /// Format as short date (e.g. "Mar 5, 2026").
  static String formatDateShort(DateTime date) {
    return _dateShort.format(date);
  }

  /// Format as weekday + short date (e.g. "Mon, Mar 5, 2026").
  static String formatWeekdayAndDate(DateTime date) {
    return '${formatWeekdayShort(date)}, ${formatDateShort(date)}';
  }
}
