import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/constants/layout_constants.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/navigation/app_navigation.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/features/5_spend_tracker/bloc/spend_bloc.dart';
import 'package:triftly/widgets/design/triftly_layout.dart';
import 'package:triftly/widgets/design/triftly_page_header.dart';

/// **Spend** tab — trip budget and transactions (mock data until ledger ships).
class SpendTrackerPage extends StatelessWidget {
  const SpendTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpendBloc(
        repository: context.read<RoutineRepository>(),
      )..add(const SpendLoaded()),
      child: const _SpendView(),
    );
  }
}

class _SpendView extends StatelessWidget {
  const _SpendView();

  static const _mockBudget = 3500.0;
  static const _mockSpent = 2180.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<SpendBloc, SpendState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                TriftlyLayout.pagePadding,
                16,
                TriftlyLayout.pagePadding,
                LayoutConstants.scrollPaddingBelowNavBar(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TriftlyPageHeader(
                    title: context.l10n.page_spend_tracker,
                    subtitle: 'Track spending for the whole trip',
                  ),
                  const SizedBox(height: 20),
                  if (!state.hasActiveTrip)
                    TriftlyEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No active trip',
                      message:
                          'Spending links to the trip whose dates include today.',
                      action: FilledButton(
                        onPressed: () =>
                            AppNavigation.openTripPlanner(context),
                        child: const Text('Plan a trip'),
                      ),
                    )
                  else ...[
                    _BudgetRingCard(
                      tripName: state.tripName ?? 'Trip',
                      daysRemaining: state.daysRemaining,
                      spent: _mockSpent,
                      budget: _mockBudget,
                    ),
                    const SizedBox(height: 24),
                    const TriftlySectionLabel(title: 'By category'),
                    const SizedBox(height: 4),
                    const _CategoryList(),
                    const SizedBox(height: 24),
                    const TriftlySectionLabel(title: 'Recent'),
                    const SizedBox(height: 4),
                    const _TransactionList(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BudgetRingCard extends StatelessWidget {
  const _BudgetRingCard({
    required this.tripName,
    required this.daysRemaining,
    required this.spent,
    required this.budget,
  });

  final String tripName;
  final int daysRemaining;
  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (spent / budget).clamp(0.0, 1.0);
    final remaining = budget - spent;

    return TriftlySurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.fogGray.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.driftTeal,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (daysRemaining > 0)
                      Text(
                        '$daysRemaining days left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mistGray,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${spent.toStringAsFixed(0)} of \$${budget.toStringAsFixed(0)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepTeal,
                      ),
                    ),
                    Text(
                      '\$${remaining.toStringAsFixed(0)} remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mistGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  static const _items = [
    (Icons.hotel_rounded, 'Stay', 850.0, AppColors.driftTeal),
    (Icons.restaurant_rounded, 'Food', 620.0, AppColors.calmGreen),
    (Icons.directions_bus_rounded, 'Transport', 340.0, AppColors.softAmber),
    (Icons.local_activity_rounded, 'Activities', 280.0, AppColors.sunsetCoral),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TriftlySurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: _items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.$4.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1, size: 20, color: item.$4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.$2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '\$${item.$3.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  static const _tx = [
    ('Ichiran Ramen', 'Food', 24.0),
    ('JR Pass', 'Transport', 280.0),
    ('Shinjuku Hotel', 'Stay', 850.0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TriftlySurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: _tx.map((t) {
          return ListTile(
            dense: true,
            title: Text(
              t.$1,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              t.$2,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mistGray,
              ),
            ),
            trailing: Text(
              '-\$${t.$3.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
