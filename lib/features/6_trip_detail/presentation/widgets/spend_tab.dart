import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/triftly_motion.dart';
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

    if (expenses.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        subtitle: 'Track what you spend and split bills with buddies',
      );
    }

    return ListView(
      padding: AppSpacing.page,
      children: [
        _SummaryCard(
          totalSpending: totalSpending,
          currency: trip.defaultCurrency,
          expenses: expenses,
        ).fadeSlideIn(),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'RECENT'),
        ...expenses.asMap().entries.map((entry) {
          return _ExpenseItem(
            expense: entry.value,
            buddies: trip.buddies,
            index: entry.key,
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        _SettlementCard(
          expenses: expenses,
          buddies: trip.buddies,
          currency: trip.defaultCurrency,
        ).fadeSlideIn(delay: 200.ms),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadii.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Spending', style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            '$currency ${_formatDecimal(totalSpending)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1),
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
        final ratio = maxAmount > Decimal.zero ? (entry.value / maxAmount).toDouble() : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              SizedBox(
                width: 72,
                child: Text(
                  category.label,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatDecimal(entry.value),
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
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
  final int index;

  const _ExpenseItem({
    required this.expense,
    required this.buddies,
    required this.index,
  });

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

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${payer.name} paid',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${expense.currency} ${_formatDecimal(expense.amount)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    ).staggerIn(index);
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
    final transactions = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: buddies,
    );

    if (transactions.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.successMuted,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'All settled up!',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Settlement', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...transactions.asMap().entries.map((entry) {
            final t = entry.value;
            final from = buddies.firstWhere((b) => b.id == t.fromId, orElse: () => Buddy(id: '', name: '?'));
            final to = buddies.firstWhere((b) => b.id == t.toId, orElse: () => Buddy(id: '', name: '?'));
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text('${from.name} → ${to.name}', style: Theme.of(context).textTheme.bodyLarge)),
                  Text(
                    '$currency ${_formatDecimal(t.amount)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ).staggerIn(entry.key + 1);
          }),
          Text(
            'Only ${transactions.length} payment${transactions.length > 1 ? 's' : ''} needed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
