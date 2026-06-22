import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_surface.dart';
import '../widgets/triftly_motion.dart';

/// Shell with a floating glass nav island overlaid on tab content.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const double _islandBottomGap = 18;
  static const double _islandHorizontalInset = 22;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: navigationShell),
          Positioned(
            left: _islandHorizontalInset,
            right: _islandHorizontalInset,
            bottom: bottomSafe + _islandBottomGap,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _FloatingGlassNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingGlassNavBar extends StatelessWidget {
  const _FloatingGlassNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      blur: 32,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        children: AppPage.values.map((page) {
          final isSelected = page.navBarMemberIndex == currentIndex;
          return Expanded(
            child: _NavItem(
              page: page,
              isSelected: isSelected,
              onTap: () => onTap(page.navBarMemberIndex),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final AppPage page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? page.activeIcon : page.icon,
              size: 22,
              color: isSelected ? AppColors.primaryDark : AppColors.textTertiary,
            ),
            const SizedBox(height: 3),
            Text(
              page.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
