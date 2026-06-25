import 'package:decimal/decimal.dart';
import '../models/spend_overview_models.dart';
import '../models/settlement_record.dart';
import '../models/trip_models.dart';
import '../models/user.dart';
import '../repositories/trip_repository.dart';
import '../repositories/hive_trip_repository.dart';
import '../services/me_identity_service.dart';
import '../services/profile_preferences.dart';
import '../utils/currency_conversion.dart';
import 'split_calculator.dart';

/// Loads and aggregates expenses for global Spend page and shared previews.
class SpendLedgerService {
  SpendLedgerService({
    TripRepository? repository,
    ProfilePreferences? preferences,
  })  : _repository = repository ?? HiveTripRepository.instance,
        _preferences = preferences ?? ProfilePreferences.instance;

  final TripRepository _repository;
  final ProfilePreferences _preferences;

  Future<GlobalSpendOverview> loadGlobalOverview({User? user}) async {
    final trips = _repository.allTrips();
    final details = await Future.wait(trips.map((trip) => _repository.loadDetail(trip.id)));

    final snapshots = <TripSpendSnapshot>[];
    final recent = <SpendTransactionLine>[];

    for (var i = 0; i < trips.length; i++) {
      final trip = trips[i];
      final detail = details[i];
      if (detail == null) continue;

      final activeExpenses = detail.expenses.where((e) => e.isActive).toList();
      final activeSettlements = detail.settlements.where((s) => s.isActive).toList();
      final me = MeIdentityService.buddyForTrip(
        trip,
        user: user,
        preferences: _preferences,
      );
      final snapshot = _snapshotForTrip(
        trip: trip,
        expenses: activeExpenses,
        settlements: activeSettlements,
        me: me,
      );
      snapshots.add(snapshot);

      for (final expense in activeExpenses) {
        recent.add(SpendTransactionLine(expense: expense, trip: trip, meBuddy: me));
      }
    }

    recent.sort((a, b) => b.expense.createdAt.compareTo(a.expense.createdAt));

    return GlobalSpendOverview(
      tripSnapshots: snapshots,
      recentTransactions: recent,
      meDisplayName: MeIdentityService.displayName(user: user, preferences: _preferences),
    );
  }

  TripSpendSnapshot snapshotForTrip(
    Trip trip,
    List<Expense> expenses, {
    User? user,
    List<SettlementRecord> settlements = const [],
  }) {
    final me = MeIdentityService.buddyForTrip(
      trip,
      user: user,
      preferences: _preferences,
    );
    return _snapshotForTrip(
      trip: trip,
      expenses: expenses,
      settlements: settlements,
      me: me,
    );
  }

  TripSpendSnapshot _snapshotForTrip({
    required Trip trip,
    required List<Expense> expenses,
    required List<SettlementRecord> settlements,
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
        if (expense.paidById == me.id) myPaid += expense.amount;
        for (final split in expense.splits) {
          if (split.buddyId == me.id) myShare += split.shareAmount;
        }
      }
      for (final record in settlements) {
        final amount = CurrencyConversion.toTripCurrency(
          amount: record.amount,
          currency: record.currency,
          tripCurrency: currency,
        );
        if (record.fromBuddyId == me.id) myPaid += amount;
        if (record.toBuddyId == me.id) myShare += amount;
      }
    }

    final settlementsTx = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: trip.buddies,
      settleCurrency: currency,
      recordedSettlements: settlements,
    );

    return TripSpendSnapshot(
      trip: trip,
      expenses: expenses,
      tripTotal: tripTotal,
      myPaid: myPaid,
      myShare: myShare,
      myNet: myPaid - myShare,
      settlements: settlementsTx,
      meBuddy: me,
    );
  }
}
