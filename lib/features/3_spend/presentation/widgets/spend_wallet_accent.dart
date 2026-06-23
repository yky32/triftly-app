import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum SpendSign { positive, negative, neutral }

const spendItemFontScale = 1.0;

TextStyle? spendItemText(TextStyle? base) {
  if (base == null) return null;
  final size = base.fontSize;
  if (size == null) return base;
  return base.copyWith(fontSize: size * spendItemFontScale);
}

TextStyle? spendSectionText(TextStyle? base) => base;

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
            style: spendItemText(
              Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared list surface for Trips + Recent on Spend page.
class SpendListCard extends StatelessWidget {
  const SpendListCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isDark ? AppColors.borderDark.withValues(alpha: 0.7) : AppColors.borderLight,
        ),
        boxShadow: AppShadows.card(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Muted inline status chip (e.g. Active).
class SpendInlineChip extends StatelessWidget {
  const SpendInlineChip({
    required this.label,
    this.color,
    super.key,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: spendItemText(
          Theme.of(context).textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

/// Section title with optional count chip.
class SpendSectionTitle extends StatelessWidget {
  const SpendSectionTitle({
    required this.title,
    this.count,
    super.key,
  });

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: spendSectionText(
              Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              '$count',
              style: spendSectionText(
                Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
