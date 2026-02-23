import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sample_app/widgets/nav_bar_members_widget.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: -25,
            child: SafeArea(
              top: false,
              child: NavBarMembersWidget(
                currentIndex: navigationShell.currentIndex,
                onTap: navigationShell.goBranch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
