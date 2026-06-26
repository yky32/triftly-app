import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
/// Primary CTA for [EmptyState] and inline empty cards — full-width teal pill.
class EmptyStateActionButton extends StatelessWidget {
  const EmptyStateActionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Centered icon + title + subtitle + optional pill CTA.
///
/// Reference: Trips tab when the list is empty (`No trips yet`).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.expand = false,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  /// Fill available height and center content (tab-root empties).
  final bool expand;

  /// Tighter layout for phase-filter slots inside a list.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconSize = compact ? 48.0 : 56.0;
    final iconColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null && actionLabel != null) ...[
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
            EmptyStateActionButton(label: actionLabel!, onPressed: action!),
          ],
        ],
      ),
    );

    if (expand) {
      return SizedBox.expand(child: Center(child: content));
    }

    return content;
  }
}
