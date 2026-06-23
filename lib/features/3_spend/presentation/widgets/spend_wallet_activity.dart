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
                    indent: 16,
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
    final amountLabel = '−${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: spendListText(
                      Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    trip.name,
                    style: spendListText(Theme.of(context).textTheme.bodySmall),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              amountLabel,
              style: spendListText(
                Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      letterSpacing: -0.2,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
