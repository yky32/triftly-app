import 'package:go_router/go_router.dart';
import '../constants/app_page.dart';
import 'scaffold_with_nav_bar.dart';
import 'page_transitions.dart';
import '../../features/1_explore/presentation/pages/explore_page.dart';
import '../../features/2_tools/presentation/pages/tools_page.dart';
import '../../features/4_profile/presentation/pages/profile_page.dart';
import '../../features/3_spend/presentation/pages/spend_page.dart';
import '../../features/3_spend/presentation/pages/spend_recent_all_page.dart';
import '../../features/5_trip_list/presentation/pages/trip_list_page.dart';
import '../../features/6_trip_detail/presentation/pages/trip_detail_page.dart';
import '../../features/6_trip_detail/presentation/pages/shared_trip_view_page.dart';

final appRouter = GoRouter(
  initialLocation: AppPage.plan.path,
  routes: [
    GoRoute(
      path: '/s/:token',
      name: 'shared_trip',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        return SharedTripViewPage(shareToken: token);
      },
    ),
    GoRoute(
      path: AppPage.explore.path,
      name: AppPage.explore.name,
      builder: (context, state) => const ExplorePage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
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
                    final tab = state.uri.queryParameters['tab'];
                    final initialTabIndex = switch (tab) {
                      'spend' => 1,
                      'map' => 2,
                      _ => 0,
                    };
                    return triftlyPage(
                      state: state,
                      child: TripDetailPage(
                        tripId: tripId,
                        initialTabIndex: initialTabIndex,
                      ),
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
              builder: (context, state) => const SpendPage(),
              routes: [
                GoRoute(
                  path: 'recent',
                  name: 'spend_recent',
                  builder: (context, state) => const SpendRecentAllPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPage.tools.path,
              name: AppPage.tools.name,
              builder: (context, state) => const ToolsPage(),
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

