import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../spend_wallet_summary.dart';

/// Wallet hero — balance + owed/owe in one card.
class SpendWalletCard extends StatelessWidget {
  const SpendWalletCard({
    required this.summary,
    super.key,
  });

  final SpendWalletSummary summary;

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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: isDark ? 0.28 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Wallet',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                summary.currency,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            heroLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.symbol}${CurrencyUtils.formatDecimal(heroAmount)}',
            style: const TextStyle(
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OweStat(
                  label: 'Owed to you',
                  amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.owedToMe)}',
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _OweStat(
                  label: 'You owe',
                  amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.iOwe)}',
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OweStat extends StatelessWidget {
  const _OweStat({
    required this.label,
    required this.amount,
    this.alignEnd = false,
  });

  final String label;
  final String amount;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          amount,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
