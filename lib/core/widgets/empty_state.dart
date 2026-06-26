import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'triftly_motion.dart';

/// Soft circular icon backdrop for empty states.
class EmptyStateIconWell extends StatelessWidget {
  const EmptyStateIconWell({
    required this.icon,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wellSize = compact ? 72.0 : 96.0;
    final iconSize = compact ? 32.0 : 40.0;

    return Container(
      width: wellSize,
      height: wellSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.24),
                  AppColors.surfaceElevatedDark,
                ]
              : [
                  AppColors.primaryMuted,
                  const Color(0xFFECFDF5),
                ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: compact ? 12 : 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
      ),
    );
  }
}

/// Primary CTA for [EmptyState] and inline empty cards — teal gradient pill.
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
    return Pressable(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: Colors.white,
          ),
        ),
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

  static const double _contentMaxWidth = 300;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyStateIconWell(icon: icon, compact: compact),
          SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.15,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: compact ? AppSpacing.sm : 10),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: compact ? 15 : 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null && actionLabel != null) ...[
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
            EmptyStateActionButton(label: actionLabel!, onPressed: action!),
          ],
        ],
      ),
    );

    if (expand) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final navInset = AppSpacing.navIslandOccupiedHeight(context);

          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  navInset * 0.55,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [content],
                ),
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      child: Center(child: content),
    );
  }
}
