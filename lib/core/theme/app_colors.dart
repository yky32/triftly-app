import 'package:flutter/material.dart';

/// Triftly design palette (from design_summary).
/// Teal/green primary, warm accents, neutrals.
class AppColors {
  AppColors._();

  // — Teal / Green (primary family)
  static const Color driftTeal = Color(0xFF14B8A6);
  static const Color tealMist = Color(0xFF99F6E4);
  static const Color deepTeal = Color(0xFF0F766E);
  static const Color calmGreen = Color(0xFF10B981);

  // — Warm
  static const Color sunsetCoral = Color(0xFFFB7185);
  static const Color softAmber = Color(0xFFFBBF24);
  static const Color mutedRed = Color(0xFFE11D48);

  // — Neutrals
  static const Color cloudWhite = Color(0xFFFFFFFF);
  static const Color fogGray = Color(0xFFE2E8F0);
  static const Color mistGray = Color(0xFF94A3B8);
  static const Color slate = Color(0xFF475569);

  // — Semantic (mapped from palette)
  static const Color primary = driftTeal;
  static const Color primaryLight = tealMist;
  static const Color primaryDark = deepTeal;
  static const Color secondary = calmGreen;
  static const Color surface = cloudWhite;
  static const Color onSurface = slate;
  static const Color onSurfaceVariant = mistGray;
  static const Color error = mutedRed;
  static const Color background = fogGray;
}
