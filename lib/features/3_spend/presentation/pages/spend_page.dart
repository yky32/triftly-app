import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/constants/app_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../bloc/spend_overview_bloc.dart';
import '../spend_wallet_summary.dart';
import '../widgets/spend_wallet_activity.dart';
import '../widgets/spend_wallet_card.dart';
import '../widgets/spend_wallet_trip_row.dart';

/// Global Spend page — personal wallet across all trips.
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
            return _buildLoading(context);
          }
          if (state.errorMessage != null) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load wallet',
              subtitle: state.errorMessage!,
              action: () => context.read<SpendOverviewBloc>().add(const SpendOverviewReloadRequested()),
              actionLabel: 'Retry',
            );
          }

          final overview = state.overview;
          if (overview == null || overview.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Your wallet is empty',
              subtitle: 'Log expenses in a trip and they will appear here.',
              action: () => context.go(AppPage.plan.path),
              actionLabel: 'Go to Trips',
            );
          }

          final summary = SpendWalletSummary.from(overview);
          final trips = overview.tripsWithSpending;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SpendOverviewBloc>().add(const SpendOverviewReloadRequested());
              await context.read<SpendOverviewBloc>().stream.firstWhere((s) => !s.isLoading);
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.listBottomInset(context),
              ),
              children: [
                SpendWalletCard(summary: summary),
                if (trips.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SpendWalletTrips(snapshots: trips),
                ],
                const SizedBox(height: AppSpacing.xl),
                SpendWalletActivity(transactions: overview.recentTransactions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Container(
            height: 168,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
          ),
        ],
      ),
    );
  }
}
