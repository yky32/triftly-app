import 'package:flutter/material.dart';
import '../constants/currency_options.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'triftly_motion.dart';

/// Shared form chrome for trip sheets (create trip, add spot, etc.).
class SheetSectionHeader extends StatelessWidget {
  const SheetSectionHeader({required this.title, this.caption, super.key});

  final String title;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );
    final captionStyle = TextStyle(
      fontSize: 13,
      height: 1.35,
      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
    );

    if (caption == null) {
      return Text(title, style: titleStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 4),
        Text(caption!, style: captionStyle),
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

/// Teal gradient shell shared by form hero fields and converter inputs.
class SheetGradientHero extends StatelessWidget {
  const SheetGradientHero({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
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

    return SheetGradientHero(
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

class SheetNumericHeroField extends StatelessWidget {
  const SheetNumericHeroField({
    this.label,
    this.leadingAffix,
    this.trailingAffix,
    this.controller,
    this.value,
    this.onChanged,
    this.readOnly = false,
    this.keyboardType,
    super.key,
  }) : assert(controller != null || value != null, 'Provide controller or value');

  final String? label;
  final String? leadingAffix;
  final String? trailingAffix;
  final TextEditingController? controller;
  final String? value;
  final VoidCallback? onChanged;
  final bool readOnly;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final textStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.2,
      height: 1.05,
      color: readOnly ? muted : primary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final affixStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      color: readOnly ? tertiary : AppColors.primaryDark,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (leadingAffix != null) ...[
              Text(leadingAffix!, style: affixStyle),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: readOnly
                  ? Text(value ?? '—', style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : TextField(
                      controller: controller,
                      onChanged: onChanged == null ? null : (_) => onChanged!(),
                      keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      style: textStyle,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: textStyle.copyWith(color: tertiary.withValues(alpha: 0.45)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
            if (trailingAffix != null) ...[
              const SizedBox(width: 8),
              Text(trailingAffix!, style: affixStyle.copyWith(fontSize: 18)),
            ],
          ],
        ),
      ],
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
    this.keyboardType,
    this.maxLines = 1,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    final field = TextField(
      controller: controller,
      onChanged: onChanged == null ? null : (_) => onChanged!(),
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
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

/// Indented divider between rows in a zero-padding [SheetSoftCard].
class SheetSoftListDivider extends StatelessWidget {
  const SheetSoftListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: 1,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

/// Selectable list row — appearance picker, currency list, trip menu, etc.
class SheetOptionRow extends StatelessWidget {
  const SheetOptionRow({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.leading,
    this.selected = false,
    this.showCheck = true,
    this.destructive = false,
    super.key,
  }) : assert(icon != null || leading != null);

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final bool selected;
  final bool showCheck;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = destructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        child: Row(
          children: [
            leading ?? _IconTile(icon: icon!, selected: selected, destructive: destructive, isDark: isDark),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (showCheck)
              if (selected)
                const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.primary)
              else
                Icon(
                  Icons.circle_outlined,
                  size: 22,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.selected,
    required this.destructive,
    required this.isDark,
  });

  final IconData icon;
  final bool selected;
  final bool destructive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
            : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(
        icon,
        size: 20,
        color: destructive
            ? AppColors.error
            : (selected ? AppColors.primaryDark : AppColors.textSecondary),
      ),
    );
  }
}

/// Compact in-row action chip for utility sheets (e.g. Paid, Everyone).
class SheetCompactAction extends StatelessWidget {
  const SheetCompactAction({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.primaryDark),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer action row inside a zero-padding [SheetSoftCard] (sign-in, etc.).
class SheetCardActionRow extends StatelessWidget {
  const SheetCardActionRow({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canTap = enabled && !loading;

    return Pressable(
      onTap: canTap ? onPressed : null,
      child: Opacity(
        opacity: canTap ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  loading ? 'Please wait…' : label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// OAuth-style sign-in row (Google, Apple, …). Use [enabled: false] for placeholders.
class SheetSocialSignInButton extends StatelessWidget {
  const SheetSocialSignInButton({
    required this.label,
    required this.leading,
    this.onTap,
    this.enabled = true,
    this.badge,
    super.key,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onTap;
  final bool enabled;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interactive = enabled && onTap != null;

    return Opacity(
      opacity: interactive ? 1 : 0.55,
      child: Pressable(
        onTap: interactive ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDimDark : AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google "G" glyph for social sign-in placeholders.
class SheetGoogleGlyph extends StatelessWidget {
  const SheetGoogleGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
          height: 1,
        ),
      ),
    );
  }
}

/// Full-width primary action for utility sheets (lookup, apply, etc.).
class SheetPrimaryButton extends StatelessWidget {
  const SheetPrimaryButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled
                  ? [
                      AppColors.primary,
                      isDark ? const Color(0xFF0F766E) : AppColors.primaryDark,
                    ]
                  : [
                      isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                      isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                    ],
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: enabled ? Colors.white : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Teal result banner used in converter / lookup tool sheets.
class SheetResultBanner extends StatelessWidget {
  const SheetResultBanner({
    required this.text,
    this.caption,
    super.key,
  });

  final String text;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted.withValues(alpha: isDark ? 0.22 : 0.35),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          if (caption != null) ...[
            Text(
              caption!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Horizontal currency chips — flag + symbol only (see `currency_options.dart`).
class SheetCurrencyChipPicker extends StatelessWidget {
  const SheetCurrencyChipPicker({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CurrencyOptions.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final option = CurrencyOptions.all[index];
          return _SheetCurrencyChip(
            option: option,
            isSelected: option.code == selected,
            onTap: () => onSelected(option.code),
          );
        },
      ),
    );
  }
}

class _SheetCurrencyChip extends StatelessWidget {
  const _SheetCurrencyChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CurrencyOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
              : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.flag, style: const TextStyle(fontSize: 20, height: 1)),
            const SizedBox(height: 2),
            Text(
              option.symbol,
              style: TextStyle(
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-option segment chips (e.g. Address → Mapcode / reverse).
class SheetChoiceChipRow extends StatelessWidget {
  const SheetChoiceChipRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final selected = index == selectedIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : AppSpacing.sm / 2,
              right: index == options.length - 1 ? 0 : AppSpacing.sm / 2,
            ),
            child: Pressable(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
                      : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
