import 'package:flutter/material.dart';

enum AppPage {
  explore(
    name: 'explore',
    path: '/explore',
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
    label: 'Explore',
    navBarMemberIndex: 0,
  ),
  plan(
    name: 'plan',
    path: '/plan',
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    label: 'Plan',
    navBarMemberIndex: 1,
  ),
  spend(
    name: 'spend',
    path: '/spend',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet,
    label: 'Spend',
    navBarMemberIndex: 2,
  ),
  profile(
    name: 'profile',
    path: '/profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Me',
    navBarMemberIndex: 3,
  );

  final String name;
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int navBarMemberIndex;

  const AppPage({
    required this.name,
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.navBarMemberIndex,
  });

  static AppPage fromIndex(int index) {
    return AppPage.values.firstWhere(
      (page) => page.navBarMemberIndex == index,
      orElse: () => AppPage.explore,
    );
  }
}
