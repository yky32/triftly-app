import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_redirect.dart';
import '../constants/app_page.dart';
import '../navigation/shared_place_flow.dart';
import 'scaffold_with_nav_bar.dart';
import 'page_transitions.dart';
import 'shared_map_redirect.dart';
import '../../features/1_explore/presentation/pages/explore_page.dart';
import '../../features/2_tools/presentation/pages/tools_page.dart';
import '../../features/4_profile/presentation/pages/profile_page.dart';
import '../../features/3_spend/presentation/pages/spend_page.dart';
import '../../features/3_spend/presentation/pages/spend_recent_all_page.dart';
import '../../features/5_trip_list/presentation/pages/trip_list_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/6_trip_detail/presentation/pages/trip_detail_page.dart';
import '../../features/6_trip_detail/presentation/pages/shared_trip_view_page.dart';
import '../../features/splash/presentation/splash_page.dart';

/// Last in-app route — used when swallowing duplicate `triftly://map` links.
/// Cannot use `GoRouter.of(context)` in redirect (router not mounted yet on startup).
String _lastKnownPath = '/splash';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    // OAuth returns via triftly://login-callback — not a screen route.
    if (AuthRedirect.isOAuthCallback(state.uri)) {
      _rememberPath(AppPage.profile.path);
      return AppPage.profile.path;
    }
    // triftly://map?url=… — share / simulator; not a go_router page.
    if (SharedMapRedirect.isMapInbound(state.uri)) {
      return SharedMapRedirect.redirectFromRouter(
        state.uri,
        fallbackPath: _routerFallbackPath(),
      );
    }
    _rememberPathFromState(state);
    return null;
  },
  errorBuilder: (context, state) {
    if (SharedMapRedirect.isMapInbound(state.uri)) {
      final target = SharedMapRedirect.redirectPath(
        state.uri,
        fallbackPath: _routerFallbackPath(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(target);
      });
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const SizedBox.expand(),
      );
    }
    return const _RouterNotFound();
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/s/:token',
      name: 'shared_trip',
      pageBuilder: (context, state) {
        final token = state.pathParameters['token']!;
        return triftlyPage(
          state: state,
          onEdgeSwipeBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppPage.plan.path);
            }
          },
          child: SharedTripViewPage(shareToken: token),
        );
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
                  path: 'notifications',
                  name: 'notifications',
                  pageBuilder: (context, state) => triftlyPage(
                    state: state,
                    child: const NotificationsPage(),
                  ),
                ),
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
                      onEdgeSwipeBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppPage.plan.path);
                        }
                      },
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
                  pageBuilder: (context, state) => triftlyPage(
                    state: state,
                    child: const SpendRecentAllPage(),
                  ),
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

void _rememberPath(String path) {
  if (path.isNotEmpty && !path.startsWith('triftly:')) {
    _lastKnownPath = path;
  }
}

void _rememberPathFromState(GoRouterState state) {
  if (state.uri.scheme == 'triftly') return;
  final path = state.uri.path;
  if (path.isEmpty || path == '/') return;
  _rememberPath(state.uri.hasQuery ? '${state.uri.path}?${state.uri.query}' : path);
}

String _routerFallbackPath() {
  if (SharedPlaceFlow.pendingPlace != null) return AppPage.plan.path;
  return _lastKnownPath;
}

class _RouterNotFound extends StatelessWidget {
  const _RouterNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: TextButton(onPressed: () => context.go(AppPage.plan.path), child: const Text('Home')),
      ),
    );
  }
}

