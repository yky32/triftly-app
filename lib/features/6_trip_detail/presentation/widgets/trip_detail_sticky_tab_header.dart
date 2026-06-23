import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Pinned bar with frosted glass when content scrolls underneath.
class TripDetailStickyBarDelegate extends SliverPersistentHeaderDelegate {
  TripDetailStickyBarDelegate({
    required this.child,
    required this.extent,
    this.isScrolled = false,
  });

  final Widget child;
  final double extent;
  final bool isScrolled;

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
          child: SizedBox(height: extent, child: child),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant TripDetailStickyBarDelegate oldDelegate) {
    return oldDelegate.isScrolled != isScrolled ||
        oldDelegate.extent != extent ||
        oldDelegate.child != child;
  }
}

/// Pinned Plan · Spend · Map bar.
class TripDetailStickyTabDelegate extends TripDetailStickyBarDelegate {
  TripDetailStickyTabDelegate({
    required super.child,
    required super.isScrolled,
  }) : super(extent: tabExtent);

  static const tabExtent = 68.0;
}
