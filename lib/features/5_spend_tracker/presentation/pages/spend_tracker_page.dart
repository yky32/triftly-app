import 'package:flutter/material.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/theme/app_colors.dart';

class SpendTrackerPage extends StatelessWidget {
  const SpendTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.page_spend_tracker,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: AppColors.driftTeal,
                    onPressed: () {},
                    tooltip: 'Add expense',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Trip Budget Overview ─────────────────────────────────
              _TripBudgetCard(
                tripName: 'Japan Spring Tour',
                totalBudget: 3500,
                spent: 2180,
                currency: 'USD',
              ),

              const SizedBox(height: 24),

              // ── Spending by Category ─────────────────────────────────
              _SectionHeader(title: 'Spending by Category'),
              const SizedBox(height: 12),
              const _CategoryBreakdown(),

              const SizedBox(height: 24),

              // ── Recent Transactions ──────────────────────────────────
              _SectionHeader(
                title: 'Recent Transactions',
                action: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _RecentTransactions(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trip Budget Card ─────────────────────────────────────────────────────────

class _TripBudgetCard extends StatelessWidget {
  const _TripBudgetCard({
    required this.tripName,
    required this.totalBudget,
    required this.spent,
    required this.currency,
  });

  final String tripName;
  final double totalBudget;
  final double spent;
  final String currency;

  double get remaining => totalBudget - spent;
  double get progress => (spent / totalBudget).clamp(0.0, 1.0);
  bool get isOverBudget => spent > totalBudget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.driftTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIVE TRIP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.driftTeal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                currency,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tripName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.fogGray.withValues(alpha: 0.30),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppColors.mutedRed : AppColors.driftTeal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BudgetMetric(
                label: 'Spent',
                amount: spent,
                color: isOverBudget ? AppColors.mutedRed : AppColors.driftTeal,
              ),
              const Spacer(),
              _BudgetMetric(
                label: 'Remaining',
                amount: remaining,
                color: remaining < 0 ? AppColors.mutedRed : AppColors.calmGreen,
              ),
              const Spacer(),
              _BudgetMetric(
                label: 'Budget',
                amount: totalBudget,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (action != null) ...[const Spacer(), action!],
      ],
    );
  }
}

// ── Category Breakdown ───────────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown();

  static const _categories = [
    _Category('Accommodation', 850, AppColors.driftTeal, Icons.hotel_rounded),
    _Category('Food & Dining', 620, AppColors.calmGreen, Icons.restaurant_rounded),
    _Category('Transport', 340, AppColors.softAmber, Icons.directions_bus_rounded),
    _Category('Activities', 280, AppColors.sunsetCoral, Icons.local_activity_rounded),
    _Category('Shopping', 90, AppColors.deepTeal, Icons.shopping_bag_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _categories
            .map((c) => _CategoryRow(category: c))
            .toList(),
      ),
    );
  }
}

class _Category {
  const _Category(this.name, this.amount, this.color, this.icon);
  final String name;
  final double amount;
  final Color color;
  final IconData icon;
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, size: 18, color: category.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '\$${category.amount.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Transactions ──────────────────────────────────────────────────────

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  static const _transactions = [
    _Transaction('Ichiran Ramen', 'Food & Dining', 24, 'Mar 14'),
    _Transaction('JR Pass 7-day', 'Transport', 280, 'Mar 13'),
    _Transaction('Shinjuku Hotel', 'Accommodation', 850, 'Mar 10'),
    _Transaction('TeamLab Tickets', 'Activities', 45, 'Mar 12'),
    _Transaction('Convenience Store', 'Shopping', 12, 'Mar 14'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) => _TransactionTile(transaction: _transactions[index]),
      ),
    );
  }
}

class _Transaction {
  const _Transaction(this.title, this.category, this.amount, this.date);
  final String title;
  final String category;
  final double amount;
  final String date;
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final _Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} · ${transaction.date}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-\$${transaction.amount.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
