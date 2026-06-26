import 'package:flutter/material.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_icon_button.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../bottom_sheets/user_detail_bottom_sheet.dart';
import 'profile_avatar.dart';
import 'user_display_name_label.dart';

/// Frosted identity hero for signed-in users on the Me tab.
class ProfileIdentityIsland extends StatelessWidget {
  const ProfileIdentityIsland({
    required this.user,
    super.key,
  });

  final User user;

  static Color _tint(bool isDark) {
    if (isDark) {
      return Color.lerp(
        const Color(0xFF2A2A2C).withValues(alpha: 0.74),
        AppColors.primary.withValues(alpha: 0.18),
        0.42,
      )!;
    }
    return Color.lerp(
      const Color(0xFFFAFAF8),
      AppColors.primaryMuted,
      0.28,
    )!.withValues(alpha: 0.94);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final emailColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF57534E);

    return Pressable(
      onTap: () => UserDetailBottomSheet.show(context, user: user),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          blur: 34,
          tint: _tint(isDark),
          padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
            Positioned(
              right: -32,
              top: -28,
              child: IgnorePointer(
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.18),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AvatarFrame(
                  isDark: isDark,
                  child: ProfileAvatar(
                    user: user,
                    isCloudSignedIn: true,
                    radius: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROFILE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 5),
                      UserDisplayNameLabel(
                        user: user,
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.55,
                          color: nameColor,
                        ),
                      ),
                      if (user.email != null && user.email!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.email!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: emailColor,
                                fontSize: 13,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                GlassIconButton(
                  icon: Icons.info_outline_rounded,
                  tooltip: 'User details',
                  size: 38,
                  onPressed: () => UserDetailBottomSheet.show(context, user: user),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.85),
            width: 2.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: child,
        ),
      ),
    );
  }
}
