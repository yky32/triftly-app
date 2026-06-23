import 'package:decimal/decimal.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/utils/currency_conversion.dart';

abstract final class SpendTabUtils {
  static Decimal tripTotal({
    required List<Expense> expenses,
    required String tripCurrency,
  }) {
    return expenses.fold<Decimal>(
      Decimal.zero,
      (sum, e) =>
          sum +
          CurrencyConversion.toTripCurrency(
            amount: e.amount,
            currency: e.currency,
            tripCurrency: tripCurrency,
          ),
    );
  }

  static Decimal dayTotal({
    required List<Expense> expenses,
    required String tripCurrency,
  }) {
    return tripTotal(expenses: expenses, tripCurrency: tripCurrency);
  }

  static Map<TripDay?, List<Expense>> groupByDay({
    required Trip trip,
    required List<TripDay> days,
    required List<Expense> expenses,
  }) {
    final map = <TripDay?, List<Expense>>{};
    for (final expense in expenses) {
      TripDay? day;
      if (expense.dayId != null) {
        for (final d in days) {
          if (d.id == expense.dayId) {
            day = d;
            break;
          }
        }
      }
      map.putIfAbsent(day, () => []).add(expense);
    }

    final todayDayNumber = trip.currentDayNumber;
    final sortedKeys = map.keys.toList()
      ..sort((a, b) {
        if (todayDayNumber != null && trip.isInProgress) {
          final aIsToday = a?.dayNumber == todayDayNumber;
          final bIsToday = b?.dayNumber == todayDayNumber;
          if (aIsToday != bIsToday) return aIsToday ? -1 : 1;
        }
        if (a == null && b == null) return 0;
        if (a == null) return 1;
        if (b == null) return -1;
        return a.dayNumber.compareTo(b.dayNumber);
      });

    return {for (final key in sortedKeys) key: map[key]!};
  }

  static bool isTodayDay(Trip trip, TripDay day) {
    final current = trip.currentDayNumber;
    return current != null && day.dayNumber == current;
  }
}
