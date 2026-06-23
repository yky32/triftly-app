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
    final details = await Future.wait(trips.map((trip) => _store.loadDetail(trip.id)));

    final snapshots = <TripSpendSnapshot>[];
    final recent = <SpendTransactionLine>[];

    for (var i = 0; i < trips.length; i++) {
      final trip = trips[i];
      final detail = details[i];
      if (detail == null) continue;

      final me = SpendMeIdentity.buddyForTrip(trip, name: meName);
      final snapshot = _snapshotForTrip(
        trip: trip,
        expenses: detail.expenses,
        me: me,
      );
      snapshots.add(snapshot);

      for (final expense in detail.expenses) {
        recent.add(SpendTransactionLine(expense: expense, trip: trip, meBuddy: me));
      }
    }

    recent.sort((a, b) => b.expense.createdAt.compareTo(a.expense.createdAt));

    return GlobalSpendOverview(
      tripSnapshots: snapshots,
      recentTransactions: recent,
      meDisplayName: meName,
    );
  }

  TripSpendSnapshot snapshotForTrip(Trip trip, List<Expense> expenses, {String meName = SpendMeIdentity.defaultName}) {
    final me = SpendMeIdentity.buddyForTrip(trip, name: meName);
    return _snapshotForTrip(trip: trip, expenses: expenses, me: me);
  }

  TripSpendSnapshot _snapshotForTrip({
    required Trip trip,
    required List<Expense> expenses,
    required Buddy? me,
  }) {
    final currency = trip.defaultCurrency;

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
