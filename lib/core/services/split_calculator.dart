import 'package:decimal/decimal.dart';
import '../models/settlement_record.dart';
import '../models/trip_models.dart';
import '../utils/currency_conversion.dart';

class SplitBuddyInput {
  final String buddyId;
  final SplitType splitType;
  final Decimal? configValue;

  const SplitBuddyInput({
    required this.buddyId,
    required this.splitType,
    this.configValue,
  });
}

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

  /// Validate split inputs before calculation.
  static String? validateInputs({
    required Decimal totalAmount,
    required List<SplitBuddyInput> entries,
  }) {
    if (entries.isEmpty) return 'Select at least one person';

    var amountTotal = Decimal.zero;
    var percentTotal = Decimal.zero;

    for (final entry in entries) {
      switch (entry.splitType) {
        case SplitType.amount:
          amountTotal += entry.configValue ?? Decimal.zero;
        case SplitType.percent:
          percentTotal += entry.configValue ?? Decimal.zero;
        case SplitType.equal:
        case SplitType.share:
          break;
      }
    }

    if (amountTotal > totalAmount) return 'Fixed amounts exceed total';
    if (percentTotal > Decimal.fromInt(100)) return 'Percents exceed 100%';
    return null;
  }

  /// Calculate owed shares for one expense across split types.
  static Map<String, Decimal> calculateShares({
    required Decimal totalAmount,
    required List<SplitBuddyInput> entries,
  }) {
    if (entries.isEmpty) return {};

    final result = <String, Decimal>{};
    var allocated = Decimal.zero;

    final amountEntries =
        entries.where((e) => e.splitType == SplitType.amount).toList();
    final percentEntries =
        entries.where((e) => e.splitType == SplitType.percent).toList();
    final shareEntries =
        entries.where((e) => e.splitType == SplitType.share).toList();
    final equalEntries =
        entries.where((e) => e.splitType == SplitType.equal).toList();

    for (final entry in amountEntries) {
      final owes = _floorTo2(entry.configValue ?? Decimal.zero);
      result[entry.buddyId] = owes;
      allocated += owes;
    }

    for (final entry in percentEntries) {
      final owes = _floorTo2(
        (totalAmount * (entry.configValue ?? Decimal.zero) / Decimal.fromInt(100))
            .toDecimal(scaleOnInfinitePrecision: 10),
      );
      result[entry.buddyId] = owes;
      allocated += owes;
    }

    if (shareEntries.isNotEmpty) {
      final remaining = totalAmount - allocated;
      final totalShares = shareEntries.fold<Decimal>(
        Decimal.zero,
        (sum, e) => sum + (e.configValue ?? Decimal.one),
      );
      if (totalShares > Decimal.zero) {
        var shareAllocated = Decimal.zero;
        for (var i = 0; i < shareEntries.length; i++) {
          final entry = shareEntries[i];
          final shares = entry.configValue ?? Decimal.one;
          final owes = i == shareEntries.length - 1
              ? _floorTo2(remaining - shareAllocated)
              : _floorTo2(
                  (remaining * shares / totalShares).toDecimal(scaleOnInfinitePrecision: 10),
                );
          result[entry.buddyId] = owes;
          shareAllocated += owes;
          allocated += owes;
        }
      }
    }

    if (equalEntries.isNotEmpty) {
      final remaining = totalAmount - allocated;
      final equalShares = equalSplit(
        totalAmount: remaining,
        buddyIds: equalEntries.map((e) => e.buddyId).toList(),
      );
      for (final entry in equalEntries) {
        result[entry.buddyId] = equalShares[entry.buddyId] ?? Decimal.zero;
      }
    }

    return result;
  }

  /// Normalize an expense to the trip currency for settlement math.
  static Expense normalizeExpense(Expense expense, String tripCurrency) {
    if (expense.currency == tripCurrency) return expense;

    final amount = CurrencyConversion.convert(
      amount: expense.amount,
      from: expense.currency,
      to: tripCurrency,
    );
    final splits = expense.splits
        .map(
          (split) => ExpenseSplit(
            id: split.id,
            expenseId: split.expenseId,
            buddyId: split.buddyId,
            splitType: split.splitType,
            shareAmount: CurrencyConversion.convert(
              amount: split.shareAmount,
              from: expense.currency,
              to: tripCurrency,
            ),
            splitConfigValue: split.splitConfigValue,
          ),
        )
        .toList();

    return expense.copyWith(
      amount: amount,
      currency: tripCurrency,
      splits: splits,
    );
  }

  /// Calculate who owes whom after all expenses.
  static List<SettlementTransaction> calculateSettlement({
    required List<Expense> expenses,
    required List<Buddy> buddies,
    required String settleCurrency,
    List<SettlementRecord> recordedSettlements = const [],
  }) {
    final balances = <String, Decimal>{};
    for (final buddy in buddies) {
      balances[buddy.id] = Decimal.zero;
    }

    for (final raw in expenses) {
      final expense = normalizeExpense(raw, settleCurrency);
      balances[expense.paidById] =
          (balances[expense.paidById] ?? Decimal.zero) + expense.amount;
      for (final split in expense.splits) {
        balances[split.buddyId] =
            (balances[split.buddyId] ?? Decimal.zero) - split.shareAmount;
      }
    }

    for (final record in recordedSettlements.where((s) => s.isActive)) {
      final amount = CurrencyConversion.toTripCurrency(
        amount: record.amount,
        currency: record.currency,
        tripCurrency: settleCurrency,
      );
      balances[record.fromBuddyId] =
          (balances[record.fromBuddyId] ?? Decimal.zero) + amount;
      balances[record.toBuddyId] =
          (balances[record.toBuddyId] ?? Decimal.zero) - amount;
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
