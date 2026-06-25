import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import 'spend_overview_metric_card.dart';

class TodaySpendCard extends StatelessWidget {
  const TodaySpendCard({
    required this.trip,
    required this.todayDay,
    required this.todayTotal,
    required this.expenseCount,
    this.onAddExpense,
    this.onOpenSpend,
    super.key,
  });

  final Trip trip;
  final TripDay todayDay;
  final Decimal todayTotal;
  final int expenseCount;
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

    return SpendOverviewMetricCard(
      label: 'Today · Day ${todayDay.dayNumber}',
      amount: amountText,
      amountSuffix: 'spent',
      meta: detailLine,
      onTap: onOpenSpend,
      trailing: onAddExpense == null ? null : _AddChipButton(onPressed: onAddExpense!),
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
