import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../spend_wallet_summary.dart';
import 'spend_wallet_accent.dart';

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
    final sign = summary.isSettled
        ? SpendSign.neutral
        : summary.net > Decimal.zero
            ? SpendSign.positive
            : SpendSign.negative;
    final heroPrefix = switch (sign) {
      SpendSign.positive => '+',
      SpendSign.negative => '−',
      SpendSign.neutral => '',
    };
    final heroBadgeLabel = switch (sign) {
      SpendSign.positive => 'You\'re owed',
      SpendSign.negative => 'You owe',
      SpendSign.neutral => 'All settled',
    };

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 100,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Wallet',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
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
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _HeroStatusBadge(label: heroBadgeLabel, sign: sign),
                  const SizedBox(height: 10),
                  Text(
                    '$heroPrefix${summary.symbol}${CurrencyUtils.formatDecimal(heroAmount)}',
                    style: TextStyle(
                      fontSize: 36,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: switch (sign) {
                        SpendSign.positive => const Color(0xFF6EE7B7),
                        SpendSign.negative => const Color(0xFFFCA5A5),
                        SpendSign.neutral => Colors.white,
                      },
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _OweStat(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Owed to you',
                          amount: '+${summary.symbol}${CurrencyUtils.formatDecimal(summary.owedToMe)}',
                          tint: const Color(0xFF6EE7B7),
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.18)),
                      Expanded(
                        child: _OweStat(
                          icon: Icons.remove_circle_outline_rounded,
                          label: 'You owe',
                          amount: '−${summary.symbol}${CurrencyUtils.formatDecimal(summary.iOwe)}',
                          tint: const Color(0xFFFCA5A5),
                          alignEnd: true,
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

class _HeroStatusBadge extends StatelessWidget {
  const _HeroStatusBadge({required this.label, required this.sign});

  final String label;
  final SpendSign sign;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (sign) {
      SpendSign.positive => (const Color(0xFF065F46), const Color(0xFF6EE7B7), Icons.trending_up_rounded),
      SpendSign.negative => (const Color(0xFF7F1D1D), const Color(0xFFFCA5A5), Icons.trending_down_rounded),
      SpendSign.neutral => (Colors.white.withValues(alpha: 0.12), Colors.white70, Icons.verified_rounded),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OweStat extends StatelessWidget {
  const _OweStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.tint,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color tint;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: alignEnd ? 12 : 0, right: alignEnd ? 0 : 12),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!alignEnd) Icon(icon, size: 13, color: tint),
              if (!alignEnd) const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white60, fontSize: 11)),
              if (alignEnd) const SizedBox(width: 4),
              if (alignEnd) Icon(icon, size: 13, color: tint),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            amount,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
