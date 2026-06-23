import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'trip_models.dart';
import '../services/split_calculator.dart';

/// One expense with trip context for global lists.
class SpendTransactionLine extends Equatable {
  const SpendTransactionLine({
    required this.expense,
    required this.trip,
    required this.meBuddy,
  });

  final Expense expense;
  final Trip trip;
  final Buddy? meBuddy;

  String get currency => trip.defaultCurrency;

  Decimal get myShare {
    final me = meBuddy;
    if (me == null) return Decimal.zero;
    var share = Decimal.zero;
    for (final split in expense.splits) {
      if (split.buddyId == me.id) share += split.shareAmount;
    }
    return share;
  }

  bool get iPaid => meBuddy != null && expense.paidById == meBuddy!.id;

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

/// One line in the cross-trip "who owes whom" list.
class BuddyOweLine extends Equatable {
  const BuddyOweLine({
    required this.counterparty,
    required this.trip,
    required this.amount,
    required this.currency,
  });

  final Buddy counterparty;
  final Trip trip;
  /// Positive = counterparty owes me; negative = I owe counterparty.
  final Decimal amount;
  final String currency;

  @override
  List<Object?> get props => [counterparty.id, trip.id, amount, currency];
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

  Map<TripPhase, int> get phaseCounts => {
        TripPhase.inProgress: tripsWithSpending.where((s) => s.trip.isInProgress).length,
        TripPhase.upcoming: tripsWithSpending.where((s) => s.trip.isUpcoming).length,
        TripPhase.completed: tripsWithSpending.where((s) => s.trip.isCompleted).length,
      };

  TripPhase defaultPhase() {
    final counts = phaseCounts;
    if (counts[TripPhase.inProgress]! > 0) return TripPhase.inProgress;
    if (counts[TripPhase.upcoming]! > 0) return TripPhase.upcoming;
    return TripPhase.completed;
  }

  List<TripSpendSnapshot> sortedTrips({required TripPhase phase}) {
    final sorted = tripsWithSpending.where((s) => s.trip.phase == phase).toList();
    sorted.sort((a, b) => b.myNet.abs().compareTo(a.myNet.abs()));
    return sorted;
  }

  List<BuddyOweLine> get buddyOweLines {
    final lines = <BuddyOweLine>[];
    for (final snap in tripSnapshots) {
      final me = snap.meBuddy;
      if (me == null || snap.settlements.isEmpty) continue;

      for (final tx in snap.settlements) {
        if (tx.toId == me.id) {
          final from = _buddy(snap.trip, tx.fromId);
          lines.add(BuddyOweLine(
            counterparty: from,
            trip: snap.trip,
            amount: tx.amount,
            currency: snap.currency,
          ));
        } else if (tx.fromId == me.id) {
          final to = _buddy(snap.trip, tx.toId);
          lines.add(BuddyOweLine(
            counterparty: to,
            trip: snap.trip,
            amount: -tx.amount,
            currency: snap.currency,
          ));
        }
      }
    }

    lines.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return lines;
  }

  static Buddy _buddy(Trip trip, String id) => trip.buddies.firstWhere(
        (b) => b.id == id,
        orElse: () => Buddy(id: id, name: '?'),
      );

  @override
  List<Object?> get props => [tripSnapshots.length, recentTransactions.length];
}
