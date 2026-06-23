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
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    final field = TextField(
      controller: controller,
      onChanged: onChanged == null ? null : (_) => onChanged!(),
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

/// Full-width primary action for utility sheets (lookup, apply, etc.).
class SheetPrimaryButton extends StatelessWidget {
  const SheetPrimaryButton({
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Teal result banner used in converter / lookup tool sheets.
class SheetResultBanner extends StatelessWidget {
  const SheetResultBanner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
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
