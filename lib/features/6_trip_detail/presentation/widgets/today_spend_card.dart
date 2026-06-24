import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/triftly_motion.dart';

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
    final amountLine = hasSpending
        ? '$symbol${CurrencyUtils.formatDecimal(todayTotal)} spent'
        : '$symbol${CurrencyUtils.formatDecimal(Decimal.zero)} spent';
    final detailLine = hasSpending
        ? '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'} · ${DateFormatters.shortDate(todayDay.date)}'
        : DateFormatters.shortDate(todayDay.date);

    return Pressable(
      onTap: onOpenSpend,
      child: AppCard(
        color: AppColors.primaryDark,
        padding: compact ? const EdgeInsets.all(AppSpacing.md) : const EdgeInsets.all(AppSpacing.lg),
        child: compact
            ? _CompactBody(
                dayNumber: todayDay.dayNumber,
                amountLine: amountLine,
                detailLine: detailLine,
                onAddExpense: onAddExpense,
              )
            : _FullBody(
                dayNumber: todayDay.dayNumber,
                amountLine: amountLine,
                detailLine: detailLine,
                onAddExpense: onAddExpense,
              ),
      ),
    );
  }
}

class _FullBody extends StatelessWidget {
  const _FullBody({
    required this.dayNumber,
    required this.amountLine,
    required this.detailLine,
    required this.onAddExpense,
  });

  final int dayNumber;
  final String amountLine;
  final String detailLine;
  final VoidCallback? onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                'Today · Day $dayNumber',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                amountLine,
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
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({
    required this.dayNumber,
    required this.amountLine,
    required this.detailLine,
    required this.onAddExpense,
  });

  final int dayNumber;
  final String amountLine;
  final String detailLine;
  final VoidCallback? onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today · Day $dayNumber',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                amountLine,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                detailLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onAddExpense != null)
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              tooltip: 'Add expense',
              onPressed: onAddExpense,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            ),
          ),
      ],
    );
  }
}
