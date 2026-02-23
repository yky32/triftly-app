import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sample_app/features/home/presentation/pages/home_page.dart';
import 'package:sample_app/features/login/presentation/pages/login_page.dart';
import 'package:sample_app/features/settings/presentation/pages/settings_page.dart';
import 'package:sample_app/router/app_page.dart';
import 'package:sample_app/widgets/scaffold_with_nav_bar.dart';
import 'package:sample_app/widgets/splash_screen.dart';

/// Placeholder pages for nav tabs (skeleton only).
Widget _explorePageBuilder() => const _PlaceholderPage(title: 'Explore', icon: Icons.explore);
Widget _activityPageBuilder() => const _PlaceholderPage(title: 'Activity', icon: Icons.dashboard);

class AppRouter {
  AppRouter._();

  static final Map<AppPage, Widget Function()> _appPages = {
    AppPage.home: () => const HomePage(),
    AppPage.explore: _explorePageBuilder,
    AppPage.activity: _activityPageBuilder,
    AppPage.settings: () => const SettingsPage(),
  };

  static final Map<AppPage, Widget Function()> _standaloneAppPages = {
    AppPage.login: () => const LoginPage(),
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

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
