import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/core/constants/app_config.dart';
import 'package:triftly/features/4_map_view/presentation/pages/map_view_page.dart';
import 'package:triftly/features/3_routine_builder/models/routine_spot.dart';
import 'package:triftly/features/3_routine_builder/presentation/pages/routine_builder_page.dart';
import 'package:triftly/features/_standalone/settings/presentation/pages/settings_page.dart';
import 'package:triftly/features/_standalone/login/presentation/pages/login_page.dart';
import 'package:triftly/features/5_spend_tracker/presentation/pages/spend_tracker_page.dart';
import 'package:triftly/features/2_trips/presentation/pages/trips_page.dart';
import 'package:triftly/features/1_today/presentation/pages/today_page.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/widgets/nav_bar/scaffold_with_nav_bar.dart';
import 'package:triftly/widgets/splash_screen.dart';

class AppRouter {
  AppRouter._();

  /// Shell tabs (bottom nav).
  static final Map<AppPage, Widget Function(Object? extra)> _shellPages = {
    AppPage.today: (_) => const TodayPage(),
    AppPage.trips: (_) => const TripsPage(),
    AppPage.spend: (_) => const SpendTrackerPage(),
  };

  /// Full-screen flows (no bottom nav).
  static final Map<AppPage, Widget Function(Object? extra)> _overlayPages = {
    AppPage.routine: (extra) =>
        RoutineBuilderPage(pendingSpotFromMap: extra as RoutineSpot?),
    AppPage.map: (extra) => MapViewPage(sharedLocation: extra as LatLng?),
  };

  static final Map<AppPage, Widget Function()> _standaloneAppPages = {
    AppPage.login: () => const LoginPage(),
    AppPage.settings: () => const SettingsPage(),
  };

  static List<StatefulShellBranch> get _navigationBranches {
    final navPages = AppConfig.enabledNavPages;
    return navPages
        .map(
          (page) => StatefulShellBranch(
            routes: [
              GoRoute(
                name: page.name,
                path: page.path,
                builder: (_, state) => _shellPages[page]!(state.extra),
              ),
            ],
          ),
        )
        .toList();
  }

  static List<GoRoute> get _standaloneRoutes {
    return AppPage.values
        .where((p) => p.navBarMemberIndex == 99 && AppConfig.isPageEnabled(p))
        .where((p) => _standaloneAppPages.containsKey(p))
        .map(
          (page) => GoRoute(
            name: page.name,
            path: page.path,
            builder: (_, __) => _standaloneAppPages[page]!(),
          ),
        )
        .toList();
  }

  static List<GoRoute> get _overlayRoutes {
    return AppPage.values
        .where((p) => p.navBarMemberIndex == 99 && AppConfig.isPageEnabled(p))
        .where((p) => _overlayPages.containsKey(p))
        .map(
          (page) => GoRoute(
            name: page.name,
            path: page.path,
            builder: (_, state) => _overlayPages[page]!(state.extra),
          ),
        )
        .toList();
  }

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || path.isEmpty) return '/splash';
      // Legacy route from earlier builds.
      if (path == '/routine') return AppPage.routine.path;
      return null;
    },
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      ..._standaloneRoutes,
      ..._overlayRoutes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: _navigationBranches,
      ),
    ],
  );
}
