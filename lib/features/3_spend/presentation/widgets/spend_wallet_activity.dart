import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_wallet_chrome.dart';

/// Ledger activity — airy rows, tabular amounts.
class SpendWalletActivity extends StatelessWidget {
  const SpendWalletActivity({
    required this.transactions,
    this.maxItems = 12,
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
        SpendWalletSectionHeader(
          title: 'Activity',
          trailing: '${items.length} recent',
        ),
        Container(
          decoration: SpendWalletChrome.surfaceCard(context),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 68,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.categoryColor(category);

    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.name} · ${DateFormatters.shortDate(expense.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '-${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}',
              style: SpendWalletChrome.moneyBody(context, size: 15),
            ),
          ],
        ),
      ),
    );
  }
}
