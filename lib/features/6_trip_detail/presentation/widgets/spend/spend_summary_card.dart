import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/currency_conversion.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../core/widgets/app_card.dart';

class SpendSummaryCard extends StatelessWidget {
  const SpendSummaryCard({
    required this.totalSpending,
    required this.currency,
    required this.expenses,
    super.key,
  });

  final Decimal totalSpending;
  final String currency;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final converted = CurrencyUtils.approximateHkd(amount: totalSpending, currency: currency);
    final symbol = CurrencyUtils.symbolFor(currency);

    return AppCard(
      color: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total spending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '$symbol${CurrencyUtils.formatDecimal(totalSpending)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (converted != null) ...[
            const SizedBox(height: 2),
            Text(converted, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
          if (expenses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _CategoryBreakdown(expenses: expenses, tripCurrency: currency),
          ],
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.expenses,
    required this.tripCurrency,
  });

  final List<Expense> expenses;
  final String tripCurrency;

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, Decimal>{};
    for (final e in expenses) {
      final converted = CurrencyConversion.toTripCurrency(
        amount: e.amount,
        currency: e.currency,
        tripCurrency: tripCurrency,
      );
      categoryTotals[e.category] = (categoryTotals[e.category] ?? Decimal.zero) + converted;
    }

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxAmount = entries.isEmpty
        ? Decimal.zero
        : entries.first.value;

    return Column(
      children: entries.map((entry) {
        final category = SpotCategory.values.firstWhere(
          (c) => c.value == entry.key,
          orElse: () => SpotCategory.other,
        );
        final barColor = AppColors.categoryColor(category);
        final ratio = maxAmount > Decimal.zero ? (entry.value / maxAmount).toDouble() : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  '${category.emoji} ${category.label}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.white24,
                    color: barColor,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyUtils.formatDecimal(entry.value),
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
