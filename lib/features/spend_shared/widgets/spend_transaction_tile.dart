import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../core/models/trip_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_conversion.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/app_card.dart';

/// Compact expense row — shared by global Spend page and (future) trip tab.
class SpendTransactionTile extends StatelessWidget {
  const SpendTransactionTile({
    required this.expense,
    required this.buddies,
    required this.tripCurrency,
    this.tripLabel,
    this.onTap,
    super.key,
  });

  final Expense expense;
  final List<Buddy> buddies;
  final String tripCurrency;
  final String? tripLabel;
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
                          if (tripLabel != null)
                            Text(
                              tripLabel!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          Text('${payer.name} paid', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
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
}

/// Net position label for personal summary.
class SpendNetLabel extends StatelessWidget {
  const SpendNetLabel({
    required this.net,
    required this.currency,
    super.key,
  });

  final Decimal net;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(currency);
    final isPositive = net > Decimal.zero;
    final isZero = net == Decimal.zero;
    final color = isZero
        ? AppColors.textSecondary
        : isPositive
            ? AppColors.success
            : AppColors.error;
    final prefix = isZero ? 'Settled' : isPositive ? 'You are owed' : 'You owe';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prefix, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          isZero ? '—' : '$symbol${CurrencyUtils.formatDecimal(net.abs())}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}
