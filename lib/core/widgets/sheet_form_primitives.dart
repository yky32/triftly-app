import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared form chrome for trip sheets (create trip, add spot, etc.).
class SheetSectionHeader extends StatelessWidget {
  const SheetSectionHeader({required this.title, this.caption, super.key});

  final String title;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        if (caption != null)
          Text(
            caption!,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}

class SheetSoftCard extends StatelessWidget {
  const SheetSoftCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SheetHeroField extends StatelessWidget {
  const SheetHeroField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF134E4A), const Color(0xFF1E1E20)]
              : [AppColors.primaryMuted, const Color(0xFFF7F5F2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            textInputAction: textInputAction,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.6,
                color: tertiary.withValues(alpha: 0.75),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class SheetIconFieldRow extends StatelessWidget {
  const SheetIconFieldRow({
    required this.icon,
    required this.field,
    super.key,
  });

  final IconData icon;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SheetIconTile(icon: icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: field),
      ],
    );
  }
}

class SheetIconTile extends StatelessWidget {
  const SheetIconTile({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.primaryMuted.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
      ),
    );
  }
}

class SheetInlineField extends StatelessWidget {
  const SheetInlineField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.textInputAction,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    final field = TextField(
      controller: controller,
      onChanged: onChanged == null ? null : (_) => onChanged!(),
      textInputAction: textInputAction,
      maxLines: maxLines,
      textAlignVertical: maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
      style: TextStyle(
        fontSize: maxLines > 1 ? 15 : 17,
        fontWeight: maxLines > 1 ? FontWeight.w500 : FontWeight.w600,
        letterSpacing: maxLines > 1 ? 0 : -0.2,
        height: maxLines > 1 ? 1.35 : 1.0,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: maxLines > 1 ? 14 : 16,
          fontWeight: FontWeight.w500,
          height: maxLines > 1 ? 1.35 : 1.0,
          color: tertiary,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

    if (maxLines > 1) return field;

    return SizedBox(height: 44, child: field);
  }
}

class SheetSoftDivider extends StatelessWidget {
  const SheetSoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );
  }
}
