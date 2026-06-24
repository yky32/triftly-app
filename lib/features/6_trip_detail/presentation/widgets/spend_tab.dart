import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_conversion.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/today_plan_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/split_calculator.dart';
import '../bottom_sheets/add_expense_bottom_sheet.dart';
import '../bottom_sheets/settlement_bottom_sheet.dart';
import '../../bloc/trip_detail_bloc.dart';
import 'today_spend_card.dart';
import 'trip_detail_tab_scroll.dart';
import 'spend_ledger_controls.dart';
import 'spend_ledger_grouping.dart';

class SpendTab extends StatefulWidget {
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
  State<SpendTab> createState() => _SpendTabState();
}

class _SpendTabState extends State<SpendTab> {
  SpendGroupBy _groupBy = SpendGroupBy.day;
  String? _categoryFilter;

  Trip get trip => widget.trip;
  List<TripDay> get days => widget.days;
  List<Expense> get expenses => widget.expenses;
  bool get readOnly => widget.readOnly;

  @override
  Widget build(BuildContext context) {
    final todayDay = trip.isInProgress ? TodayPlanUtils.todayDay(trip, days) : null;
    final todayCard = todayDay == null
        ? null
        : TodaySpendCard(
            trip: trip,
            todayDay: todayDay,
            compact: true,
            todayTotal: TodayPlanUtils.todaySpendingTotal(
              trip: trip,
              days: days,
              expenses: expenses,
            ),
            expenseCount: TodayPlanUtils.todayExpenseCount(trip, days, expenses),
            onAddExpense: readOnly
                ? null
                : () => _showExpenseSheet(context, dayId: todayDay.id),
          );

    Widget buildOverviewRow({
      required Decimal totalSpending,
      String? emptyBadgeLabel,
    }) {
      return _SpendOverviewRow(
        todayCard: todayCard,
        summaryCard: _SummaryCard(
          compact: true,
          totalSpending: totalSpending,
          currency: trip.defaultCurrency,
          expenses: expenses,
          emptyBadgeLabel: emptyBadgeLabel,
        ),
      );
    }

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
                child: buildOverviewRow(
                  totalSpending: Decimal.zero,
                  emptyBadgeLabel: readOnly ? 'No spending' : 'No expenses',
                ),
              ),
            ),
          ],
        ),
      );
    }

    final totalSpending = _tripTotal(expenses);
    final visibleExpenses = SpendLedgerGrouping.filterByCategory(expenses, _categoryFilter);
    final sections = SpendLedgerGrouping.buildSections(
      groupBy: _groupBy,
      expenses: visibleExpenses,
      days: days,
      trip: trip,
      buddies: trip.buddies,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: readOnly ? null : _AddFab(onPressed: () => _showExpenseSheet(context)),
      body: TripDetailTabScroll(
        key: widget.key,
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
                buildOverviewRow(totalSpending: totalSpending),
                const SizedBox(height: AppSpacing.lg),
                SpendLedgerControls(
                  expenses: expenses,
                  tripCurrency: trip.defaultCurrency,
                  groupBy: _groupBy,
                  categoryFilter: _categoryFilter,
                  onGroupByChanged: (value) => setState(() => _groupBy = value),
                  onCategoryFilterChanged: (value) => setState(() => _categoryFilter = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (visibleExpenses.isEmpty && _categoryFilter != null)
                  SpendFilteredEmptyHint(onClearFilter: () => setState(() => _categoryFilter = null))
                else
                  ...sections.expand((section) {
                    return [
                      SpendLedgerSectionHeader(
                        title: section.title,
                        badge: section.badge,
                        totalLabel: SpendLedgerGrouping.formatTotal(section.total, trip.defaultCurrency),
                      ),
                      ...section.expenses.map(
                        (expense) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ExpenseDismissible(
                            expense: expense,
                            readOnly: readOnly,
                            child: _ExpenseItem(
                              expense: expense,
                              buddies: trip.buddies,
                              tripCurrency: trip.defaultCurrency,
                              showDayContext: _groupBy != SpendGroupBy.day,
                              dayLabel: SpendLedgerGrouping.dayLabelForExpense(expense, days),
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
    return SpendLedgerGrouping.sumExpenses(expenses, trip.defaultCurrency);
  }

  void _showExpenseSheet(BuildContext context, {Expense? editExpense, String? dayId}) {
    if (readOnly) return;
    AddExpenseBottomSheet.show(
      context,
      trip: trip,
      bloc: context.read<TripDetailBloc>(),
      editExpense: editExpense,
      initialDayId: dayId,
    );
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

class _SpendOverviewRow extends StatelessWidget {
  const _SpendOverviewRow({
    required this.summaryCard,
    this.todayCard,
  });

  final Widget? todayCard;
  final Widget summaryCard;

  @override
  Widget build(BuildContext context) {
    if (todayCard == null) return summaryCard;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: todayCard!),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: summaryCard),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalSpending,
    required this.currency,
    required this.expenses,
    this.compact = false,
    this.emptyBadgeLabel,
  });

  final Decimal totalSpending;
  final String currency;
  final List<Expense> expenses;
  final bool compact;
  final String? emptyBadgeLabel;

  @override
  Widget build(BuildContext context) {
    final converted = CurrencyUtils.approximateHkd(amount: totalSpending, currency: currency);
    final symbol = CurrencyUtils.symbolFor(currency);
    final amountStyle = TextStyle(
      fontSize: compact ? 22 : 30,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.5,
      height: compact ? 1.1 : null,
    );

    return AppCard(
      color: AppColors.primaryDark,
      padding: compact ? const EdgeInsets.all(AppSpacing.md) : const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compact ? 'Total' : 'Total Spending',
                  style: (compact
                          ? Theme.of(context).textTheme.labelSmall
                          : Theme.of(context).textTheme.bodySmall)
                      ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: compact ? AppSpacing.sm : 4),
                Text(
                  '$symbol${CurrencyUtils.formatDecimal(totalSpending)}',
                  style: amountStyle,
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (converted != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    converted,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: compact ? 11 : null,
                        ),
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (emptyBadgeLabel != null)
            Positioned(
              top: 0,
              right: 0,
              child: _SpendEmptyBadge(label: emptyBadgeLabel!),
            ),
        ],
      ),
    );
  }
}

class _SpendEmptyBadge extends StatelessWidget {
  const _SpendEmptyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  const _ExpenseItem({
    required this.expense,
    required this.buddies,
    required this.tripCurrency,
    this.showDayContext = false,
    this.dayLabel,
    this.onTap,
  });

  final Expense expense;
  final List<Buddy> buddies;
  final String tripCurrency;
  final bool showDayContext;
  final String? dayLabel;
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
    final detailParts = <String>['${payer.name} paid'];
    if (showDayContext && dayLabel != null) detailParts.add(dayLabel!);
    if (showDayContext && dayLabel == null) detailParts.add('Unassigned day');

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
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                expense.title,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadii.sm),
                                ),
                                child: Text(
                                  category.label,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: categoryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Text(detailParts.join(' · '), style: Theme.of(context).textTheme.bodySmall),
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
