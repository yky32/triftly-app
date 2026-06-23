import 'package:decimal/decimal.dart';
import '../models/spend_overview_models.dart';
import '../models/trip_models.dart';
import '../utils/currency_conversion.dart';
import 'split_calculator.dart';
import 'trip_store.dart';

/// Demo identity until profile ↔ buddy mapping ships.
abstract final class SpendMeIdentity {
  static const defaultName = 'Wayne';

  static Buddy? buddyForTrip(Trip trip, {String name = defaultName}) {
    for (final buddy in trip.buddies) {
      if (buddy.name == name) return buddy;
    }
    return trip.buddies.isNotEmpty ? trip.buddies.first : null;
  }
}

/// Loads and aggregates expenses for global Spend page and shared previews.
class SpendLedgerService {
  SpendLedgerService({TripStore? store}) : _store = store ?? TripStore.instance;

  final TripStore _store;

  Future<GlobalSpendOverview> loadGlobalOverview({
    String meName = SpendMeIdentity.defaultName,
  }) async {
    final trips = _store.allTrips();
    final snapshots = <TripSpendSnapshot>[];
    final recent = <SpendTransactionLine>[];

    for (final trip in trips) {
      final detail = await _store.loadDetail(trip.id);
      if (detail == null) continue;

      final snapshot = _snapshotForTrip(
        trip: trip,
        expenses: detail.expenses,
        meName: meName,
      );
      snapshots.add(snapshot);

      for (final expense in detail.expenses) {
        recent.add(SpendTransactionLine(expense: expense, trip: trip));
      }
    }

    recent.sort((a, b) => b.expense.createdAt.compareTo(a.expense.createdAt));

    return GlobalSpendOverview(
      tripSnapshots: snapshots,
      recentTransactions: recent.take(20).toList(),
      meDisplayName: meName,
    );
  }

  TripSpendSnapshot snapshotForTrip(Trip trip, List<Expense> expenses, {String meName = SpendMeIdentity.defaultName}) {
    return _snapshotForTrip(trip: trip, expenses: expenses, meName: meName);
  }

  TripSpendSnapshot _snapshotForTrip({
    required Trip trip,
    required List<Expense> expenses,
    required String meName,
  }) {
    final currency = trip.defaultCurrency;
    final me = SpendMeIdentity.buddyForTrip(trip, name: meName);

    final tripTotal = expenses.fold<Decimal>(
      Decimal.zero,
      (sum, e) =>
          sum +
          CurrencyConversion.toTripCurrency(
            amount: e.amount,
            currency: e.currency,
            tripCurrency: currency,
          ),
    );

    var myPaid = Decimal.zero;
    var myShare = Decimal.zero;

    if (me != null) {
      for (final raw in expenses) {
        final expense = SplitCalculator.normalizeExpense(raw, currency);
        if (expense.paidById == me.id) {
          myPaid += expense.amount;
        }
        for (final split in expense.splits) {
          if (split.buddyId == me.id) {
            myShare += split.shareAmount;
          }
        }
      }
    }

    final settlements = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: trip.buddies,
      settleCurrency: currency,
    );

    return TripSpendSnapshot(
      trip: trip,
      expenses: expenses,
      tripTotal: tripTotal,
      myPaid: myPaid,
      myShare: myShare,
      myNet: myPaid - myShare,
      settlements: settlements,
      meBuddy: me,
    );
  }
}
