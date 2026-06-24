import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_overview_metric_card.dart';

class TodaySpendCard extends StatelessWidget {
  const TodaySpendCard({
    required this.trip,
    required this.todayDay,
    required this.todayTotal,
    required this.expenseCount,
    this.compact = false,
    this.onAddExpense,
    this.onOpenSpend,
    super.key,
  });

  final Trip trip;
  final TripDay todayDay;
  final Decimal todayTotal;
  final int expenseCount;
  final bool compact;
  final VoidCallback? onAddExpense;
  final VoidCallback? onOpenSpend;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(trip.defaultCurrency);
    final hasSpending = expenseCount > 0;
    final amountText = '$symbol${CurrencyUtils.formatDecimal(hasSpending ? todayTotal : Decimal.zero)}';
    final detailLine = hasSpending
        ? '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'} · ${DateFormatters.shortDate(todayDay.date)}'
        : DateFormatters.shortDate(todayDay.date);

    if (compact) {
      return SpendOverviewMetricCard(
        label: 'Today · Day ${todayDay.dayNumber}',
        amount: amountText,
        amountSuffix: 'spent',
        meta: detailLine,
        onTap: onOpenSpend,
        trailing: onAddExpense == null
            ? null
            : _AddChipButton(onPressed: onAddExpense!),
      );
    }

    return Pressable(
      onTap: onOpenSpend,
      child: AppCard(
        color: AppColors.primaryDark,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              alignment: Alignment.center,
              child: const Text('💰', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today · Day ${todayDay.dayNumber}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$amountText spent',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    detailLine,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (onAddExpense != null)
              IconButton(
                tooltip: 'Add expense',
                onPressed: onAddExpense,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

class _AddChipButton extends StatelessWidget {
  const _AddChipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.primary.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            Icons.add_rounded,
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            size: 18,
          ),
        ),
      ),
    );
  }
}
