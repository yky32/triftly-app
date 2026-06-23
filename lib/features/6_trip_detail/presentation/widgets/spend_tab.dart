import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_conversion.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/split_calculator.dart';
import '../bottom_sheets/add_expense_bottom_sheet.dart';
import '../bottom_sheets/settlement_bottom_sheet.dart';
import '../../bloc/trip_detail_bloc.dart';
import 'spend_empty_state.dart';
import 'trip_detail_tab_scroll.dart';

class SpendTab extends StatelessWidget {
  final Trip trip;
  final List<TripDay> days;
  final List<Expense> expenses;
  final bool readOnly;

  const SpendTab({
    required this.trip,
    required this.days,
    required this.expenses,
    this.readOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: readOnly ? null : _AddFab(onPressed: () => _showExpenseSheet(context)),
        body: TripDetailTabScroll(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: SpendEmptyState(
                  readOnly: readOnly,
                  onAddExpense: readOnly ? null : () => _showExpenseSheet(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final totalSpending = _tripTotal(expenses);
    final grouped = _groupByDay(expenses);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: readOnly ? null : _AddFab(onPressed: () => _showExpenseSheet(context)),
      body: TripDetailTabScroll(
        key: key,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.listBottomInset(context) + 72,
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
                  final isToday = day != null && _isTodayDay(day);
                  return [
                    _DaySectionHeader(
                      day: day,
                      isToday: isToday,
                      dayTotal: _dayTotal(dayExpenses),
                      currency: trip.defaultCurrency,
                    ),
                    ...dayExpenses.map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ExpenseDismissible(
                          expense: expense,
                          readOnly: readOnly,
                          child: _ExpenseItem(
                            expense: expense,
                            buddies: trip.buddies,
                            tripCurrency: trip.defaultCurrency,
                            onTap: readOnly
                                ? null
                                : () => _showExpenseSheet(context, editExpense: expense),
                          ),
                          onDelete: () {
                            HapticFeedback.mediumImpact();
                            context.read<TripDetailBloc>().add(
                                  TripDetailExpenseRemoved(expenseId: expense.id),
                                );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ];
                }),
                _SettlementCard(
                  trip: trip,
                  expenses: expenses,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Decimal _tripTotal(List<Expense> expenses) {
    return expenses.fold<Decimal>(
      Decimal.zero,
      (sum, e) =>
          sum +
          CurrencyConversion.toTripCurrency(
            amount: e.amount,
            currency: e.currency,
            tripCurrency: trip.defaultCurrency,
          ),
    );
  }

  Decimal _dayTotal(List<Expense> expenses) {
    return expenses.fold<Decimal>(
      Decimal.zero,
      (sum, e) =>
          sum +
          CurrencyConversion.toTripCurrency(
            amount: e.amount,
            currency: e.currency,
            tripCurrency: trip.defaultCurrency,
          ),
    );
  }

  bool _isTodayDay(TripDay day) {
    final current = trip.currentDayNumber;
    return current != null && day.dayNumber == current;
  }

  void _showExpenseSheet(BuildContext context, {Expense? editExpense}) {
    if (readOnly) return;
    AddExpenseBottomSheet.show(
      context,
      trip: trip,
      bloc: context.read<TripDetailBloc>(),
      editExpense: editExpense,
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

    final todayDayNumber = trip.currentDayNumber;
    final sortedKeys = map.keys.toList()
      ..sort((a, b) {
        if (todayDayNumber != null && trip.isInProgress) {
          final aIsToday = a?.dayNumber == todayDayNumber;
          final bIsToday = b?.dayNumber == todayDayNumber;
          if (aIsToday != bIsToday) return aIsToday ? -1 : 1;
        }
        if (a == null && b == null) return 0;
        if (a == null) return 1;
        if (b == null) return -1;
        return a.dayNumber.compareTo(b.dayNumber);
      });

    return {for (final key in sortedKeys) key: map[key]!};
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Expense'),
    );
  }
}

class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({
    required this.day,
    required this.isToday,
    required this.dayTotal,
    required this.currency,
  });

  final TripDay? day;
  final bool isToday;
  final Decimal dayTotal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final title = day == null
        ? 'Other'
        : '${day!.displayTitleLine} · ${DateFormatters.shortDate(day!.date)}';

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
            '$currency ${CurrencyUtils.formatDecimal(dayTotal)}',
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

class _ExpenseDismissible extends StatelessWidget {
  const _ExpenseDismissible({
    required this.expense,
    required this.child,
    required this.onDelete,
    required this.readOnly,
  });

  final Expense expense;
  final Widget child;
  final VoidCallback onDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (readOnly) return child;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadii.card,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete expense?'),
                content: Text('Remove "${expense.title}" from this trip.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: child,
    );
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
    final symbol = CurrencyUtils.symbolFor(currency);

    return AppCard(
      color: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Spending', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            '$symbol${CurrencyUtils.formatDecimal(totalSpending)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
          ),
          if (converted != null) ...[
            const SizedBox(height: 2),
            Text(converted, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
          if (expenses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _CategoryBreakdown(expenses: expenses, tripCurrency: currency),
          ],
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.expenses,
    required this.tripCurrency,
  });

  final List<Expense> expenses;
  final String tripCurrency;

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, Decimal>{};
    for (final e in expenses) {
      final converted = CurrencyConversion.toTripCurrency(
        amount: e.amount,
        currency: e.currency,
        tripCurrency: tripCurrency,
      );
      categoryTotals[e.category] = (categoryTotals[e.category] ?? Decimal.zero) + converted;
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
  const _ExpenseItem({
    required this.expense,
    required this.buddies,
    required this.tripCurrency,
    this.onTap,
  });

  final Expense expense;
  final List<Buddy> buddies;
  final String tripCurrency;
  final VoidCallback? onTap;

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
    final conversionLabel = CurrencyConversion.tripEquivalentLabel(
      amount: expense.amount,
      currency: expense.currency,
      tripCurrency: tripCurrency,
    );

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
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
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${expense.currency} ${CurrencyUtils.formatDecimal(expense.amount)}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (conversionLabel != null)
                          Text(conversionLabel, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                    ],
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
    if (expense.splits.every((s) => s.splitType == expense.splits.first.splitType)) {
      return switch (expense.splits.first.splitType) {
        SplitType.equal => 'Split: ${expense.splits.length} people',
        SplitType.percent => 'Split: percent',
        SplitType.amount => 'Split: fixed amounts',
        SplitType.share => 'Split: shares',
      };
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
    final transactions = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: trip.buddies,
      settleCurrency: trip.defaultCurrency,
    );
    final symbol = CurrencyUtils.symbolFor(trip.defaultCurrency);

    if (transactions.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'All settled up',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Settlement', style: Theme.of(context).textTheme.titleMedium),
              ),
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
                    '$symbol${CurrencyUtils.formatDecimal(t.amount)}',
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
