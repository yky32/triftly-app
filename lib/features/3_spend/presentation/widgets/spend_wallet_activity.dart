import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import 'spend_wallet_accent.dart';

class SpendWalletActivity extends StatelessWidget {
  const SpendWalletActivity({
    required this.transactions,
    this.maxItems = 8,
    super.key,
  });

  final List<SpendTransactionLine> transactions;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    final items = transactions.take(maxItems).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpendSectionTitle(
          icon: Icons.receipt_long_rounded,
          title: 'Recent',
          count: items.length,
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                _ActivityRow(
                  line: items[i],
                  onTap: () => SpendNavigation.openTripSpend(context, items[i].trip.id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.line,
    required this.onTap,
  });

  final SpendTransactionLine line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expense = line.expense;
    final trip = line.trip;
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => SpotCategory.other,
    );
    final accent = AppColors.categoryColor(category);
    final amountLabel = '−${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            SpendIconAvatar(
              size: 38,
              color: accent,
              child: Text(category.emoji, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.name,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              amountLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    letterSpacing: -0.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
