import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_page.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: AppPage.values
            .map(
              (page) => NavigationDestination(
                icon: Icon(page.icon),
                selectedIcon: Icon(page.activeIcon),
                label: page.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
