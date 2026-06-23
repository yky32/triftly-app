import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shared typography + chrome for the Spend wallet page.
abstract final class SpendWalletChrome {
  static TextStyle moneyHero(BuildContext context, {Color? color, double size = 44}) {
    return TextStyle(
      fontSize: size,
      height: 1.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.4,
      color: color ?? (Theme.of(context).brightness == Brightness.dark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimary),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle moneyBody(BuildContext context, {Color? color, double size = 16}) {
    return TextStyle(
      fontSize: size,
      height: 1.1,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle sectionLabel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
    );
  }

  static BoxDecoration surfaceCard(BuildContext context) {
    return BoxDecoration(
      color: AppColors.cardBackground(context),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      boxShadow: AppShadows.card(context),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.borderDark.withValues(alpha: 0.6)
            : AppColors.borderLight,
      ),
    );
  }
}

class SpendWalletSectionHeader extends StatelessWidget {
  const SpendWalletSectionHeader({
    required this.title,
    this.trailing,
    super.key,
  });

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: SpendWalletChrome.sectionLabel(context),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class SpendWalletStatusPill extends StatelessWidget {
  const SpendWalletStatusPill({
    required this.label,
    required this.tone,
    super.key,
  });

  final String label;
  final SpendWalletStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      SpendWalletStatusTone.positive => (AppColors.successMuted, AppColors.success),
      SpendWalletStatusTone.negative => (const Color(0xFFFEE2E2), AppColors.error),
      SpendWalletStatusTone.neutral => (
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primaryDark,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

enum SpendWalletStatusTone { positive, negative, neutral }
