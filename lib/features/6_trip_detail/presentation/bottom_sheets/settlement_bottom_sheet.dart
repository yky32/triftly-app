import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/split_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

class SettlementBottomSheet extends StatelessWidget {
  const SettlementBottomSheet({
    required this.trip,
    required this.expenses,
    super.key,
  });

  final Trip trip;
  final List<Expense> expenses;

  static Future<void> show(
    BuildContext context, {
    required Trip trip,
    required List<Expense> expenses,
  }) {
    return TriftlyBottomSheet.show(
      context,
      child: SettlementBottomSheet(trip: trip, expenses: expenses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold<Decimal>(Decimal.zero, (sum, e) => sum + e.amount);
    final perPerson = trip.buddies.isEmpty
        ? Decimal.zero
        : (total / Decimal.fromInt(trip.buddies.length)).toDecimal();
    final transactions = SplitCalculator.calculateSettlement(expenses: expenses, buddies: trip.buddies);
    final balances = _buddyBalances(expenses);

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Settlement'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Total: ${trip.defaultCurrency} ${CurrencyUtils.formatDecimal(total)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (CurrencyUtils.approximateHkd(amount: total, currency: trip.defaultCurrency) case final converted?)
            Text(converted, style: Theme.of(context).textTheme.bodySmall),
          if (trip.buddies.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Per person: ${trip.defaultCurrency} ${CurrencyUtils.formatDecimal(perPerson)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ...balances.entries.map((entry) {
            final buddy = trip.buddies.firstWhere(
              (b) => b.id == entry.key,
              orElse: () => Buddy(id: entry.key, name: '?'),
            );
            final balance = entry.value;
            final isPositive = balance >= Decimal.zero;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: AppRadii.card,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(buddy.name, style: Theme.of(context).textTheme.labelLarge)),
                  Text(
                    '${isPositive ? '+' : ''}${trip.defaultCurrency} ${CurrencyUtils.formatDecimal(balance.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (transactions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Minimized transactions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...transactions.map((t) {
              final from = trip.buddies.firstWhere((b) => b.id == t.fromId, orElse: () => Buddy(id: '', name: '?'));
              final to = trip.buddies.firstWhere((b) => b.id == t.toId, orElse: () => Buddy(id: '', name: '?'));
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: Text('${from.name} → ${to.name}')),
                    Text(
                      '${trip.defaultCurrency} ${CurrencyUtils.formatDecimal(t.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
            Text(
              'Only ${transactions.length} ${transactions.length == 1 ? 'transaction' : 'transactions'} needed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Decimal> _buddyBalances(List<Expense> expenses) {
    final balances = <String, Decimal>{};
    for (final buddy in trip.buddies) {
      balances[buddy.id] = Decimal.zero;
    }
    for (final expense in expenses) {
      balances[expense.paidById] = (balances[expense.paidById] ?? Decimal.zero) + expense.amount;
      for (final split in expense.splits) {
        balances[split.buddyId] = (balances[split.buddyId] ?? Decimal.zero) - split.shareAmount;
      }
    }
    return balances;
  }
}
