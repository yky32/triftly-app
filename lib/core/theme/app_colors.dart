import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF007AFF);
  static const primaryLight = Color(0xFF4DA3FF);
  static const primaryDark = Color(0xFF0055CC);
  static const primaryMuted = Color(0xFFE8F2FF);

  // Surface — light
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF5F6F8);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFAFBFC);

  // Surface — dark
  static const surfaceDark = Color(0xFF121214);
  static const surfaceDimDark = Color(0xFF1C1C1E);
  static const surfaceCardDark = Color(0xFF2C2C2E);
  static const surfaceElevatedDark = Color(0xFF3A3A3C);

  // Text — light
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Text — dark
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const textTertiaryDark = Color(0xFF6B7280);

  // Border
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const borderDark = Color(0xFF3A3A3C);

  // Status
  static const success = Color(0xFF10B981);
  static const successMuted = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const exploreGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category
  static const food = Color(0xFFFF6B6B);
  static const attraction = Color(0xFF4ECDC4);
  static const hotel = Color(0xFF45B7D1);
  static const transport = Color(0xFF96CEB4);
  static const shopping = Color(0xFFFFEAA7);
  static const other = Color(0xFFDDA0DD);

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
