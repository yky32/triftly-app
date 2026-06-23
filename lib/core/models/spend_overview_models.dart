import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'trip_models.dart';
import '../services/split_calculator.dart';

/// One expense with trip context for global lists.
class SpendTransactionLine extends Equatable {
  const SpendTransactionLine({
    required this.expense,
    required this.trip,
  });

  final Expense expense;
  final Trip trip;

  @override
  List<Object?> get props => [expense.id, trip.id];
}

/// Spending snapshot for a single trip.
class TripSpendSnapshot extends Equatable {
  const TripSpendSnapshot({
    required this.trip,
    required this.expenses,
    required this.tripTotal,
    required this.myPaid,
    required this.myShare,
    required this.myNet,
    required this.settlements,
    this.meBuddy,
  });

  final Trip trip;
  final List<Expense> expenses;
  final Decimal tripTotal;
  final Decimal myPaid;
  final Decimal myShare;
  /// Positive = others owe me; negative = I owe others.
  final Decimal myNet;
  final List<SettlementTransaction> settlements;
  final Buddy? meBuddy;

  bool get hasExpenses => expenses.isNotEmpty;

  String get currency => trip.defaultCurrency;

  @override
  List<Object?> get props => [trip.id, expenses.length, myNet];
}

/// Aggregated personal spending across all trips.
class GlobalSpendOverview extends Equatable {
  const GlobalSpendOverview({
    required this.tripSnapshots,
    required this.recentTransactions,
    required this.meDisplayName,
  });

  final List<TripSpendSnapshot> tripSnapshots;
  final List<SpendTransactionLine> recentTransactions;
  final String meDisplayName;

  List<TripSpendSnapshot> get tripsWithSpending =>
      tripSnapshots.where((s) => s.hasExpenses).toList();

  List<TripSpendSnapshot> get activeTripsWithSpending => tripSnapshots
      .where((s) => s.hasExpenses && s.trip.isInProgress)
      .toList();

  int get totalExpenseCount =>
      tripSnapshots.fold(0, (sum, s) => sum + s.expenses.length);

  bool get isEmpty => tripsWithSpending.isEmpty;

  @override
  List<Object?> get props => [tripSnapshots.length, recentTransactions.length];
}
