import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/triftly_motion.dart';
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
        SpendSectionTitle(title: 'Recent', count: items.length),
        SpendListCard(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md + 3,
                    endIndent: AppSpacing.md,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => SpotCategory.other,
    );
    final accent = AppColors.categoryColor(category);
    final amountLabel = '−${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}';

    return Pressable(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: accent.withValues(alpha: 0.85)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 13, AppSpacing.md, 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: spendItemText(
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${trip.name} · ${DateFormatters.shortDate(expense.createdAt)}',
                            style: spendItemText(
                              Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: isDark ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Text(
                        amountLabel,
                        style: spendItemText(
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                                letterSpacing: -0.2,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
