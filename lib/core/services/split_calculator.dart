import 'package:decimal/decimal.dart';
import '../models/trip_models.dart';

/// 100% accurate split calculations using Decimal.
/// NEVER use double/num for money.
class SplitCalculator {
  /// Calculate equal split for an expense.
  static Map<String, Decimal> equalSplit({
    required Decimal totalAmount,
    required List<String> buddyIds,
  }) {
    if (buddyIds.isEmpty) return {};
    final splitCount = Decimal.fromInt(buddyIds.length);
    final perPerson = (totalAmount / splitCount).toDecimal(scaleOnInfinitePrecision: 10);
    final perPersonRounded = _floorTo2(perPerson);
    final totalDistributed = perPersonRounded * Decimal.fromInt(buddyIds.length);
    final remainderCents = _floorTo2(totalAmount - totalDistributed)
        .shift(2)
        .toBigInt()
        .toInt();

    final result = <String, Decimal>{};
    for (int i = 0; i < buddyIds.length; i++) {
      final extra = i < remainderCents
          ? Decimal.parse('0.01')
          : Decimal.zero;
      result[buddyIds[i]] = perPersonRounded + extra;
    }
    return result;
  }

  /// Calculate who owes whom after all expenses.
  static List<SettlementTransaction> calculateSettlement({
    required List<Expense> expenses,
    required List<Buddy> buddies,
  }) {
    final balances = <String, Decimal>{};
    for (final buddy in buddies) {
      balances[buddy.id] = Decimal.zero;
    }

    for (final expense in expenses) {
      balances[expense.paidById] =
          (balances[expense.paidById] ?? Decimal.zero) + expense.amount;
      for (final split in expense.splits) {
        balances[split.buddyId] =
            (balances[split.buddyId] ?? Decimal.zero) - split.shareAmount;
      }
    }

    return _minimizeTransactions(balances);
  }

  static List<SettlementTransaction> _minimizeTransactions(
    Map<String, Decimal> balances,
  ) {
    final transactions = <SettlementTransaction>[];
    final creditors = <String, Decimal>{};
    final debtors = <String, Decimal>{};

    for (final entry in balances.entries) {
      if (entry.value > Decimal.zero) {
        creditors[entry.key] = _floorTo2(entry.value);
      } else if (entry.value < Decimal.zero) {
        debtors[entry.key] = _floorTo2(-entry.value);
      }
    }

    while (creditors.isNotEmpty && debtors.isNotEmpty) {
      final creditorEntry = creditors.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final debtorEntry = debtors.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      final amount = creditorEntry.value < debtorEntry.value
          ? creditorEntry.value
          : debtorEntry.value;

      transactions.add(SettlementTransaction(
        fromId: debtorEntry.key,
        toId: creditorEntry.key,
        amount: _floorTo2(amount),
      ));

      final newCreditorBalance = creditorEntry.value - amount;
      final newDebtorBalance = debtorEntry.value - amount;

      if (newCreditorBalance == Decimal.zero) {
        creditors.remove(creditorEntry.key);
      } else {
        creditors[creditorEntry.key] = _floorTo2(newCreditorBalance);
      }

      if (newDebtorBalance == Decimal.zero) {
        debtors.remove(debtorEntry.key);
      } else {
        debtors[debtorEntry.key] = _floorTo2(newDebtorBalance);
      }
    }

    return transactions;
  }

  /// Floor a Decimal to 2 decimal places.
  static Decimal _floorTo2(Decimal d) {
    final multiplied = d * Decimal.fromInt(100);
    final truncatedInt = multiplied.floor().toBigInt().toInt();
    return (Decimal.fromInt(truncatedInt) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 2);
  }
}

class SettlementTransaction {
  final String fromId;
  final String toId;
  final Decimal amount;

  const SettlementTransaction({
    required this.fromId,
    required this.toId,
    required this.amount,
  });
}
