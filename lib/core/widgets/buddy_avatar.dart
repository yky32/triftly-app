import 'package:flutter/material.dart';

/// Initial-based avatar for plan buddies and joined members.
class BuddyAvatar extends StatelessWidget {
  const BuddyAvatar({
    required this.name,
    this.colorHex,
    this.size = 36,
    this.fontSize,
    super.key,
  });

  final String name;
  final String? colorHex;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = _colorFromHex(colorHex ?? _defaultHex(name));
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final fs = fontSize ?? (size * 0.38).clamp(11.0, 16.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: isDark ? 0.55 : 0.92),
            base.withValues(alpha: isDark ? 0.35 : 0.72),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }

  static String _defaultHex(String name) {
    const colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4',
      'FFEAA7', 'DDA0DD', '74B9FF', 'A29BFE',
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  static Color _colorFromHex(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
