import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Pinned Plan · Spend · Map bar with frosted glass when scrolled.
class TripDetailStickyTabDelegate extends SliverPersistentHeaderDelegate {
  TripDetailStickyTabDelegate({
    required this.child,
    required this.isScrolled,
  });

  final Widget child;
  final bool isScrolled;

  static const extent = 68.0;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glass = isScrolled || overlapsContent || shrinkOffset > 0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glass ? 18 : 0,
          sigmaY: glass ? 18 : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.pageBackground(context).withValues(
              alpha: glass ? (isDark ? 0.82 : 0.9) : 1,
            ),
            border: glass
                ? Border(
                    bottom: BorderSide(
                      color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.55),
                    ),
                  )
                : null,
            boxShadow: glass
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant TripDetailStickyTabDelegate oldDelegate) {
    return oldDelegate.isScrolled != isScrolled || oldDelegate.child != child;
  }
}
