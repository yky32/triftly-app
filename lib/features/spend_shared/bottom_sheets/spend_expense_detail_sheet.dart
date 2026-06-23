import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';

/// Read-only expense detail before jumping to the trip Spend tab.
class SpendExpenseDetailSheet extends StatelessWidget {
  const SpendExpenseDetailSheet({required this.line, super.key});

  final SpendTransactionLine line;

  static Future<void> show(BuildContext context, {required SpendTransactionLine line}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpendExpenseDetailSheet(line: line),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expense = line.expense;
    final trip = line.trip;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payer = trip.buddies.firstWhere(
      (b) => b.id == expense.paidById,
      orElse: () => const Buddy(id: '', name: 'Unknown'),
    );
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => SpotCategory.other,
    );
    final symbol = CurrencyUtils.symbolFor(line.currency);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            expense.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${category.emoji} ${category.label} · ${trip.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Amount', value: '${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}'),
          if (line.myShare > Decimal.zero && !line.iPaid)
            _DetailRow(label: 'Your share', value: '$symbol${CurrencyUtils.formatDecimal(line.myShare)}'),
          _DetailRow(label: 'Paid by', value: payer.name),
          _DetailRow(label: 'Date', value: DateFormatters.shortDate(expense.createdAt)),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              SpendNavigation.openTripSpend(context, trip.id);
            },
            child: const Text('Open in trip'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
