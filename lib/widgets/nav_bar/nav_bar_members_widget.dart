import 'package:flutter/material.dart';
import 'package:triftly/core/constants/app_config.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/widgets/design/triftly_layout.dart';

/// Minimal floating nav: **Plan · Day · Spend**.
class NavBarMembersWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBarMembersWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static List<AppPage> get _navPages => AppConfig.enabledNavPages;

  static String _navLabel(AppPage page) {
    switch (page) {
      case AppPage.trips:
        return 'Plan';
      case AppPage.today:
        return 'Day';
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(TriftlyLayout.navRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              page.icon,
              size: 22,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
