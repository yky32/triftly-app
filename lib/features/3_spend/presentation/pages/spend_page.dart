import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/constants/app_page.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../5_trip_list/presentation/widgets/trip_phase_segment.dart';
import '../../bloc/spend_overview_bloc.dart';
import '../spend_wallet_summary.dart';
import '../widgets/spend_wallet_accent.dart';
import '../widgets/spend_wallet_activity.dart';
import '../widgets/spend_wallet_balances.dart';
import '../widgets/spend_wallet_card.dart';
import '../widgets/spend_wallet_trip_row.dart';

/// Global Spend page — personal wallet across all trips.
class SpendPage extends StatelessWidget {
  const SpendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _View();
  }
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  TripPhase? _selectedPhase;

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
            return _buildLoading(context);
          }

          final body = _buildBody(context, state);
          if (state.overview != null && state.errorMessage == null) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SpendOverviewBloc>().add(const SpendOverviewReloadRequested());
                await context.read<SpendOverviewBloc>().stream.firstWhere((s) => !s.isLoading);
              },
              child: body,
            );
          }

          return body;
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SpendOverviewState state) {
    if (state.errorMessage != null) {
      return EmptyState(
        expand: true,
        icon: Icons.error_outline_rounded,
        title: 'Could not load wallet',
        subtitle: state.errorMessage!,
        action: () => context.read<SpendOverviewBloc>().add(const SpendOverviewReloadRequested()),
        actionLabel: 'Retry',
      );
    }

    final overview = state.overview;
    if (overview == null) {
      return const SizedBox.shrink();
    }

    return _buildWalletScroll(context, overview);
  }

  Widget _buildWalletScroll(BuildContext context, GlobalSpendOverview overview) {
    final session = AppBootstrap.userSession;

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final summary = SpendWalletSummary.from(
          overview,
          preferredCurrency: session.defaultCurrency,
        );
        final selected = _selectedPhase ?? overview.defaultPhase();
        final trips = overview.sortedTrips(phase: selected);
        final balances = overview.buddyOweLines;
        final counts = overview.phaseCounts;
        final hasTripSpending = overview.tripsWithSpending.isNotEmpty;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.listBottomInset(context),
          ),
          children: [
            SpendWalletCard(summary: summary),
            if (balances.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              SpendWalletBalances(lines: balances),
            ],
            if (hasTripSpending) ...[
              const SizedBox(height: AppSpacing.xl),
              SpendSectionTitle(title: 'Trips', count: trips.length),
              const SizedBox(height: AppSpacing.sm),
              TripPhaseSegment(
                selected: selected,
                counts: counts,
                onChanged: (phase) => setState(() => _selectedPhase = phase),
              ),
              const SizedBox(height: AppSpacing.md),
              if (trips.isNotEmpty)
                SpendWalletTrips(snapshots: trips)
              else
                _buildPhaseEmpty(selected),
            ] else ...[
              const SizedBox(height: AppSpacing.xl),
              EmptyState(
                compact: true,
                icon: Icons.receipt_long_outlined,
                title: 'No expenses yet',
                action: () => context.go(AppPage.plan.path),
                actionLabel: 'Go to Trips',
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SpendWalletActivity(
              transactions: overview.recentTransactions,
              totalCount: overview.recentTransactions.length,
              onSeeAll: overview.recentTransactions.length > 8
                  ? () => context.push('${AppPage.spend.path}/recent')
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhaseEmpty(TripPhase phase) {
    final (icon, title) = switch (phase) {
      TripPhase.inProgress => (
          Icons.flight_takeoff_outlined,
          'No active trip spending',
        ),
      TripPhase.upcoming => (
          Icons.event_outlined,
          'No upcoming trip spending',
        ),
      TripPhase.completed => (
          Icons.check_circle_outline_rounded,
          'No past trip spending',
        ),
    };

    return EmptyState(
      compact: true,
      icon: icon,
      title: title,
    );
  }

  Widget _buildLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;

    return Skeletonizer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.listBottomInset(context),
        ),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 48,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadii.pill)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 20,
            width: 80,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadii.sm)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 120,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 160,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 200,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
        ],
      ),
    );
  }
}
