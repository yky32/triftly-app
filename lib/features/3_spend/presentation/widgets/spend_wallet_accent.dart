import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum SpendSign { positive, negative, neutral }

/// Colored pill for + / − / settled amounts.
class SpendSignedBadge extends StatelessWidget {
  const SpendSignedBadge({
    required this.label,
    required this.sign,
    this.compact = false,
    super.key,
  });

  final String label;
  final SpendSign sign;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (sign) {
      SpendSign.positive => (
          AppColors.success.withValues(alpha: 0.14),
          AppColors.success,
          Icons.south_west_rounded,
        ),
      SpendSign.negative => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
          Icons.north_east_rounded,
        ),
      SpendSign.neutral => (
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primaryDark,
          Icons.check_rounded,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
    );
  }
}

/// Section title with optional count chip.
class SpendSectionTitle extends StatelessWidget {
  const SpendSectionTitle({
    required this.icon,
    required this.title,
    this.count,
    super.key,
  });

  final IconData icon;
  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SpendIconAvatar extends StatelessWidget {
  const SpendIconAvatar({
    required this.child,
    this.color,
    this.size = 40,
    super.key,
  });

  final Widget child;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = color ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tint.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

String tripDestinationEmoji(String destination) {
  final lower = destination.toLowerCase();
  if (lower.contains('tokyo') || lower.contains('osaka') || lower.contains('japan')) return '🇯🇵';
  if (lower.contains('taipei') || lower.contains('taiwan')) return '🇹🇼';
  if (lower.contains('bangkok') || lower.contains('thailand')) return '🇹🇭';
  if (lower.contains('seoul') || lower.contains('korea')) return '🇰🇷';
  if (lower.contains('paris') || lower.contains('france')) return '🇫🇷';
  return '✈️';
}
