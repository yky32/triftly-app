import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/models/settlement_record.dart';
import 'package:triftly/core/models/trip_models.dart';
import 'package:triftly/core/repositories/supabase_trip_mapper.dart';

void main() {
  group('SupabaseTripMapper', () {
    final trip = Trip(
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Tokyo',
      destination: 'Japan',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 3, 5),
      defaultCurrency: 'JPY',
      buddies: const [
        Buddy(
          id: '22222222-2222-4222-8222-222222222222',
          name: 'Alex',
          isMe: true,
          userId: '33333333-3333-4333-8333-333333333333',
        ),
      ],
      shareToken: 'abc123',
      ownerId: '33333333-3333-4333-8333-333333333333',
      createdAt: DateTime(2026, 1, 1, 12),
      updatedAt: DateTime(2026, 1, 2, 12),
    );

    test('daysForTrip matches trip length', () {
      final days = SupabaseTripMapper.daysForTrip(trip);
      expect(days.length, trip.numberOfDays);
      expect(days.first.dayNumber, 1);
      expect(days.last.id, '${trip.id}-d${trip.numberOfDays}');
    });

    test('tripToRow uses date-only fields', () {
      final row = SupabaseTripMapper.tripToRow(trip);
      expect(row['start_date'], '2026-03-01');
      expect(row['end_date'], '2026-03-05');
      expect(row['owner_id'], trip.ownerId);
    });

    test('trip round-trip preserves buddies and dates', () {
      final row = SupabaseTripMapper.tripToRow(trip);
      final restored = SupabaseTripMapper.tripFromRow(row, trip.buddies);
      expect(restored.name, trip.name);
      expect(restored.startDate.year, trip.startDate.year);
      expect(restored.buddies.first.name, 'Alex');
      expect(restored.isActive, true);
    });

    test('expense and split round-trip', () {
      const expenseId = '44444444-4444-4444-8444-444444444444';
      final expense = Expense(
        id: expenseId,
        tripId: trip.id,
        title: 'Dinner',
        amount: Decimal.parse('120.50'),
        currency: 'JPY',
        paidById: trip.buddies.first.id,
        createdAt: DateTime(2026, 3, 2),
        splits: [
          ExpenseSplit(
            id: '55555555-5555-4555-8555-555555555555',
            expenseId: expenseId,
            buddyId: trip.buddies.first.id,
            splitType: SplitType.equal,
            shareAmount: Decimal.parse('120.50'),
          ),
        ],
      );

      final expenseRow = SupabaseTripMapper.expenseToRow(expense);
      final splitRow = SupabaseTripMapper.splitToRow(expense.splits.first);
      final restored = SupabaseTripMapper.expenseFromRow(
        expenseRow,
        [SupabaseTripMapper.splitFromRow(splitRow)],
      );

      expect(restored.title, 'Dinner');
      expect(restored.amount, Decimal.parse('120.50'));
      expect(restored.splits.first.shareAmount, Decimal.parse('120.50'));
    });

    test('settlement round-trip', () {
      final record = SettlementRecord(
        id: '66666666-6666-4666-8666-666666666666',
        tripId: trip.id,
        fromBuddyId: trip.buddies.first.id,
        toBuddyId: trip.buddies.first.id,
        amount: Decimal.parse('50'),
        currency: 'JPY',
        paidAt: DateTime(2026, 3, 3, 18, 30),
      );

      final row = SupabaseTripMapper.settlementToRow(record);
      final restored = SupabaseTripMapper.settlementFromRow(row);
      expect(restored.amount, Decimal.parse('50'));
      expect(restored.paidAt.hour, 18);
    });
  });
}
