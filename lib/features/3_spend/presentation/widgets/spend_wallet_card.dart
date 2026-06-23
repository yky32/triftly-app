import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../spend_wallet_summary.dart';
import 'spend_wallet_chrome.dart';

/// Modern wallet hero — light surface, bold type, soft status chips.
class SpendWalletCard extends StatelessWidget {
  const SpendWalletCard({
    required this.summary,
    super.key,
  });

  final SpendWalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroAmount = summary.isSettled ? summary.myShare : summary.net.abs();
    final heroLabel = summary.isSettled
        ? 'All settled'
        : summary.net > Decimal.zero
            ? 'You\'re owed'
            : 'You owe';
    final statusTone = summary.isSettled
        ? SpendWalletStatusTone.neutral
        : summary.net > Decimal.zero
            ? SpendWalletStatusTone.positive
            : SpendWalletStatusTone.negative;

    return Container(
      decoration: SpendWalletChrome.surfaceCard(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: AppColors.primary),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NET BALANCE',
                              style: SpendWalletChrome.sectionLabel(context),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${summary.symbol}${CurrencyUtils.formatDecimal(heroAmount)}',
                              style: SpendWalletChrome.moneyHero(context),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          summary.currency,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SpendWalletStatusPill(label: heroLabel, tone: statusTone),
                  const SizedBox(height: 20),
                  _InsetMetrics(summary: summary),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _BalanceChip(
                          label: 'Owed to you',
                          amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.owedToMe)}',
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _BalanceChip(
                          label: 'You owe',
                          amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.iOwe)}',
                          color: AppColors.error,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsetMetrics extends StatelessWidget {
  const _InsetMetrics({required this.summary});

  final SpendWalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceDim;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          _Metric(
            label: 'Your share',
            value: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.myShare)}',
          ),
          _Metric(
            label: 'You paid',
            value: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.myPaid)}',
          ),
          _Metric(
            label: 'Trips',
            value: '${summary.activeTripCount}',
            alignEnd: true,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 3),
          Text(
            value,
            style: SpendWalletChrome.moneyBody(context, size: 15),
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String amount;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            amount,
            style: SpendWalletChrome.moneyBody(context, color: color, size: 17),
          ),
        ],
      ),
    );
  }
}
