import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_page.dart';
import 'scaffold_with_nav_bar.dart';
import 'page_transitions.dart';
import '../../features/1_explore/presentation/pages/explore_page.dart';
import '../../features/4_profile/presentation/pages/profile_page.dart';
import '../../features/5_trip_list/presentation/pages/trip_list_page.dart';
import '../../features/6_trip_detail/presentation/pages/trip_detail_page.dart';
import '../../core/widgets/empty_state.dart';

final appRouter = GoRouter(
  initialLocation: AppPage.plan.path,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPage.explore.path,
              name: AppPage.explore.name,
              builder: (context, state) => const ExplorePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPage.plan.path,
              name: AppPage.plan.name,
              builder: (context, state) => const TripListPage(),
              routes: [
                GoRoute(
                  path: ':tripId',
                  name: 'trip_detail',
                  pageBuilder: (context, state) {
                    final tripId = state.pathParameters['tripId']!;
                    return triftlyPage(
                      state: state,
                      child: TripDetailPage(tripId: tripId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPage.spend.path,
              name: AppPage.spend.name,
              builder: (context, state) => const _SpendPlaceholder(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPage.profile.path,
              name: AppPage.profile.name,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _SpendPlaceholder extends StatelessWidget {
  const _SpendPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Track spending',
        subtitle: 'Open a trip from Plan to view expenses and settlements',
        action: () => context.go(AppPage.plan.path),
        actionLabel: 'Go to Plan',
      ),
    );
  }
}
