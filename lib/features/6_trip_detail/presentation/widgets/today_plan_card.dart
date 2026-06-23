import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/triftly_motion.dart';

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
    final symbol = CurrencyUtils.symbolFor(trip.defaultCurrency);
    final hasSpending = expenseCount > 0;
    final showUpNext = nextSpot != null;

    return AppCard(
      color: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showUpNext) ...[
            Pressable(
              onTap: onOpenMaps ?? () => MapsLauncher.openSpot(nextSpot!),
              child: _UpNextRow(spot: nextSpot!, defaultCurrency: trip.defaultCurrency),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.14)),
            ),
          ],
          Pressable(
            onTap: onOpenSpend,
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
                  child: Text(
                    showUpNext ? '💰' : _dayEmoji(todayDay.dayNumber),
                    style: const TextStyle(fontSize: 22),
                  ),
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
                        hasSpending
                            ? '$symbol${CurrencyUtils.formatDecimal(todayTotal)} spent'
                            : 'No spending logged yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        hasSpending
                            ? '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'} · ${DateFormatters.shortDate(todayDay.date)}'
                            : DateFormatters.shortDate(todayDay.date),
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

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.spot,
    required this.defaultCurrency,
  });

  final Spot spot;
  final String defaultCurrency;

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );

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
          child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Up next',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                spot.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (_meta().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _meta(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
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
