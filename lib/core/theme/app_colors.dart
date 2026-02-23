import 'package:flutter/material.dart';

/// Consistent color palette for the ParkParkPark app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Professional Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Lighter Blue
  static const Color primaryDark = Color(0xFF1E40AF); // Darker Blue

  // Secondary Colors
  static const Color secondary = Color(0xFF059669); // Parking Green
  static const Color secondaryLight = Color(0xFF10B981); // Success Green
  static const Color secondaryDark = Color(0xFF047857); // Dark Green

  // Accent Colors
  static const Color accent = Color(0xFF7C3AED); // Premium Purple
  static const Color accentLight = Color(0xFF8B5CF6); // Light Purple
  static const Color accentDark = Color(0xFF6D28D9); // Dark Purple

  // Status Colors
  static const Color success = Color(0xFF10B981); // Available/Success
  static const Color warning = Color(0xFFF59E0B); // Caution/Moderate
  static const Color error = Color(0xFFDC2626); // Full/Error
  static const Color info = Color(0xFF0EA5E9); // Information

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC); // Light Gray Background
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color onSurface = Color(0xFF1F2937); // Dark Text
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Muted Text
  static const Color divider = Color(0xFFE5E7EB); // Light Divider

  // Gradients
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> secondaryGradient = [secondary, secondaryLight];
  static const List<Color> accentGradient = [accent, accentLight];
  static const List<Color> weatherGradient = [
    Color(0xFFFFB347),
    Color(0xFFFF8C69)
  ]; // Orange to Coral
  static const List<Color> transportationGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D)
  ]; // Red to Yellow
  static const List<Color> parkingGradient = [
    secondary,
    Color(0xFF34D399)
  ]; // Green gradient

  // Traffic Status Colors
  static const Color trafficHeavy = Color(0xFFDC2626); // Red
  static const Color trafficModerate = Color(0xFFF59E0B); // Orange
  static const Color trafficLight = Color(0xFF10B981); // Green

  // Car Park Category Colors
  static const Color mallParking = primary; // Blue for malls
  static const Color airportParking = accent; // Purple for airports
  static const Color shoppingParking = secondary; // Green for shopping
  static const Color residentialParking =
      Color(0xFFF59E0B); // Orange for residential

  // Semantic Colors with Alpha
  static Color primaryWithAlpha(double alpha) =>
      primary.withValues(alpha: alpha);
  static Color secondaryWithAlpha(double alpha) =>
      secondary.withValues(alpha: alpha);
  static Color accentWithAlpha(double alpha) => accent.withValues(alpha: alpha);
  static Color whiteWithAlpha(double alpha) =>
      Colors.white.withValues(alpha: alpha);
  static Color blackWithAlpha(double alpha) =>
      Colors.black.withValues(alpha: alpha);
}
