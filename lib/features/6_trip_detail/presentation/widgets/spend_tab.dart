import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/split_calculator.dart';

class SpendTab extends StatelessWidget {
  final Trip trip;
  final List<Expense> expenses;

  const SpendTab({required this.trip, required this.expenses, super.key});

  @override
  Widget build(BuildContext context) {
    final totalSpending = expenses.fold<Decimal>(
      Decimal.zero,
      (sum, e) => sum + e.amount,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Summary card
        _SummaryCard(
          totalSpending: totalSpending,
          currency: trip.defaultCurrency,
          expenses: expenses,
        ),
        const SizedBox(height: 16),

        // Expenses by day
        if (expenses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text('No expenses yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            ),
          )
        else ...[
          const Text('Recent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...expenses.map((expense) => _ExpenseItem(
            expense: expense,
            buddies: trip.buddies,
          )),
          const SizedBox(height: 16),

          // Settlement card
          _SettlementCard(
            expenses: expenses,
            buddies: trip.buddies,
            currency: trip.defaultCurrency,
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Decimal totalSpending;
  final String currency;
  final List<Expense> expenses;

  const _SummaryCard({
    required this.totalSpending,
    required this.currency,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF4DA3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Spending', style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            '$currency ${_formatDecimal(totalSpending)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          if (expenses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _CategoryBreakdown(expenses: expenses),
          ],
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<Expense> expenses;

  const _CategoryBreakdown({required this.expenses});

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
        final ratio = maxAmount > Decimal.zero
            ? (entry.value / maxAmount).toDouble()
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '${category.label} ${_formatDecimal(entry.value)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final Expense expense;
  final List<Buddy> buddies;

  const _ExpenseItem({required this.expense, required this.buddies});

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => SpotCategory.other,
    );
    final color = AppColors.categoryColor(category);
    final payer = buddies.firstWhere(
      (b) => b.id == expense.paidById,
      orElse: () => Buddy(id: '', name: 'Unknown'),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          expense.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${payer.name} paid · ${expense.currency} ${_formatDecimal(expense.amount)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (expense.splits.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Split: ${expense.splits.map((s) {
                        final b = buddies.firstWhere((b) => b.id == s.buddyId, orElse: () => Buddy(id: '', name: '?'));
                        return b.name;
                      }).join(', ')}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final List<Expense> expenses;
  final List<Buddy> buddies;
  final String currency;

  const _SettlementCard({
    required this.expenses,
    required this.buddies,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    final transactions = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: buddies,
    );

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('All settled up!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Settlement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ...transactions.map((t) {
            final from = buddies.firstWhere((b) => b.id == t.fromId, orElse: () => Buddy(id: '', name: '?'));
            final to = buddies.firstWhere((b) => b.id == t.toId, orElse: () => Buddy(id: '', name: '?'));
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${from.name} → ${to.name}', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                  Text('$currency ${_formatDecimal(t.amount)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            'Only ${transactions.length} transaction${transactions.length > 1 ? 's' : ''} needed!',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

String _formatDecimal(Decimal d) {
  final str = d.toStringAsFixed(2);
  // Remove trailing zeros after decimal
  if (str.contains('.')) {
    final parts = str.split('.');
    if (parts[1] == '00') return parts[0];
    if (parts[1].endsWith('0')) return '${parts[0]}.${parts[1].substring(0, 1)}';
  }
  return str;
}
