import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/models/trip_models.dart';

void main() {
  test('Expense.fromMap accepts Hive-style nested maps', () {
    final expense = Expense.fromMap({
      'id': 'e1',
      'trip_id': 't1',
      'day_id': 'd1',
      'title': 'Lunch',
      'amount': '100.00',
      'currency': 'HKD',
      'paid_by_id': 'b1',
      'category': 'food',
      'splits': <dynamic>[
        <dynamic, dynamic>{
          'id': 's1',
          'expense_id': 'e1',
          'buddy_id': 'b1',
          'split_type': 'equal',
          'share_amount': '50.00',
        },
        <dynamic, dynamic>{
          'id': 's2',
          'expense_id': 'e1',
          'buddy_id': 'b2',
          'split_type': 'equal',
          'share_amount': '50.00',
        },
      ],
      'created_at': '2026-01-01T12:00:00.000',
      'is_active': true,
    });

    expect(expense.splits, hasLength(2));
    expect(expense.splits.first.buddyId, 'b1');
  });
}
