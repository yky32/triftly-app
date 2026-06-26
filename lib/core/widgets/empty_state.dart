import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'glass_surface.dart';
import 'spend_glass_shell.dart';
import 'triftly_motion.dart';

/// Frosted icon chip — matches wallet / spend metric chips (`liquid-glass-ui.mdc`).
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
    final wellSize = compact ? 52.0 : 60.0;
    final iconSize = compact ? 24.0 : 28.0;
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

/// Frosted pill CTA — no solid teal blocks on glass surfaces.
class EmptyStateActionButton extends StatelessWidget {
  const EmptyStateActionButton({
    required this.label,
    required this.onPressed,
    this.leading,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? leading;

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
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 18, color: accent),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liquid-glass empty hero — `SpendGlassShell` card with frosted CTA.
///
/// Reference: Trips tab when the list is empty (`No trips yet`).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.action,
    this.actionLabel,
    this.actionIcon,
    this.expand = false,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Uppercase glass label (e.g. `TRIPS`, `WALLET`).
  final String? eyebrow;
  final VoidCallback? action;
  final String? actionLabel;
  final IconData? actionIcon;

  /// Fill available height and center content (tab-root empties).
  final bool expand;

  /// Tighter layout for phase-filter slots inside a list.
  final bool compact;

  static const double _cardMaxWidth = 340;

  static TextStyle _eyebrowStyle(BuildContext context, bool isDark) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.45,
          height: 1.2,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final shellPadding = compact
        ? const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg)
        : const EdgeInsets.fromLTRB(AppSpacing.xl, 28, AppSpacing.xl, AppSpacing.xl);

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
      child: SpendGlassShell(
        padding: shellPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!.toUpperCase(),
                style: _eyebrowStyle(context, isDark),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            ],
            Center(child: EmptyStateIconWell(icon: icon, compact: compact)),
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: compact ? 18 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.15,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                      fontSize: compact ? 13 : 14,
                      height: 1.45,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              EmptyStateActionButton(
                label: actionLabel!,
                onPressed: action!,
                leading: actionIcon ?? Icons.add_rounded,
              ),
            ],
          ],
        ),
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
                  AppSpacing.sm,
                  AppSpacing.lg,
                  navInset * 0.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [card],
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
        vertical: compact ? AppSpacing.md : AppSpacing.lg,
      ),
      child: Center(child: card),
    );
  }
}
