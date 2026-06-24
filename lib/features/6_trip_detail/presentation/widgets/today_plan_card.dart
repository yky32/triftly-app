import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_overview_metric_card.dart';

/// Today summary on Plan tab — glass "Up next" plus inline spend strip.
class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({
    required this.trip,
    required this.todayDay,
    required this.todayTotal,
    required this.expenseCount,
    this.nextSpot,
    this.onOpenMaps,
    this.onAddExpense,
    this.onOpenSpend,
    super.key,
  });

  final Trip trip;
  final TripDay todayDay;
  final Decimal todayTotal;
  final int expenseCount;
  final Spot? nextSpot;
  final VoidCallback? onOpenMaps;
  final VoidCallback? onAddExpense;
  final VoidCallback? onOpenSpend;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(trip.defaultCurrency);
    final hasSpending = expenseCount > 0;
    final amountText = '$symbol${CurrencyUtils.formatDecimal(hasSpending ? todayTotal : Decimal.zero)}';
    final dateLabel = DateFormatters.shortDate(todayDay.date);
    final showUpNext = nextSpot != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showUpNext) ...[
          SpendGlassShell(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Pressable(
              onTap: onOpenMaps ?? () => MapsLauncher.openSpot(nextSpot!),
              child: _UpNextRow(
                spot: nextSpot!,
                defaultCurrency: trip.defaultCurrency,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _TodaySpendInlineStrip(
          amountText: amountText,
          dateLabel: dateLabel,
          hasSpending: hasSpending,
          expenseCount: expenseCount,
          onOpenSpend: onOpenSpend,
          onAddExpense: onAddExpense,
        ),
      ],
    );
  }
}

/// Compact spend meta row — not a glass island; links to Spend tab.
class _TodaySpendInlineStrip extends StatelessWidget {
  const _TodaySpendInlineStrip({
    required this.amountText,
    required this.dateLabel,
    required this.hasSpending,
    required this.expenseCount,
    this.onOpenSpend,
    this.onAddExpense,
  });

  final String amountText;
  final String dateLabel;
  final bool hasSpending;
  final int expenseCount;
  final VoidCallback? onOpenSpend;
  final VoidCallback? onAddExpense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final statusLabel = hasSpending
        ? '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}'
        : 'No expenses';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              onTap: onOpenSpend,
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 15,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                              height: 1.25,
                            ),
                        children: [
                          TextSpan(
                            text: amountText,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const TextSpan(text: ' spent  ·  '),
                          TextSpan(text: dateLabel),
                          const TextSpan(text: '  ·  '),
                          TextSpan(
                            text: statusLabel,
                            style: TextStyle(
                              fontStyle: hasSpending ? FontStyle.normal : FontStyle.italic,
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onAddExpense != null)
            _InlineAddButton(onPressed: onAddExpense!)
          else
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}

class _InlineAddButton extends StatelessWidget {
  const _InlineAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.add_circle_outline_rounded,
          size: 20,
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.emoji, required this.isDark});

  final String emoji;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.spot,
    required this.defaultCurrency,
  });

  final Spot spot;
  final String defaultCurrency;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );

    return Row(
      children: [
        _IconTile(emoji: category.emoji, isDark: isDark),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UP NEXT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.45,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                spot.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (_meta().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _meta(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        Icon(
          Icons.navigation_rounded,
          size: 22,
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
        ),
      ],
    );
  }

  String _meta() {
    return [
      if (spot.openingHours != null) spot.openingHours,
      if (spot.estimatedDuration != null) spot.estimatedDuration,
      if (spot.estimatedCost != null) '$defaultCurrency ${spot.estimatedCost}',
    ].join(' · ');
  }
}
