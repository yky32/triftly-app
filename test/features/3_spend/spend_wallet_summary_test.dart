import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/models/spend_overview_models.dart';
import 'package:triftly/core/models/trip_models.dart';
import 'package:triftly/features/3_spend/presentation/spend_wallet_summary.dart';

Trip _trip({
  required String id,
  required String currency,
  TripPhase phase = TripPhase.inProgress,
}) {
  final now = DateTime.now();
  final (start, end) = switch (phase) {
    TripPhase.inProgress => (now.subtract(const Duration(days: 1)), now.add(const Duration(days: 5))),
    TripPhase.upcoming => (now.add(const Duration(days: 10)), now.add(const Duration(days: 15))),
    TripPhase.completed => (now.subtract(const Duration(days: 20)), now.subtract(const Duration(days: 10))),
  };

  return Trip(
    id: id,
    name: id,
    destination: 'Tokyo, Japan',
    startDate: start,
    endDate: end,
    defaultCurrency: currency,
    buddies: const [Buddy(id: 'me', name: 'Wayne')],
    createdAt: now,
  );
}

TripSpendSnapshot _snap({
  required Trip trip,
  Decimal? myPaid,
  Decimal? myShare,
  bool hasExpenses = true,
}) {
  final paid = myPaid ?? d('0');
  final share = myShare ?? d('0');
  final expenses = hasExpenses
      ? [
          Expense(
            id: 'e-${trip.id}',
            tripId: trip.id,
            title: 'Test',
            amount: Decimal.fromInt(10),
            currency: trip.defaultCurrency,
            paidById: 'me',
            createdAt: DateTime(2025, 1, 1),
          ),
        ]
      : <Expense>[];

  return TripSpendSnapshot(
    trip: trip,
    expenses: expenses,
    tripTotal: Decimal.fromInt(100),
    myPaid: paid,
    myShare: share,
    myNet: paid - share,
    settlements: const [],
    meBuddy: const Buddy(id: 'me', name: 'Wayne'),
  );
}

void main() {
  group('SpendWalletSummary', () {
    test('is settled when all currency buckets net to zero', () {
      final overview = GlobalSpendOverview(
        tripSnapshots: [
          _snap(trip: _trip(id: 'a', currency: 'JPY'), myPaid: d('50'), myShare: d('50')),
        ],
        recentTransactions: const [],
        meDisplayName: 'Wayne',
      );

      final summary = SpendWalletSummary.from(overview);
      expect(summary.isSettled, isTrue);
      expect(summary.net, d('0'));
    });

    test('aggregates buckets per currency and marks multi-currency', () {
      final overview = GlobalSpendOverview(
        tripSnapshots: [
          _snap(trip: _trip(id: 'jpy', currency: 'JPY'), myPaid: d('100'), myShare: d('40')),
          _snap(trip: _trip(id: 'thb', currency: 'THB'), myPaid: d('20'), myShare: d('50')),
        ],
        recentTransactions: const [],
        meDisplayName: 'Wayne',
      );

      final summary = SpendWalletSummary.from(overview);
      expect(summary.isMultiCurrency, isTrue);
      expect(summary.primary.currency, anyOf('JPY', 'THB'));
      expect(summary.otherCurrencies, hasLength(1));
      expect(summary.hkdEquivalentNet, isNotNull);
    });
  });

  group('GlobalSpendOverview', () {
    test('sortedTrips filters by trip phase', () {
      final activeHigh = _snap(
        trip: _trip(id: 'active', currency: 'JPY', phase: TripPhase.inProgress),
        myPaid: d('100'),
        myShare: d('10'),
      );
      final completed = _snap(
        trip: _trip(id: 'done', currency: 'JPY', phase: TripPhase.completed),
        myPaid: d('200'),
        myShare: d('0'),
      );
      final activeLow = _snap(
        trip: _trip(id: 'active-low', currency: 'JPY', phase: TripPhase.inProgress),
        myPaid: d('30'),
        myShare: d('20'),
      );

      final overview = GlobalSpendOverview(
        tripSnapshots: [completed, activeLow, activeHigh],
        recentTransactions: const [],
        meDisplayName: 'Wayne',
      );

      final activeTrips = overview.sortedTrips(phase: TripPhase.inProgress);
      expect(activeTrips, hasLength(2));
      expect(activeTrips.first.trip.id, 'active');
      expect(overview.sortedTrips(phase: TripPhase.completed), hasLength(1));
    });

    test('active phase filter keeps only in-progress trips', () {
      final overview = GlobalSpendOverview(
        tripSnapshots: [
          _snap(trip: _trip(id: 'active', currency: 'JPY', phase: TripPhase.inProgress)),
          _snap(trip: _trip(id: 'done', currency: 'JPY', phase: TripPhase.completed)),
        ],
        recentTransactions: const [],
        meDisplayName: 'Wayne',
      );

      expect(overview.sortedTrips(phase: TripPhase.inProgress), hasLength(1));
    });
  });
}

Decimal d(String value) => Decimal.parse(value);
