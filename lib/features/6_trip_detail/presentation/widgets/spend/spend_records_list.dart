import 'package:flutter/material.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/section_header.dart';
import 'spend_day_section.dart';
import 'spend_tab_utils.dart';

class SpendRecordsList extends StatelessWidget {
  const SpendRecordsList({
    required this.trip,
    required this.days,
    required this.expenses,
    required this.grouped,
    required this.readOnly,
    required this.onExpenseTap,
    required this.onExpenseDelete,
    super.key,
  });

  final Trip trip;
  final List<TripDay> days;
  final List<Expense> expenses;
  final Map<TripDay?, List<Expense>> grouped;
  final bool readOnly;
  final ValueChanged<Expense> onExpenseTap;
  final ValueChanged<Expense> onExpenseDelete;

  @override
  Widget build(BuildContext context) {
    final countLabel = '${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Records · $countLabel'),
        const SizedBox(height: AppSpacing.sm),
        ...grouped.entries.map((entry) {
          final day = entry.key;
          final dayExpenses = entry.value;
          return SpendDaySection(
            day: day,
            isToday: day != null && SpendTabUtils.isTodayDay(trip, day),
            dayTotal: SpendTabUtils.dayTotal(
              expenses: dayExpenses,
              tripCurrency: trip.defaultCurrency,
            ),
            currency: trip.defaultCurrency,
            expenses: dayExpenses,
            buddies: trip.buddies,
            tripCurrency: trip.defaultCurrency,
            readOnly: readOnly,
            onExpenseTap: onExpenseTap,
            onExpenseDelete: onExpenseDelete,
          );
        }),
      ],
    );
  }
}
