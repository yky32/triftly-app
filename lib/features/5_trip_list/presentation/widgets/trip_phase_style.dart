import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';

/// Shared phase colors for segment control and trip cards.
class TripPhaseStyle {
  const TripPhaseStyle({
    required this.pillLight,
    required this.pillDark,
    required this.accent,
    required this.accentDark,
    required this.badgeLight,
    required this.badgeDark,
  });

  final Color pillLight;
  final Color pillDark;
  final Color accent;
  final Color accentDark;
  final Color badgeLight;
  final Color badgeDark;

  Color pill(bool isDark) => isDark ? pillDark : pillLight;
  Color foreground(bool isDark) => isDark ? accentDark : accent;
  Color badge(bool isDark) => isDark ? badgeDark : badgeLight;

  static TripPhaseStyle of(TripPhase phase) => styles[phase]!;

  static final styles = {
    TripPhase.inProgress: TripPhaseStyle(
      pillLight: Color(0xFFFFF7ED),
      pillDark: Color(0xFF431407),
      accent: Color(0xFFC2410C),
      accentDark: Color(0xFFFDBA74),
      badgeLight: Color(0xFFFFEDD5),
      badgeDark: Color(0xFF7C2D12),
    ),
    TripPhase.upcoming: TripPhaseStyle(
      pillLight: Color(0xFFF0FDF4),
      pillDark: Color(0xFF052E16),
      accent: Color(0xFF15803D),
      accentDark: Color(0xFF86EFAC),
      badgeLight: Color(0xFFDCFCE7),
      badgeDark: Color(0xFF14532D),
    ),
    TripPhase.completed: TripPhaseStyle(
      pillLight: Color(0xFFF5F5F4),
      pillDark: Color(0xFF292524),
      accent: Color(0xFF78716C),
      accentDark: Color(0xFFA8A29E),
      badgeLight: Color(0xFFE7E5E4),
      badgeDark: Color(0xFF44403C),
    ),
  };
}

extension TripPhaseIndex on TripPhase {
  int get index {
    switch (this) {
      case TripPhase.inProgress:
        return 0;
      case TripPhase.upcoming:
        return 1;
      case TripPhase.completed:
        return 2;
    }
  }
}
