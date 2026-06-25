import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'glass_surface.dart';

/// Frosted card shell for trip and global Spend metrics.
class SpendGlassShell extends StatelessWidget {
  const SpendGlassShell({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  static Color tint(bool isDark) {
    if (isDark) {
      return const Color(0xFF2A2A2C).withValues(alpha: 0.62);
    }
    return Color.lerp(
      const Color(0xFFFAFAF8),
      AppColors.primaryMuted,
      0.08,
    )!.withValues(alpha: 0.94);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      borderRadius: AppRadii.card,
      blur: 22,
      padding: padding,
      tint: tint(isDark),
      child: child,
    );
  }
}
