import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../../spend_shared/bottom_sheets/spend_expense_detail_sheet.dart';
import 'spend_wallet_accent.dart';

class SpendWalletActivity extends StatelessWidget {
  const SpendWalletActivity({
    required this.transactions,
    this.maxItems = 8,
    this.totalCount,
    this.onSeeAll,
    super.key,
  });

  final List<SpendTransactionLine> transactions;
  final int maxItems;
  final int? totalCount;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    final items = transactions.take(maxItems).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countLabel = totalCount ?? transactions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: SpendSectionTitle(title: 'Recent', count: countLabel)),
            if (onSeeAll != null && (totalCount ?? transactions.length) > maxItems)
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See all'),
              ),
          ],
        ),
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
                _ActivityRow(line: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Single recent expense row on the global Spend page.
class SpendActivityRow extends StatelessWidget {
  const SpendActivityRow({required this.line, super.key});

  final SpendTransactionLine line;

  @override
  Widget build(BuildContext context) => _ActivityBody(line: line);
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.line});

  final SpendTransactionLine line;

  @override
  Widget build(BuildContext context) => _ActivityBody(line: line);
}

class _ActivityBody extends StatelessWidget {
  const _ActivityBody({required this.line});

  final SpendTransactionLine line;

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
    final symbol = CurrencyUtils.symbolFor(line.currency);
    final myShare = line.myShare;
    final iPaid = line.iPaid;

    final payer = trip.buddies.firstWhere(
      (b) => b.id == expense.paidById,
      orElse: () => const Buddy(id: '', name: 'Someone'),
    );

    final (amountLabel, amountColor, subtitle) = switch (true) {
      _ when iPaid => (
          '$symbol${CurrencyUtils.formatDecimal(expense.amount)}',
          AppColors.primaryDark,
          'You paid · ${trip.name} · ${DateFormatters.shortDate(expense.createdAt)}',
        ),
      _ when myShare > Decimal.zero => (
          '$symbol${CurrencyUtils.formatDecimal(myShare)}',
          AppColors.error,
          '${payer.name} paid · your share · ${DateFormatters.shortDate(expense.createdAt)}',
        ),
      _ => (
          '$symbol${CurrencyUtils.formatDecimal(expense.amount)}',
          muted,
          '${payer.name} paid · ${trip.name} · ${DateFormatters.shortDate(expense.createdAt)}',
        ),
    };

    return Pressable(
      onTap: () => SpendExpenseDetailSheet.show(context, line: line),
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
                            subtitle,
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
                        color: amountColor.withValues(alpha: isDark ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Text(
                        amountLabel,
                        style: spendItemText(
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: amountColor,
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
