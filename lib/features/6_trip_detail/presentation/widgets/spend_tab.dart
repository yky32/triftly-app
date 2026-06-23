import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../../../core/services/split_calculator.dart';
import '../bottom_sheets/add_expense_bottom_sheet.dart';
import '../bottom_sheets/settlement_bottom_sheet.dart';
import 'trip_detail_tab_scroll.dart';

class SpendTab extends StatelessWidget {
  final Trip trip;
  final List<TripDay> days;
  final List<Expense> expenses;

  const SpendTab({
    required this.trip,
    required this.days,
    required this.expenses,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return TripDetailTabScroll(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No expenses yet',
              subtitle: 'Track spending and split with your group',
              action: () => _showAddExpense(context),
              actionLabel: 'Add expense',
            ),
          ),
        ],
      );
    }

    final totalSpending = expenses.fold<Decimal>(Decimal.zero, (sum, e) => sum + e.amount);
    final grouped = _groupByDay(expenses);

    return TripDetailTabScroll(
      key: key,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.listBottomInset(context),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SummaryCard(
                totalSpending: totalSpending,
                currency: trip.defaultCurrency,
                expenses: expenses,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...grouped.entries.expand((entry) {
                final day = entry.key;
                final dayExpenses = entry.value;
                return [
                  SectionHeader(title: _dayHeader(day)),
                  ...dayExpenses.map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ExpenseItem(expense: expense, buddies: trip.buddies),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ];
              }),
              _SettlementCard(
                trip: trip,
                expenses: expenses,
              ),
              const SizedBox(height: AppSpacing.md),
              _AddExpenseButton(onTap: () => _showAddExpense(context)),
            ]),
          ),
        ),
      ],
    );
  }

  void _showAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseBottomSheet(trip: trip),
    );
  }

  Map<TripDay?, List<Expense>> _groupByDay(List<Expense> expenses) {
    final map = <TripDay?, List<Expense>>{};
    for (final expense in expenses) {
      TripDay? day;
      if (expense.dayId != null) {
        for (final d in days) {
          if (d.id == expense.dayId) {
            day = d;
            break;
          }
        }
      }
      map.putIfAbsent(day, () => []).add(expense);
    }

    final sortedKeys = map.keys.toList()
      ..sort((a, b) {
        if (a == null && b == null) return 0;
        if (a == null) return 1;
        if (b == null) return -1;
        return a.dayNumber.compareTo(b.dayNumber);
      });

    return {for (final key in sortedKeys) key: map[key]!};
  }

  String _dayHeader(TripDay? day) {
    if (day == null) return 'Other';
    return '${day.displayTitleLine} · ${DateFormatters.shortDate(day.date)}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalSpending,
    required this.currency,
    required this.expenses,
  });

  final Decimal totalSpending;
  final String currency;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final converted = CurrencyUtils.approximateHkd(amount: totalSpending, currency: currency);

    return AppCard(
      color: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Spending', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            '$currency ${CurrencyUtils.formatDecimal(totalSpending)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
          ),
          if (converted != null) ...[
            const SizedBox(height: 2),
            Text(converted, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
          if (expenses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _CategoryBreakdown(expenses: expenses),
          ],
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, Decimal>{};
    for (final e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? Decimal.zero) + e.amount;
    }
    final maxAmount = categoryTotals.values.fold(Decimal.zero, (a, b) => a > b ? a : b);

    return Column(
      children: categoryTotals.entries.map((entry) {
        final category = SpotCategory.values.firstWhere(
          (c) => c.value == entry.key,
          orElse: () => SpotCategory.other,
        );
        final ratio = maxAmount > Decimal.zero ? (entry.value / maxAmount).toDouble() : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  '${category.emoji} ${category.label}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyUtils.formatDecimal(entry.value),
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  const _ExpenseItem({required this.expense, required this.buddies});

  final Expense expense;
  final List<Buddy> buddies;

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => SpotCategory.other,
    );
    final payer = buddies.firstWhere(
      (b) => b.id == expense.paidById,
      orElse: () => Buddy(id: '', name: 'Unknown'),
    );
    final categoryColor = AppColors.categoryColor(category);

    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: categoryColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text('${payer.name} paid', style: Theme.of(context).textTheme.bodySmall),
                          Text(_splitLabel(expense), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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

  String _splitLabel(Expense expense) {
    if (expense.splits.isEmpty) {
      return buddies.length == 1 ? 'Split: ${buddies.first.name}' : 'Split: All ${buddies.length}';
    }
    final names = expense.splits
        .map((split) => buddies.firstWhere((b) => b.id == split.buddyId, orElse: () => Buddy(id: '', name: '?')).name)
        .toList();
    return 'Split: ${names.join(', ')}';
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.trip,
    required this.expenses,
  });

  final Trip trip;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final transactions = SplitCalculator.calculateSettlement(expenses: expenses, buddies: trip.buddies);

    if (transactions.isEmpty) {
      return AppCard(
        child: Text(
          'All settled up',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
        ),
      );
    }

    return AppCard(
      onTap: () => SettlementBottomSheet.show(context, trip: trip, expenses: expenses),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Settlement', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...transactions.take(3).map((t) {
            final from = trip.buddies.firstWhere((b) => b.id == t.fromId, orElse: () => Buddy(id: '', name: '?'));
            final to = trip.buddies.firstWhere((b) => b.id == t.toId, orElse: () => Buddy(id: '', name: '?'));
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text('${from.name} → ${to.name}')),
                  Text(
                    '${trip.defaultCurrency} ${CurrencyUtils.formatDecimal(t.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  const _AddExpenseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Add expense', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
