import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'glass_surface.dart';
import 'spend_glass_shell.dart';
import 'triftly_motion.dart';

/// Frosted icon chip — matches wallet / spend metric chips.
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
    final wellSize = compact ? 48.0 : 56.0;
    final iconSize = compact ? 22.0 : 26.0;
    final radius = compact ? AppRadii.md : AppRadii.lg;

    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: wellSize,
        height: wellSize,
        child: Icon(
          icon,
          size: iconSize,
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
        ),
      ),
    );
  }
}

/// Frosted pill CTA — text only for minimal empty states.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryLight : AppColors.primaryDark;

    return Pressable(
      onTap: onPressed,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        blur: 22,
        tint: SpendGlassShell.tint(isDark),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppSpacing.xl),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: accent,
          ),
        ),
      ),
    );
  }
}

/// Minimal empty hero — icon, one line, optional glass CTA.
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

  static const double _contentMaxWidth = 280;

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
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 17 : 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
              height: 1.2,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
      final navInset = AppSpacing.navIslandOccupiedHeight(context);

      return SizedBox.expand(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, navInset),
          child: Center(child: content),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: compact ? AppSpacing.md : AppSpacing.lg,
      ),
      child: Center(child: content),
    );
  }
}
