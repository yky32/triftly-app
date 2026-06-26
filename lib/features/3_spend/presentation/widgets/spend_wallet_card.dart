import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/spend_glass_shell.dart';
import '../spend_wallet_summary.dart';
import 'spend_wallet_accent.dart';

/// Wallet hero — shared liquid glass shell, balance + owed/owe.
class SpendWalletCard extends StatelessWidget {
  const SpendWalletCard({
    required this.summary,
    super.key,
  });

  final SpendWalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

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
    final heroColor = switch (sign) {
      SpendSign.positive => AppColors.success,
      SpendSign.negative => AppColors.error,
      SpendSign.neutral => isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    };

    return SpendGlassShell(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _WalletIconChip(isDark: isDark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WALLET',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: tertiary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.45,
                          ),
                    ),
                    Text(
                      'As ${summary.meDisplayName}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: muted,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              SpendInlineChip(label: summary.currency),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${summary.activeTripCount} active · ${summary.expenseCount} expenses',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SpendSignedBadge(label: heroBadgeLabel, sign: sign),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$heroPrefix${summary.symbol}${CurrencyUtils.formatDecimal(heroAmount)}',
            style: TextStyle(
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: heroColor,
              letterSpacing: -1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatPanel(
            isDark: isDark,
            child: Row(
              children: [
                Expanded(
                  child: _OweStat(
                    icon: Icons.payments_outlined,
                    label: 'You paid',
                    amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.myPaid)}',
                    tint: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                _StatDivider(isDark: isDark),
                Expanded(
                  child: _OweStat(
                    icon: Icons.receipt_long_outlined,
                    label: 'Your share',
                    amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.myShare)}',
                    tint: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatPanel(
            isDark: isDark,
            child: Row(
              children: [
                Expanded(
                  child: _OweStat(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Owed to you',
                    amount: '+${summary.symbol}${CurrencyUtils.formatDecimal(summary.owedToMe)}',
                    tint: AppColors.success,
                  ),
                ),
                _StatDivider(isDark: isDark),
                Expanded(
                  child: _OweStat(
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'You owe',
                    amount: '−${summary.symbol}${CurrencyUtils.formatDecimal(summary.iOwe)}',
                    tint: AppColors.error,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          if (summary.isMultiCurrency) ...[
            const SizedBox(height: AppSpacing.sm),
            _StatPanel(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Other currencies',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  ...summary.otherCurrencies.map(
                    (bucket) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${bucket.currency} · net ${bucket.net > Decimal.zero ? '+' : bucket.net < Decimal.zero ? '−' : ''}'
                        '${bucket.symbol}${CurrencyUtils.formatDecimal(bucket.net.abs())}',
                        style: spendItemText(
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                  if (summary.consolidatedNet != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      summary.consolidatedNet!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: tertiary,
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
    );
  }
}

class _WalletIconChip extends StatelessWidget {
  const _WalletIconChip({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          Icons.account_balance_wallet_rounded,
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          size: 20,
        ),
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child,
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
    final muted = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

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
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontSize: 11,
                    ),
              ),
              if (alignEnd) const SizedBox(width: 4),
              if (alignEnd) Icon(icon, size: 13, color: tint),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            amount,
            style: spendItemText(
              Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
