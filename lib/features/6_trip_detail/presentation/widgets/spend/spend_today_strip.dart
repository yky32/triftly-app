import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../core/utils/date_formatters.dart';
import '../../../../../core/widgets/app_card.dart';

/// Compact today spending strip on Spend tab (light card, not dark hero).
class SpendTodayStrip extends StatelessWidget {
  const SpendTodayStrip({
    required this.todayDay,
    required this.currency,
    required this.todayTotal,
    required this.expenseCount,
    super.key,
  });

  final TripDay todayDay;
  final String currency;
  final Decimal todayTotal;
  final int expenseCount;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(currency);
    final hasSpending = expenseCount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: const Text('📅', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today · Day ${todayDay.dayNumber}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasSpending
                      ? '$symbol${CurrencyUtils.formatDecimal(todayTotal)} · $expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}'
                      : 'No spending logged yet',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormatters.shortDate(todayDay.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
