import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_conversion.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_overview_metric_card.dart';

class SpendCategoryBreakdownCard extends StatefulWidget {
  const SpendCategoryBreakdownCard({
    required this.expenses,
    required this.tripCurrency,
    this.collapsedPreviewCount = 2,
    super.key,
  });

  final List<Expense> expenses;
  final String tripCurrency;
  final int collapsedPreviewCount;

  @override
  State<SpendCategoryBreakdownCard> createState() => _SpendCategoryBreakdownCardState();
}

class _SpendCategoryBreakdownCardState extends State<SpendCategoryBreakdownCard> {
  bool _expanded = false;

  List<({SpotCategory category, Decimal total})> get _entries {
    final categoryTotals = <String, Decimal>{};
    for (final expense in widget.expenses) {
      final converted = CurrencyConversion.toTripCurrency(
        amount: expense.amount,
        currency: expense.currency,
        tripCurrency: widget.tripCurrency,
      );
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? Decimal.zero) + converted;
    }

    final entries = categoryTotals.entries.map((entry) {
      final category = SpotCategory.values.firstWhere(
        (c) => c.value == entry.key,
        orElse: () => SpotCategory.other,
      );
      return (category: category, total: entry.value);
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return entries;
  }

  bool get _canCollapse => _entries.length > widget.collapsedPreviewCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = _entries;
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxAmount = entries.first.total;
    final visibleEntries = !_canCollapse || _expanded
        ? entries
        : entries.take(widget.collapsedPreviewCount).toList();
    final hiddenCount = entries.length - visibleEntries.length;

    return SpendGlassShell(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Pressable(
            onTap: _canCollapse ? () => setState(() => _expanded = !_expanded) : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'BY CATEGORY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.45,
                        ),
                  ),
                ),
                Text(
                  '${entries.length} ${entries.length == 1 ? 'type' : 'types'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (_canCollapse) ...[
                  const SizedBox(width: AppSpacing.xs),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (var i = 0; i < visibleEntries.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _CategoryRow(
                    category: visibleEntries[i].category,
                    total: visibleEntries[i].total,
                    ratio: maxAmount > Decimal.zero
                        ? (visibleEntries[i].total / maxAmount).toDouble()
                        : 0,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
          if (_canCollapse && !_expanded && hiddenCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '+ $hiddenCount more ${hiddenCount == 1 ? 'category' : 'categories'}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.total,
    required this.ratio,
    required this.isDark,
  });

  final SpotCategory category;
  final Decimal total;
  final double ratio;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final barColor = AppColors.categoryColor(category);
    final trackColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            '${category.emoji} ${category.label}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: trackColor,
              color: barColor,
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 52,
          child: Text(
            CurrencyUtils.formatDecimal(total),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ),
      ],
    );
  }
}
