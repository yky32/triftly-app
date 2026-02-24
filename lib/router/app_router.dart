import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triftly/features/map_view/presentation/pages/map_view_page.dart';
import 'package:triftly/features/routine_builder/presentation/pages/routine_builder_page.dart';
import 'package:triftly/features/settings/presentation/pages/settings_page.dart';
import 'package:triftly/features/spend_tracker/presentation/pages/spend_tracker_page.dart';
import 'package:triftly/features/today/presentation/pages/today_page.dart';
import 'package:triftly/features/trips/presentation/pages/trips_page.dart';
import 'package:triftly/features/login/presentation/pages/login_page.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/widgets/nav_bar/scaffold_with_nav_bar.dart';
import 'package:triftly/widgets/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final Map<AppPage, Widget Function()> _appPages = {
    AppPage.today: () => const TodayPage(),
    AppPage.trips: () => const TripsPage(),
    AppPage.routine: () => const RoutineBuilderPage(),
    AppPage.map: () => const MapViewPage(),
    AppPage.spend: () => const SpendTrackerPage(),
  };

  static final Map<AppPage, Widget Function()> _standaloneAppPages = {
    AppPage.login: () => const LoginPage(),
    AppPage.settings: () => const SettingsPage(),
  };

  static List<StatefulShellBranch> get _navigationBranches {
    final navPages = AppPage.values
        .where((p) => p.navBarMemberIndex != 99)
        .toList()
      ..sort((a, b) => a.navBarMemberIndex.compareTo(b.navBarMemberIndex));
    return navPages
        .map(
          (page) => StatefulShellBranch(
            routes: [
              GoRoute(
                name: page.name,
                path: page.path,
                builder: (_, __) => _appPages[page]!(),
              ),
            ],
          ),
        )
        .toList();
  }

  static List<GoRoute> get _standaloneRoutes {
    return AppPage.values
        .where((p) => p.navBarMemberIndex == 99)
        .map(
          (page) => GoRoute(
            name: page.name,
            path: page.path,
            builder: (_, __) => _standaloneAppPages[page]!(),
          ),
        )
        .toList();
  }

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || path.isEmpty) return '/splash';
      return null;
    },
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      ..._standaloneRoutes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: _navigationBranches,
      ),
    ],
  );
}
