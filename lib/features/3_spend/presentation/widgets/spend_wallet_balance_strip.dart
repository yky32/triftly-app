import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../spend_wallet_summary.dart';

/// Owed to you · You owe — quick money glance under the wallet card.
class SpendWalletBalanceStrip extends StatelessWidget {
  const SpendWalletBalanceStrip({
    required this.summary,
    super.key,
  });

  final SpendWalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;

    return Row(
      children: [
        Expanded(
          child: _Pill(
            surface: surface,
            label: 'Owed to you',
            amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.owedToMe)}',
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Pill(
            surface: surface,
            label: 'You owe',
            amount: '${summary.symbol}${CurrencyUtils.formatDecimal(summary.iOwe)}',
            color: AppColors.error,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.surface,
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  final Color surface;
  final String label;
  final String amount;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.3,
                ),
          ),
        ],
      ),
    );
  }
}
