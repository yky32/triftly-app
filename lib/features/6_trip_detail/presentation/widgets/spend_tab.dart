import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/services/split_calculator.dart';

class SpendTab extends StatelessWidget {
  final Trip trip;
  final List<Expense> expenses;

  const SpendTab({required this.trip, required this.expenses, super.key});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        subtitle: 'Track spending and split with your group',
      );
    }

    final totalSpending = expenses.fold<Decimal>(Decimal.zero, (sum, e) => sum + e.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
      children: [
        _SummaryCard(
          totalSpending: totalSpending,
          currency: trip.defaultCurrency,
          expenses: expenses,
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Recent'),
        ...expenses.map(
          (expense) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ExpenseItem(expense: expense, buddies: trip.buddies),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SettlementCard(
          expenses: expenses,
          buddies: trip.buddies,
          currency: trip.defaultCurrency,
        ),
      ],
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
    return AppCard(
      color: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            '$currency ${_formatDecimal(totalSpending)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
          ),
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
              Text(category.emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
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
                _formatDecimal(entry.value),
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

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text('${payer.name} paid', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${expense.currency} ${_formatDecimal(expense.amount)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.expenses,
    required this.buddies,
    required this.currency,
  });

  final List<Expense> expenses;
  final List<Buddy> buddies;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final transactions = SplitCalculator.calculateSettlement(expenses: expenses, buddies: buddies);

    if (transactions.isEmpty) {
      return AppCard(
        child: Text(
          'All settled up',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settlement', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...transactions.map((t) {
            final from = buddies.firstWhere((b) => b.id == t.fromId, orElse: () => Buddy(id: '', name: '?'));
            final to = buddies.firstWhere((b) => b.id == t.toId, orElse: () => Buddy(id: '', name: '?'));
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text('${from.name} → ${to.name}')),
                  Text('$currency ${_formatDecimal(t.amount)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _formatDecimal(Decimal d) {
  final str = d.toStringAsFixed(2);
  if (str.contains('.')) {
    final parts = str.split('.');
    if (parts[1] == '00') return parts[0];
    if (parts[1].endsWith('0')) return '${parts[0]}.${parts[1].substring(0, 1)}';
  }
  return str;
}
