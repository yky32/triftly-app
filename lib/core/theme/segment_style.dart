import 'package:flutter/material.dart';
import '../models/trip_models.dart';

/// Global three-tone palette — Active (orange), Upcoming (blue), Done (grey).
class SegmentStyle {
  const SegmentStyle({
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

  static const active = SegmentStyle(
    pillLight: Color(0xFFFFF7ED),
    pillDark: Color(0xFF431407),
    accent: Color(0xFFC2410C),
    accentDark: Color(0xFFFDBA74),
    badgeLight: Color(0xFFFFEDD5),
    badgeDark: Color(0xFF7C2D12),
  );

  static const upcoming = SegmentStyle(
    pillLight: Color(0xFFF0F9FF),
    pillDark: Color(0xFF082F49),
    accent: Color(0xFF0369A1),
    accentDark: Color(0xFF7DD3FC),
    badgeLight: Color(0xFFE0F2FE),
    badgeDark: Color(0xFF0C4A6E),
  );

  static const done = SegmentStyle(
    pillLight: Color(0xFFF5F5F4),
    pillDark: Color(0xFF292524),
    accent: Color(0xFF78716C),
    accentDark: Color(0xFFA8A29E),
    badgeLight: Color(0xFFE7E5E4),
    badgeDark: Color(0xFF44403C),
  );

  static const tones = [active, upcoming, done];

  static SegmentStyle toneAt(int index) => tones[index.clamp(0, tones.length - 1)];

  static SegmentStyle ofPhase(TripPhase phase) => switch (phase) {
        TripPhase.inProgress => active,
        TripPhase.upcoming => upcoming,
        TripPhase.completed => done,
      };

  /// Back-compat alias for trip cards and badges.
  static SegmentStyle of(TripPhase phase) => ofPhase(phase);
}

extension TripPhaseSegmentIndex on TripPhase {
  /// Slot in the segment bar: Upcoming · Active · Done.
  int get segmentIndex => switch (this) {
        TripPhase.upcoming => 0,
        TripPhase.inProgress => 1,
        TripPhase.completed => 2,
      };

  /// Color tone (independent of slot position).
  int get toneIndex => switch (this) {
        TripPhase.inProgress => 0,
        TripPhase.upcoming => 1,
        TripPhase.completed => 2,
      };
}

/// Display order: Upcoming · Active · Done.
const tripPhaseSegmentOrder = [
  TripPhase.upcoming,
  TripPhase.inProgress,
  TripPhase.completed,
];
