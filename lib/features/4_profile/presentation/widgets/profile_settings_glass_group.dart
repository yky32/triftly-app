import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_surface.dart';

/// Light frosted panel for Me tab settings groups — quieter than [ProfileIdentityIsland].
class ProfileSettingsGlassGroup extends StatelessWidget {
  const ProfileSettingsGlassGroup({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  static Color tint(bool isDark) {
    if (isDark) {
      return const Color(0xFF1E1E20).withValues(alpha: 0.55);
    }
    return const Color(0xFFFEFEFE).withValues(alpha: 0.48);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight.withValues(alpha: 0.85);

    return GlassSurface(
      borderRadius: AppRadii.card,
      blur: 18,
      tint: tint(isDark),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.lg,
                color: dividerColor,
              ),
          ],
        ],
      ),
    );
  }
}

/// Same subtle glass as settings — for guest / sign-in prompt on Me.
class ProfileGuestGlassCard extends StatelessWidget {
  const ProfileGuestGlassCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      borderRadius: AppRadii.card,
      blur: 18,
      tint: ProfileSettingsGlassGroup.tint(isDark),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}
