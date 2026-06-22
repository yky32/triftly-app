import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets page = EdgeInsets.fromLTRB(lg, 0, lg, 110);
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(lg, sm, lg, xl);

  /// Vertical clearance so content / FAB sit above the floating nav island.
  static const double navIslandClearance = 80;

  /// List bottom inset when the floating nav island is visible (nested routes).
  static double listBottomInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + navIslandClearance;
  }
}

abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get sheet => const BorderRadius.vertical(top: Radius.circular(xl));
}

abstract final class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
        blurRadius: isDark ? 8 : 20,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> soft(BuildContext context) => card(context);

  static List<BoxShadow> navBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
        blurRadius: 40,
        spreadRadius: -6,
        offset: const Offset(0, 16),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
        blurRadius: 1,
        offset: const Offset(0, 0.5),
      ),
    ];
  }
}
