import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../core/utils/date_formatters.dart';
import 'spend_expense_item.dart';

class SpendDaySection extends StatelessWidget {
  const SpendDaySection({
    required this.day,
    required this.isToday,
    required this.dayTotal,
    required this.currency,
    required this.expenses,
    required this.buddies,
    required this.tripCurrency,
    required this.readOnly,
    required this.onExpenseTap,
    required this.onExpenseDelete,
    super.key,
  });

  final TripDay? day;
  final bool isToday;
  final Decimal dayTotal;
  final String currency;
  final List<Expense> expenses;
  final List<Buddy> buddies;
  final String tripCurrency;
  final bool readOnly;
  final ValueChanged<Expense> onExpenseTap;
  final ValueChanged<Expense> onExpenseDelete;

  @override
  Widget build(BuildContext context) {
    final title = day == null
        ? 'Other'
        : '${day!.displayTitleLine} · ${DateFormatters.shortDate(day!.date)}';
    final symbol = CurrencyUtils.symbolFor(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          'Today',
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
                '$symbol${CurrencyUtils.formatDecimal(dayTotal)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        ...expenses.map(
          (expense) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SpendExpenseDismissible(
              expense: expense,
              readOnly: readOnly,
              onDelete: () => onExpenseDelete(expense),
              child: SpendExpenseItem(
                expense: expense,
                buddies: buddies,
                tripCurrency: tripCurrency,
                onTap: readOnly ? null : () => onExpenseTap(expense),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
