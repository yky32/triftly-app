import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_card.dart';

class SpendMeHeroCard extends StatelessWidget {
  const SpendMeHeroCard({
    required this.overview,
    super.key,
  });

  final GlobalSpendOverview overview;

  @override
  Widget build(BuildContext context) {
    final active = overview.activeTripsWithSpending;
    final primaryCurrency = active.isNotEmpty ? active.first.currency : 'HKD';
    final symbol = CurrencyUtils.symbolFor(primaryCurrency);

    var totalPaid = Decimal.zero;
    var totalShare = Decimal.zero;
    for (final snap in overview.tripsWithSpending) {
      if (snap.currency == primaryCurrency) {
        totalPaid += snap.myPaid;
        totalShare += snap.myShare;
      }
    }
    final net = totalPaid - totalShare;

    return AppCard(
      color: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${overview.meDisplayName}\'s spending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            overview.isEmpty ? 'No expenses yet' : '$symbol${CurrencyUtils.formatDecimal(totalPaid)} paid',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (!overview.isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Your share: $symbol${CurrencyUtils.formatDecimal(totalShare)} · ${overview.totalExpenseCount} expenses',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Net position',
                    value: net == Decimal.zero
                        ? 'Settled'
                        : net > Decimal.zero
                            ? '+$symbol${CurrencyUtils.formatDecimal(net)}'
                            : '-$symbol${CurrencyUtils.formatDecimal(net.abs())}',
                    valueColor: net == Decimal.zero
                        ? Colors.white70
                        : net > Decimal.zero
                            ? AppColors.success
                            : const Color(0xFFFFB4B4),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatChip(
                    label: 'Active trips',
                    value: '${active.length}',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white60)),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
