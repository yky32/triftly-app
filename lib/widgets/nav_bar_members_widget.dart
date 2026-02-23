import 'package:flutter/material.dart';
import 'package:sample_app/router/app_page.dart';

/// Bottom nav bar driven by [AppPage]. Shows only pages with navBarMemberIndex != 99.
class NavBarMembersWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBarMembersWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static List<AppPage> get _navPages {
    final list = AppPage.values
        .where((p) => p.navBarMemberIndex != 99)
        .toList();
    list.sort((a, b) => a.navBarMemberIndex.compareTo(b.navBarMemberIndex));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final navPages = _navPages;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          for (int i = 0; i < navPages.length; i++) ...[
            Expanded(
              child: _NavItem(
                page: navPages[i],
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
                colorScheme: colorScheme,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppPage page;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavItem({
    required this.page,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(
          page.icon,
          size: 24,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
