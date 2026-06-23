import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/today_plan_utils.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../bottom_sheets/add_expense_bottom_sheet.dart';
import 'spend/spend_add_fab.dart';
import 'spend/spend_records_list.dart';
import 'spend/spend_settlement_card.dart';
import 'spend/spend_summary_card.dart';
import 'spend/spend_tab_utils.dart';
import 'spend/spend_today_strip.dart';
import 'spend_empty_state.dart';
import 'trip_detail_tab_scroll.dart';

class SpendTab extends StatelessWidget {
  const SpendTab({
    required this.trip,
    required this.days,
    required this.expenses,
    this.readOnly = false,
    super.key,
  });

  final Trip trip;
  final List<TripDay> days;
  final List<Expense> expenses;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final todayDay = trip.isInProgress ? TodayPlanUtils.todayDay(trip, days) : null;
    final hasExpenses = expenses.isNotEmpty;
    final grouped = SpendTabUtils.groupByDay(trip: trip, days: days, expenses: expenses);
    final totalSpending = SpendTabUtils.tripTotal(
      expenses: expenses,
      tripCurrency: trip.defaultCurrency,
    );

    final items = <Widget>[];

    if (todayDay != null) {
      items.add(
        SpendTodayStrip(
          todayDay: todayDay,
          currency: trip.defaultCurrency,
          todayTotal: TodayPlanUtils.todaySpendingTotal(
            trip: trip,
            days: days,
            expenses: expenses,
          ),
          expenseCount: TodayPlanUtils.todayExpenseCount(trip, days, expenses),
        ),
      );
      items.add(const SizedBox(height: AppSpacing.lg));
    }

    if (!hasExpenses) {
      items.add(SpendEmptyState(readOnly: readOnly));
    } else {
      items.add(
        SpendSummaryCard(
          totalSpending: totalSpending,
          currency: trip.defaultCurrency,
          expenses: expenses,
        ),
      );
      items.add(const SizedBox(height: AppSpacing.lg));
      items.add(
        SpendRecordsList(
          trip: trip,
          days: days,
          expenses: expenses,
          grouped: grouped,
          readOnly: readOnly,
          onExpenseTap: (expense) => _showExpenseSheet(context, editExpense: expense),
          onExpenseDelete: (expense) {
            HapticFeedback.mediumImpact();
            context.read<TripDetailBloc>().add(
                  TripDetailExpenseRemoved(expenseId: expense.id),
                );
          },
        ),
      );
      items.add(const SizedBox(height: AppSpacing.lg));
      items.add(SpendSettlementCard(trip: trip, expenses: expenses));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: readOnly
          ? null
          : SpendAddFab(onPressed: () => _showExpenseSheet(context, dayId: todayDay?.id)),
      body: TripDetailTabScroll(
        key: key,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              hasExpenses
                  ? AppSpacing.listBottomInset(context) + 72
                  : AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(items),
            ),
          ),
        ],
      ),
    );
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
