import 'dart:ui';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../spend_wallet_summary.dart';
import 'spend_wallet_accent.dart';

/// Wallet hero — liquid glass over teal, balance + owed/owe.
class SpendWalletCard extends StatelessWidget {
  const SpendWalletCard({
    required this.summary,
    super.key,
  });

  final SpendWalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadii.lg);

    final heroAmount = summary.isSettled ? Decimal.zero : summary.net.abs();
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.navBar(context),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Color wash beneath the glass
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF0F766E), const Color(0xFF0C4A6E)]
                        : [AppColors.primaryDark, const Color(0xFF0E7490)],
                  ),
                ),
              ),
            ),
            // Frosted liquid glass layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.14 : 0.28),
                        Colors.white.withValues(alpha: isDark ? 0.04 : 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.45),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            // Specular highlight along the top edge
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -24,
              top: -28,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 112,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _GlassChip(
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'As ${summary.meDisplayName}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _GlassChip(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  Text(
                    '${summary.activeTripCount} active · ${summary.expenseCount} expenses',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 8),
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
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _GlassInset(
                    child: Row(
                      children: [
                        Expanded(
                          child: _OweStat(
                            icon: Icons.payments_outlined,
                            label: 'You paid',
                            amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.myPaid)}',
                            tint: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
                        Expanded(
                          child: _OweStat(
                            icon: Icons.receipt_long_outlined,
                            label: 'Your share',
                            amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.myShare)}',
                            tint: Colors.white.withValues(alpha: 0.9),
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _GlassInset(
                    child: Row(
                      children: [
                        Expanded(
                          child: _OweStat(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Owed to you',
                            amount: '+${summary.symbol}${CurrencyUtils.formatDecimal(summary.owedToMe)}',
                            tint: const Color(0xFF6EE7B7),
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
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
                  ),
                  if (summary.isMultiCurrency) ...[
                    const SizedBox(height: 10),
                    _GlassInset(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Other currencies',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                          ),
                          const SizedBox(height: 6),
                          ...summary.otherCurrencies.map(
                            (bucket) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${bucket.currency} · net ${bucket.net > Decimal.zero ? '+' : bucket.net < Decimal.zero ? '−' : ''}'
                                '${bucket.symbol}${CurrencyUtils.formatDecimal(bucket.net.abs())}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                          if (summary.hkdEquivalentNet != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              summary.hkdEquivalentNet!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini frosted capsule for icons and chips on the wallet card.
class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: padding == null ? 36 : null,
          height: padding == null ? 36 : null,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.18),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          alignment: padding == null ? Alignment.center : null,
          child: child,
        ),
      ),
    );
  }
}

/// Frosted inset panel for the owe/owed row.
class _GlassInset extends StatelessWidget {
  const _GlassInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: child,
          ),
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
      SpendSign.positive => (
          const Color(0xFF065F46).withValues(alpha: 0.75),
          const Color(0xFF6EE7B7),
          Icons.trending_up_rounded,
        ),
      SpendSign.negative => (
          const Color(0xFF7F1D1D).withValues(alpha: 0.75),
          const Color(0xFFFCA5A5),
          Icons.trending_down_rounded,
        ),
      SpendSign.neutral => (
          Colors.white.withValues(alpha: 0.14),
          Colors.white70,
          Icons.verified_rounded,
        ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: fg.withValues(alpha: 0.35)),
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
      padding: EdgeInsets.only(left: alignEnd ? 8 : 0, right: alignEnd ? 0 : 8),
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
