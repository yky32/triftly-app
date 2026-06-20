import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF007AFF);
  static const primaryLight = Color(0xFF4DA3FF);
  static const primaryDark = Color(0xFF0055CC);

  // Surface
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF8F9FA);
  static const surfaceCard = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Border
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);

  // Status
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

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
