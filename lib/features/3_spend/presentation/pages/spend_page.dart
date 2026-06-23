import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/constants/app_page.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../bloc/spend_overview_bloc.dart';
import '../widgets/spend_me_hero_card.dart';
import '../widgets/spend_recent_transactions.dart';
import '../widgets/spend_trip_balance_card.dart';

/// Global Spend page — personal view across all trips.
class SpendPage extends StatelessWidget {
  const SpendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpendOverviewBloc()..add(const SpendOverviewLoadRequested()),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const TriftlyAppBarTitle(title: 'Spend'),
      ),
      body: BlocBuilder<SpendOverviewBloc, SpendOverviewState>(
        builder: (context, state) {
          if (state.isLoading && state.overview == null) {
            return _buildLoading();
          }
          if (state.errorMessage != null) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load spending',
              subtitle: state.errorMessage!,
              action: () => context.read<SpendOverviewBloc>().add(const SpendOverviewReloadRequested()),
              actionLabel: 'Retry',
            );
          }

          final overview = state.overview;
          if (overview == null || overview.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No spending yet',
              subtitle: 'Open a trip and log expenses — they will show up here across all your travels.',
              action: () => context.go(AppPage.plan.path),
              actionLabel: 'Go to Trips',
            );
          }

          final trips = overview.tripsWithSpending;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SpendOverviewBloc>().add(const SpendOverviewReloadRequested());
              await context.read<SpendOverviewBloc>().stream.firstWhere((s) => !s.isLoading);
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.listBottomInset(context),
              ),
              children: [
                SpendMeHeroCard(overview: overview),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'By trip'),
                const SizedBox(height: AppSpacing.sm),
                ...trips.map(
                  (snap) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SpendTripBalanceCard(snapshot: snap),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SpendRecentTransactions(transactions: overview.recentTransactions),
                const SizedBox(height: AppSpacing.lg),
                _FutureIdeasCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Skeletonizer(
      child: ListView(
        padding: AppSpacing.page,
        children: List.generate(
          4,
          (_) => Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _FutureIdeasCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coming next',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _IdeaRow(icon: Icons.receipt_long_outlined, label: 'Expense detail sheet (tap → read → edit)'),
          const _IdeaRow(icon: Icons.people_outline_rounded, label: 'Per-buddy paid / owed breakdown'),
          const _IdeaRow(icon: Icons.filter_list_rounded, label: 'Search & filter transactions'),
          const _IdeaRow(icon: Icons.notifications_outlined, label: 'Settlement reminders'),
        ],
      ),
    );
  }
}

class _IdeaRow extends StatelessWidget {
  const _IdeaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
