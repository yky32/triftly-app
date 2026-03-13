import 'package:flutter/material.dart';
import 'package:triftly/router/app_page.dart';

/// Bottom nav bar with 5 tabs: Today, My Trips, Routine, Map, Spend.
/// Driven by [AppPage]; shows only pages with navBarMemberIndex != 99.
class NavBarMembersWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBarMembersWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static List<AppPage> get _navPages {
    final list =
        AppPage.values.where((p) => p.navBarMemberIndex != 99).toList();
    list.sort((a, b) => a.navBarMemberIndex.compareTo(b.navBarMemberIndex));
    return list;
  }

  /// Short label for nav bar (fits 5 tabs).
  static String _navLabel(AppPage page) {
    switch (page) {
      case AppPage.today:
        return 'Today';
      case AppPage.trips:
        return 'Trips';
      case AppPage.routine:
        return 'Routine';
      case AppPage.map:
        return 'Map';
      case AppPage.spend:
        return 'Spend';
      default:
        return page.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final navPages = _navPages;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < navPages.length; i++)
            Expanded(
              child: _NavItem(
                page: navPages[i],
                label: _navLabel(navPages[i]),
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
                colorScheme: colorScheme,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppPage page;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavItem({
    required this.page,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              page.icon,
              size: 24,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
