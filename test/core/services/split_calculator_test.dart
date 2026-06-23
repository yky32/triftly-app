import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/models/trip_models.dart';
import 'package:triftly/core/services/split_calculator.dart';

Decimal d(String value) => Decimal.parse(value);

Buddy buddy(String id, {String name = 'Buddy'}) => Buddy(
      id: id,
      name: name,
    );

Expense expense({
  required String id,
  required String paidById,
  required Decimal amount,
  required List<ExpenseSplit> splits,
}) =>
    Expense(
      id: id,
      tripId: 'trip-1',
      title: 'Test expense',
      amount: amount,
      currency: 'USD',
      paidById: paidById,
      createdAt: DateTime(2025, 1, 1),
      splits: splits,
    );

ExpenseSplit split({
  required String id,
  required String expenseId,
  required String buddyId,
  required Decimal shareAmount,
}) =>
    ExpenseSplit(
      id: id,
      expenseId: expenseId,
      buddyId: buddyId,
      splitType: SplitType.equal,
      shareAmount: shareAmount,
    );

Decimal sumShares(Map<String, Decimal> shares) =>
    shares.values.fold(Decimal.zero, (a, b) => a + b);

void expectSharesSumTo(
  Map<String, Decimal> result,
  Decimal total,
  Map<String, String> expected,
) {
  expect(result.length, expected.length);
  for (final entry in expected.entries) {
    expect(result[entry.key], d(entry.value));
  }
  expect(sumShares(result), total);
}

void main() {
group('SplitCalculator.equalSplit', () {
  test('splits 3000 evenly across 3 people', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('3000'),
      buddyIds: ['a', 'b', 'c'],
    );
    expectSharesSumTo(result, d('3000'), {
      'a': '1000',
      'b': '1000',
      'c': '1000',
    });
  });

  test('handles rounding: 1000 / 3', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('1000'),
      buddyIds: ['a', 'b', 'c'],
    );
    expectSharesSumTo(result, d('1000'), {
      'a': '333.34',
      'b': '333.33',
      'c': '333.33',
    });
  });

  test('handles rounding: 1 / 3', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('1'),
      buddyIds: ['a', 'b', 'c'],
    );
    expectSharesSumTo(result, d('1'), {
      'a': '0.34',
      'b': '0.33',
      'c': '0.33',
    });
  });

  test('single person receives entire amount', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('42.50'),
      buddyIds: ['solo'],
    );
    expectSharesSumTo(result, d('42.50'), {'solo': '42.50'});
  });

  test('zero amount splits to zero shares', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: Decimal.zero,
      buddyIds: ['a', 'b'],
    );
    expectSharesSumTo(result, Decimal.zero, {
      'a': '0',
      'b': '0',
    });
  });

  test('large amount: 999999.99 / 7', () {
    final buddies = List.generate(7, (i) => 'p$i');
    final result = SplitCalculator.equalSplit(
      totalAmount: d('999999.99'),
      buddyIds: buddies,
    );
    expect(sumShares(result), d('999999.99'));
    expect(result.length, 7);
    final perPerson = (d('999999.99') / Decimal.fromInt(7))
        .toDecimal(scaleOnInfinitePrecision: 2);
    for (final share in result.values) {
      expect((share - perPerson).abs() <= d('0.01'), isTrue);
    }
  });

  test('two people split odd cents', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('10.01'),
      buddyIds: ['a', 'b'],
    );
    expectSharesSumTo(result, d('10.01'), {
      'a': '5.01',
      'b': '5.00',
    });
  });

  test('five people split 1.00', () {
    final buddies = ['a', 'b', 'c', 'd', 'e'];
    final result = SplitCalculator.equalSplit(
      totalAmount: d('1.00'),
      buddyIds: buddies,
    );
    expect(sumShares(result), d('1.00'));
    expect(result.values.where((v) => v == d('0.20')).length, 5);
  });

  test('empty buddy list returns empty map', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('100'),
      buddyIds: const [],
    );
    expect(result, isEmpty);
  });

  test('JPY-style whole units still distribute remainder cents', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('15000'),
      buddyIds: ['a', 'b', 'c'],
    );
    expectSharesSumTo(result, d('15000'), {
      'a': '5000',
      'b': '5000',
      'c': '5000',
    });
  });

  test('preserves buddy order for remainder assignment', () {
    final result = SplitCalculator.equalSplit(
      totalAmount: d('0.03'),
      buddyIds: ['first', 'second', 'third'],
    );
    expect(result['first'], d('0.01'));
    expect(result['second'], d('0.01'));
    expect(result['third'], d('0.01'));
  });
});

group('SplitCalculator.calculateSettlement', () {
  final buddies = [
    buddy('alice', name: 'Alice'),
    buddy('bob', name: 'Bob'),
    buddy('carol', name: 'Carol'),
  ];

  test('simple: A owes B, C owes B', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'bob',
        amount: d('50'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'alice', shareAmount: d('50')),
        ],
      ),
      expense(
        id: 'e2',
        paidById: 'bob',
        amount: d('30'),
        splits: [
          split(id: 's2', expenseId: 'e2', buddyId: 'carol', shareAmount: d('30')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: buddies,
      settleCurrency: 'USD',
    );

    expect(txs.length, 2);
    expect(
      txs,
      containsAll([
        isA<SettlementTransaction>()
            .having((t) => t.fromId, 'from', 'alice')
            .having((t) => t.toId, 'to', 'bob')
            .having((t) => t.amount, 'amount', d('50')),
        isA<SettlementTransaction>()
            .having((t) => t.fromId, 'from', 'carol')
            .having((t) => t.toId, 'to', 'bob')
            .having((t) => t.amount, 'amount', d('30')),
      ]),
    );
  });

  test('four people with circular debts minimizes transactions', () {
    final four = [
      buddy('a'),
      buddy('b'),
      buddy('c'),
      buddy('d'),
    ];
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'a',
        amount: d('40'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'b', shareAmount: d('40')),
        ],
      ),
      expense(
        id: 'e2',
        paidById: 'b',
        amount: d('30'),
        splits: [
          split(id: 's2', expenseId: 'e2', buddyId: 'c', shareAmount: d('30')),
        ],
      ),
      expense(
        id: 'e3',
        paidById: 'c',
        amount: d('20'),
        splits: [
          split(id: 's3', expenseId: 'e3', buddyId: 'd', shareAmount: d('20')),
        ],
      ),
      expense(
        id: 'e4',
        paidById: 'd',
        amount: d('10'),
        splits: [
          split(id: 's4', expenseId: 'e4', buddyId: 'a', shareAmount: d('10')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: four,
      settleCurrency: 'USD',
    );

    expect(txs.length, 3);
    expect(txs.fold(Decimal.zero, (sum, t) => sum + t.amount), d('30'));
  });

  test('no debts when everyone is even', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'alice',
        amount: d('30'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'alice', shareAmount: d('10')),
          split(id: 's2', expenseId: 'e1', buddyId: 'bob', shareAmount: d('10')),
          split(id: 's3', expenseId: 'e1', buddyId: 'carol', shareAmount: d('10')),
        ],
      ),
      expense(
        id: 'e2',
        paidById: 'bob',
        amount: d('30'),
        splits: [
          split(id: 's4', expenseId: 'e2', buddyId: 'alice', shareAmount: d('10')),
          split(id: 's5', expenseId: 'e2', buddyId: 'bob', shareAmount: d('10')),
          split(id: 's6', expenseId: 'e2', buddyId: 'carol', shareAmount: d('10')),
        ],
      ),
      expense(
        id: 'e3',
        paidById: 'carol',
        amount: d('30'),
        splits: [
          split(id: 's7', expenseId: 'e3', buddyId: 'alice', shareAmount: d('10')),
          split(id: 's8', expenseId: 'e3', buddyId: 'bob', shareAmount: d('10')),
          split(id: 's9', expenseId: 'e3', buddyId: 'carol', shareAmount: d('10')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: buddies,
      settleCurrency: 'USD',
    );

    expect(txs, isEmpty);
  });

  test('one person owes everyone else', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'bob',
        amount: d('90'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'alice', shareAmount: d('30')),
          split(id: 's2', expenseId: 'e1', buddyId: 'carol', shareAmount: d('30')),
          split(id: 's3', expenseId: 'e1', buddyId: 'bob', shareAmount: d('30')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: buddies,
      settleCurrency: 'USD',
    );

    expect(txs.length, 2);
    expect(txs.every((t) => t.fromId == 'alice' || t.fromId == 'carol'), isTrue);
    expect(txs.every((t) => t.toId == 'bob'), isTrue);
    expect(txs.fold(Decimal.zero, (s, t) => s + t.amount), d('60'));
  });

  test('multiple expenses net to fewer payments', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'alice',
        amount: d('100'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'bob', shareAmount: d('50')),
          split(id: 's2', expenseId: 'e1', buddyId: 'alice', shareAmount: d('50')),
        ],
      ),
      expense(
        id: 'e2',
        paidById: 'bob',
        amount: d('40'),
        splits: [
          split(id: 's3', expenseId: 'e2', buddyId: 'alice', shareAmount: d('40')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: [buddy('alice'), buddy('bob')],
      settleCurrency: 'USD',
    );

    expect(txs.length, 1);
    expect(txs.first.fromId, 'bob');
    expect(txs.first.toId, 'alice');
    expect(txs.first.amount, d('10'));
  });

  test('ignores buddies with no activity', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'alice',
        amount: d('25'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'bob', shareAmount: d('25')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: buddies,
      settleCurrency: 'USD',
    );

    expect(txs.length, 1);
    expect(txs.first.fromId, 'bob');
    expect(txs.first.toId, 'alice');
    expect(txs.first.amount, d('25'));
  });

  test('floors settlement amounts to two decimal places', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'bob',
        amount: d('10.999'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'alice', shareAmount: d('10.999')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: [buddy('alice'), buddy('bob')],
      settleCurrency: 'USD',
    );

    expect(txs.first.amount, d('10.99'));
  });

  test('empty expenses yields no transactions', () {
    final txs = SplitCalculator.calculateSettlement(
      expenses: const [],
      buddies: buddies,
      settleCurrency: 'USD',
    );
    expect(txs, isEmpty);
  });

  test('payer not in split still credited full payment', () {
    final expenses = [
      expense(
        id: 'e1',
        paidById: 'alice',
        amount: d('50'),
        splits: [
          split(id: 's1', expenseId: 'e1', buddyId: 'bob', shareAmount: d('50')),
        ],
      ),
    ];

    final txs = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: [buddy('alice'), buddy('bob')],
      settleCurrency: 'USD',
    );

    expect(txs.length, 1);
    expect(txs.first.fromId, 'bob');
    expect(txs.first.amount, d('50'));
  });
});

group('SplitCalculator.calculateShares', () {
  test('percent split 50/50', () {
    final shares = SplitCalculator.calculateShares(
      totalAmount: d('3000'),
      entries: [
        SplitBuddyInput(buddyId: 'a', splitType: SplitType.percent, configValue: d('50')),
        SplitBuddyInput(buddyId: 'b', splitType: SplitType.percent, configValue: d('50')),
      ],
    );
    expectSharesSumTo(shares, d('3000'), {'a': '1500', 'b': '1500'});
  });

  test('amount split Wayne 1000 Alice 2000', () {
    final shares = SplitCalculator.calculateShares(
      totalAmount: d('3000'),
      entries: [
        SplitBuddyInput(buddyId: 'wayne', splitType: SplitType.amount, configValue: d('1000')),
        SplitBuddyInput(buddyId: 'alice', splitType: SplitType.amount, configValue: d('2000')),
      ],
    );
    expectSharesSumTo(shares, d('3000'), {'wayne': '1000', 'alice': '2000'});
  });

  test('share split 2:1', () {
    final shares = SplitCalculator.calculateShares(
      totalAmount: d('3000'),
      entries: [
        SplitBuddyInput(buddyId: 'wayne', splitType: SplitType.share, configValue: d('2')),
        SplitBuddyInput(buddyId: 'alice', splitType: SplitType.share, configValue: d('1')),
      ],
    );
    expectSharesSumTo(shares, d('3000'), {'wayne': '2000', 'alice': '1000'});
  });

  test('validate rejects amount splits over total', () {
    final error = SplitCalculator.validateInputs(
      totalAmount: d('100'),
      entries: [
        SplitBuddyInput(buddyId: 'a', splitType: SplitType.amount, configValue: d('80')),
        SplitBuddyInput(buddyId: 'b', splitType: SplitType.amount, configValue: d('30')),
      ],
    );
    expect(error, isNotNull);
  });

  test('validate rejects percent over 100', () {
    final error = SplitCalculator.validateInputs(
      totalAmount: d('100'),
      entries: [
        SplitBuddyInput(buddyId: 'a', splitType: SplitType.percent, configValue: d('60')),
        SplitBuddyInput(buddyId: 'b', splitType: SplitType.percent, configValue: d('50')),
      ],
    );
    expect(error, isNotNull);
  });
});

}
