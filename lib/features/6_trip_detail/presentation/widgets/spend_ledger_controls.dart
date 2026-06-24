import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_ledger_grouping.dart';

class SpendLedgerControls extends StatelessWidget {
  const SpendLedgerControls({
    required this.expenses,
    required this.tripCurrency,
    required this.groupBy,
    required this.categoryFilter,
    required this.onGroupByChanged,
    required this.onCategoryFilterChanged,
    super.key,
  });

  final List<Expense> expenses;
  final String tripCurrency;
  final SpendGroupBy groupBy;
  final String? categoryFilter;
  final ValueChanged<SpendGroupBy> onGroupByChanged;
  final ValueChanged<String?> onCategoryFilterChanged;

  static const _groupLabels = ['Day', 'Category', 'Person'];

  @override
  Widget build(BuildContext context) {
    final categoryTotals = SpendLedgerGrouping.sortedCategoryTotals(expenses, tripCurrency);
    final symbol = CurrencyUtils.symbolFor(tripCurrency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categoryTotals.isNotEmpty) ...[
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categoryTotals.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategoryFilterChip(
                    label: 'All',
                    amountLabel: null,
                    selected: categoryFilter == null,
                    onTap: () => onCategoryFilterChanged(null),
                  );
                }
                final row = categoryTotals[index - 1];
                return _CategoryFilterChip(
                  emoji: row.category.emoji,
                  label: row.category.label,
                  amountLabel: '$symbol${CurrencyUtils.formatDecimal(row.total)}',
                  selected: categoryFilter == row.category.value,
                  tint: AppColors.categoryColor(row.category),
                  onTap: () => onCategoryFilterChanged(
                    categoryFilter == row.category.value ? null : row.category.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          'Group by',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SheetChoiceChipRow(
          options: _groupLabels,
          selectedIndex: groupBy.index,
          onSelected: (index) => onGroupByChanged(SpendGroupBy.values[index]),
        ),
      ],
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.amountLabel,
    this.tint,
  });

  final String? emoji;
  final String label;
  final String? amountLabel;
  final bool selected;
  final Color? tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = tint ?? AppColors.primary;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.55) : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? accent : null,
                  ),
            ),
            if (amountLabel != null) ...[
              const SizedBox(width: 6),
              Text(
                amountLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SpendLedgerSectionHeader extends StatelessWidget {
  const SpendLedgerSectionHeader({
    required this.title,
    required this.totalLabel,
    this.badge,
    super.key,
  });

  final String title;
  final String totalLabel;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      badge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            totalLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class SpendFilteredEmptyHint extends StatelessWidget {
  const SpendFilteredEmptyHint({required this.onClearFilter, super.key});

  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'No expenses in this category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: onClearFilter, child: const Text('Show all')),
        ],
      ),
    );
  }
}
