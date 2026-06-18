import 'package:flutter/material.dart';
import 'package:triftly/core/theme/app_colors.dart';

/// Shared radii and spacing for the Triftly UI refresh.
abstract final class TriftlyLayout {
  static const double pagePadding = 20;
  static const double cardRadius = 22;
  static const double chipRadius = 14;
  static const double navRadius = 28;

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.cloudWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static const gradientPrimary = LinearGradient(
    colors: [AppColors.deepTeal, AppColors.driftTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientWarm = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
