import 'package:flutter/material.dart';

class AppColors {
  // Brand — warm ink + teal (not generic iOS blue)
  static const primary = Color(0xFF0D9488);
  static const primaryLight = Color(0xFF14B8A6);
  static const primaryDark = Color(0xFF0F766E);
  static const primaryMuted = Color(0xFFCCFBF1);

  // Surface — light (warm neutrals)
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF7F5F2);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFAFAF8);

  // Surface — dark
  static const surfaceDark = Color(0xFF0C0C0D);
  static const surfaceDimDark = Color(0xFF161618);
  static const surfaceCardDark = Color(0xFF1E1E20);
  static const surfaceElevatedDark = Color(0xFF2A2A2C);

  // Text — light
  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF78716C);
  static const textTertiary = Color(0xFFA8A29E);

  // Text — dark
  static const textPrimaryDark = Color(0xFFFAFAF9);
  static const textSecondaryDark = Color(0xFFA8A29E);
  static const textTertiaryDark = Color(0xFF78716C);

  // Border
  static const border = Color(0xFFE7E5E4);
  static const borderLight = Color(0xFFF5F5F4);
  static const borderDark = Color(0xFF2A2A2C);

  // Status
  static const success = Color(0xFF059669);
  static const successMuted = Color(0xFFD1FAE5);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);

  // Accent surfaces
  static const accentSurface = Color(0xFFF0FDFA);

  // Category — muted, harmonious
  static const food = Color(0xFFE11D48);
  static const attraction = Color(0xFF0D9488);
  static const hotel = Color(0xFF2563EB);
  static const transport = Color(0xFF65A30D);
  static const shopping = Color(0xFFD97706);
  static const other = Color(0xFF7C3AED);

  static Color categoryColor(SpotCategory category) {
    switch (category) {
      case SpotCategory.food:
        return food;
      case SpotCategory.attraction:
        return attraction;
      case SpotCategory.hotel:
        return hotel;
      case SpotCategory.transport:
        return transport;
      case SpotCategory.shopping:
        return shopping;
      case SpotCategory.other:
        return other;
    }
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceCardDark
        : surfaceCard;
  }

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceDim;
  }

  static Color tintForDestination(String destination) {
    final lower = destination.toLowerCase();
    if (lower.contains('tokyo') || lower.contains('osaka')) return const Color(0xFFFCE7F3);
    if (lower.contains('seoul')) return const Color(0xFFE0E7FF);
    if (lower.contains('bali') || lower.contains('bangkok')) return const Color(0xFFD1FAE5);
    if (lower.contains('london') || lower.contains('paris')) return const Color(0xFFFFEDD5);
    return accentSurface;
  }
}

enum SpotCategory {
  food('food', '🍜', 'Food'),
  attraction('attraction', '🏯', 'Attraction'),
  hotel('hotel', '🏨', 'Hotel'),
  transport('transport', '🚃', 'Transport'),
  shopping('shopping', '🛍️', 'Shopping'),
  other('other', '📌', 'Other');

  final String value;
  final String emoji;
  final String label;
  const SpotCategory(this.value, this.emoji, this.label);
}
