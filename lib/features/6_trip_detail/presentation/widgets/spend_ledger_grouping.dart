import 'package:decimal/decimal.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_conversion.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';

enum SpendGroupBy { day, category, person }

class SpendLedgerSection {
  const SpendLedgerSection({
    required this.title,
    required this.expenses,
    required this.total,
    this.badge,
  });

  final String title;
  final String? badge;
  final Decimal total;
  final List<Expense> expenses;
}

abstract final class SpendLedgerGrouping {
  static Decimal amountInTripCurrency(Expense expense, String tripCurrency) {
    return CurrencyConversion.toTripCurrency(
      amount: expense.amount,
      currency: expense.currency,
      tripCurrency: tripCurrency,
    );
  }

  static Decimal sumExpenses(List<Expense> expenses, String tripCurrency) {
    return expenses.fold<Decimal>(
      Decimal.zero,
      (sum, expense) => sum + amountInTripCurrency(expense, tripCurrency),
    );
  }

  static List<Expense> filterByCategory(List<Expense> expenses, String? category) {
    if (category == null) return expenses;
    return expenses.where((expense) => expense.category == category).toList();
  }

  static Map<String, Decimal> totalsByCategory(List<Expense> expenses, String tripCurrency) {
    final totals = <String, Decimal>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? Decimal.zero) + amountInTripCurrency(expense, tripCurrency);
    }
    return totals;
  }

  static List<({SpotCategory category, Decimal total})> sortedCategoryTotals(
    List<Expense> expenses,
    String tripCurrency,
  ) {
    final totals = totalsByCategory(expenses, tripCurrency);
    final rows = totals.entries.map((entry) {
      final category = SpotCategory.values.firstWhere(
        (value) => value.value == entry.key,
        orElse: () => SpotCategory.other,
      );
      return (category: category, total: entry.value);
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return rows;
  }

  static List<SpendLedgerSection> buildSections({
    required SpendGroupBy groupBy,
    required List<Expense> expenses,
    required List<TripDay> days,
    required Trip trip,
    required List<Buddy> buddies,
  }) {
    return switch (groupBy) {
      SpendGroupBy.day => _sectionsByDay(expenses, days, trip),
      SpendGroupBy.category => _sectionsByCategory(expenses, trip.defaultCurrency),
      SpendGroupBy.person => _sectionsByPerson(expenses, buddies, trip.defaultCurrency),
    };
  }

  static List<SpendLedgerSection> _sectionsByDay(
    List<Expense> expenses,
    List<TripDay> days,
    Trip trip,
  ) {
    final map = <TripDay?, List<Expense>>{};
    for (final expense in expenses) {
      TripDay? day;
      if (expense.dayId != null) {
        for (final candidate in days) {
          if (candidate.id == expense.dayId) {
            day = candidate;
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

    return sortedKeys.map((day) {
      final dayExpenses = map[day]!;
      final isToday = todayDayNumber != null && day?.dayNumber == todayDayNumber;
      return SpendLedgerSection(
        title: day == null
            ? 'Unassigned'
            : '${day.displayTitleLine} · ${DateFormatters.shortDate(day.date)}',
        badge: isToday ? 'Today' : null,
        total: sumExpenses(dayExpenses, trip.defaultCurrency),
        expenses: dayExpenses,
      );
    }).toList();
  }

  static List<SpendLedgerSection> _sectionsByCategory(
    List<Expense> expenses,
    String tripCurrency,
  ) {
    final map = <String, List<Expense>>{};
    for (final expense in expenses) {
      map.putIfAbsent(expense.category, () => []).add(expense);
    }

    final sorted = sortedCategoryTotals(expenses, tripCurrency);
    return sorted.map((row) {
      final categoryExpenses = map[row.category.value]!;
      return SpendLedgerSection(
        title: '${row.category.emoji} ${row.category.label}',
        total: row.total,
        expenses: categoryExpenses,
      );
    }).toList();
  }

  static List<SpendLedgerSection> _sectionsByPerson(
    List<Expense> expenses,
    List<Buddy> buddies,
    String tripCurrency,
  ) {
    final map = <String, List<Expense>>{};
    for (final expense in expenses) {
      map.putIfAbsent(expense.paidById, () => []).add(expense);
    }

    final rows = map.entries.map((entry) {
      final buddy = buddies.firstWhere(
        (candidate) => candidate.id == entry.key,
        orElse: () => Buddy(id: entry.key, name: 'Unknown'),
      );
      final personExpenses = entry.value;
      return (
        buddy: buddy,
        total: sumExpenses(personExpenses, tripCurrency),
        expenses: personExpenses,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return rows
        .map(
          (row) => SpendLedgerSection(
            title: row.buddy.name,
            badge: '${row.expenses.length} paid',
            total: row.total,
            expenses: row.expenses,
          ),
        )
        .toList();
  }

  static String? dayLabelForExpense(Expense expense, List<TripDay> days) {
    if (expense.dayId == null) return null;
    for (final day in days) {
      if (day.id == expense.dayId) {
        return day.displayTitleLine;
      }
    }
    return null;
  }

  static String formatTotal(Decimal total, String currency) {
    final symbol = CurrencyUtils.symbolFor(currency);
    return '$symbol${CurrencyUtils.formatDecimal(total)}';
  }
}
