import 'package:flutter/material.dart';

enum AppPage {
  explore(
    name: 'explore',
    path: '/explore',
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
    label: 'Explore',
    showInNavBar: false,
    shellBranchIndex: null,
  ),
  plan(
    name: 'plan',
    path: '/plan',
    icon: Icons.flight_outlined,
    activeIcon: Icons.flight,
    label: 'Plan',
    showInNavBar: true,
    shellBranchIndex: 0,
  ),
  spend(
    name: 'spend',
    path: '/spend',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet,
    label: 'Spend',
    showInNavBar: true,
    shellBranchIndex: 1,
  ),
  tools(
    name: 'tools',
    path: '/tools',
    icon: Icons.widgets_outlined,
    activeIcon: Icons.widgets_rounded,
    label: 'Tools',
    showInNavBar: true,
    shellBranchIndex: 2,
  ),
  profile(
    name: 'profile',
    path: '/profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Me',
    showInNavBar: true,
    shellBranchIndex: 3,
  );

  final String name;
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showInNavBar;
  final int? shellBranchIndex;

  const AppPage({
    required this.name,
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.showInNavBar,
    required this.shellBranchIndex,
  });

  static List<AppPage> get navBarPages => values.where((page) => page.showInNavBar).toList();

  static AppPage fromShellIndex(int index) {
    return values.firstWhere(
      (page) => page.shellBranchIndex == index,
      orElse: () => AppPage.plan,
    );
  }

  /// Me tab uses account-circle icons when cloud-signed-in; other tabs unchanged.
  IconData resolveNavIcon({required bool selected, required bool isCloudSignedIn}) {
    if (this == AppPage.profile && isCloudSignedIn) {
      return selected ? Icons.account_circle : Icons.account_circle_outlined;
    }
    return selected ? activeIcon : icon;
  }
}
