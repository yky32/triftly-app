import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/currency_conversion.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../core/widgets/app_card.dart';

class SpendExpenseItem extends StatelessWidget {
  const SpendExpenseItem({
    required this.expense,
    required this.buddies,
    required this.tripCurrency,
    this.onTap,
    super.key,
  });

  final Expense expense;
  final List<Buddy> buddies;
  final String tripCurrency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => SpotCategory.other,
    );
    final payer = buddies.firstWhere(
      (b) => b.id == expense.paidById,
      orElse: () => Buddy(id: '', name: 'Unknown'),
    );
    final categoryColor = AppColors.categoryColor(category);
    final conversionLabel = CurrencyConversion.tripEquivalentLabel(
      amount: expense.amount,
      currency: expense.currency,
      tripCurrency: tripCurrency,
    );

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: categoryColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text('${payer.name} paid', style: Theme.of(context).textTheme.bodySmall),
                          Text(_splitLabel(expense), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (conversionLabel != null)
                          Text(conversionLabel, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _splitLabel(Expense expense) {
    if (expense.splits.isEmpty) {
      return buddies.length == 1 ? 'Split: ${buddies.first.name}' : 'Split: All ${buddies.length}';
    }
    if (expense.splits.every((s) => s.splitType == expense.splits.first.splitType)) {
      return switch (expense.splits.first.splitType) {
        SplitType.equal => 'Split: ${expense.splits.length} people',
        SplitType.percent => 'Split: percent',
        SplitType.amount => 'Split: fixed amounts',
        SplitType.share => 'Split: shares',
      };
    }
    final names = expense.splits
        .map((split) => buddies.firstWhere((b) => b.id == split.buddyId, orElse: () => Buddy(id: '', name: '?')).name)
        .toList();
    return 'Split: ${names.join(', ')}';
  }
}

class SpendExpenseDismissible extends StatelessWidget {
  const SpendExpenseDismissible({
    required this.expense,
    required this.child,
    required this.onDelete,
    required this.readOnly,
    super.key,
  });

  final Expense expense;
  final Widget child;
  final VoidCallback onDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (readOnly) return child;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadii.card,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete expense?'),
                content: Text('Remove "${expense.title}" from this trip.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: child,
    );
  }
}
