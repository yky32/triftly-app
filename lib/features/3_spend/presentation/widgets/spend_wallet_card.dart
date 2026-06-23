import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../spend_wallet_summary.dart';

/// Top wallet card — balance-first, credit-card feel.
class SpendWalletCard extends StatelessWidget {
  const SpendWalletCard({
    required this.summary,
    required this.ownerName,
    super.key,
  });

  final SpendWalletSummary summary;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF134E4A), const Color(0xFF0F172A)]
          : [AppColors.primaryDark, const Color(0xFF115E59)],
    );

    final heroAmount = summary.isSettled ? summary.myShare : summary.net.abs();
    final heroLabel = summary.isSettled
        ? 'All settled'
        : summary.net > Decimal.zero
            ? 'You\'re owed'
            : 'You owe';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -16,
              bottom: -32,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.white.withValues(alpha: 0.85)),
                      const SizedBox(width: 8),
                      Text(
                        '$ownerName\'s wallet',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          summary.currency,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    heroLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.symbol}${CurrencyUtils.formatDecimal(heroAmount)}',
                    style: const TextStyle(
                      fontSize: 40,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.16)),
                  const SizedBox(height: 14),
                  Row(
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
                ],
              ),
            ),
          ],
        ),
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
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
