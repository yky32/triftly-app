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

/// Single today summary on Plan tab — up next + spending in one card.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = CurrencyUtils.symbolFor(trip.defaultCurrency);
    final hasSpending = expenseCount > 0;
    final showUpNext = nextSpot != null;
    final amountText = hasSpending
        ? '$symbol${CurrencyUtils.formatDecimal(todayTotal)}'
        : '$symbol${CurrencyUtils.formatDecimal(Decimal.zero)}';
    final spendDetail = hasSpending
        ? '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'} · ${DateFormatters.shortDate(todayDay.date)}'
        : DateFormatters.shortDate(todayDay.date);

    return SpendGlassShell(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showUpNext) ...[
            Pressable(
              onTap: onOpenMaps ?? () => MapsLauncher.openSpot(nextSpot!),
              child: _UpNextRow(
                spot: nextSpot!,
                defaultCurrency: trip.defaultCurrency,
                isDark: isDark,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ],
          Pressable(
            onTap: onOpenSpend,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconTile(
                  emoji: showUpNext ? '💰' : _dayEmoji(todayDay.dayNumber),
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY · DAY ${todayDay.dayNumber}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.45,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: amountText,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                letterSpacing: -0.6,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            TextSpan(
                              text: ' spent',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spendDetail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!hasSpending) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _EmptySpendBadge(isDark: isDark),
                ],
                if (onAddExpense != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _AddChipButton(onPressed: onAddExpense!),
                ] else ...[
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dayEmoji(int dayNumber) {
    const emojis = ['1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣'];
    if (dayNumber >= 1 && dayNumber <= emojis.length) return emojis[dayNumber - 1];
    return '📅';
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

class _EmptySpendBadge extends StatelessWidget {
  const _EmptySpendBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        'No expenses',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
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

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.spot,
    required this.defaultCurrency,
    required this.isDark,
  });

  final Spot spot;
  final String defaultCurrency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
