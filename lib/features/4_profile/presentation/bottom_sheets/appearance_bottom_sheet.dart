import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/triftly_motion.dart';

class AppearanceBottomSheet extends StatelessWidget {
  const AppearanceBottomSheet({required this.controller, super.key});

  final ThemeController controller;

  static Future<void> show(BuildContext context) {
    final themeController = ThemeScope.of(context);
    return TriftlyBottomSheet.show(
      context,
      child: AppearanceBottomSheet(controller: themeController),
    );
  }

  static const _options = [
    _AppearanceOption(
      mode: ThemeMode.system,
      title: 'System',
      subtitle: 'Match device settings',
      icon: Icons.brightness_auto_rounded,
    ),
    _AppearanceOption(
      mode: ThemeMode.light,
      title: 'Light',
      subtitle: 'Bright surfaces',
      icon: Icons.light_mode_rounded,
    ),
    _AppearanceOption(
      mode: ThemeMode.dark,
      title: 'Dark',
      subtitle: 'Easy on the eyes at night',
      icon: Icons.dark_mode_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SheetScaffold(
          showCloseButton: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetSectionHeader(title: 'Appearance', caption: 'Choose a theme'),
              const SizedBox(height: AppSpacing.md),
              SheetSoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < _options.length; i++) ...[
                      _AppearanceRow(
                        option: _options[i],
                        selected: controller.themeMode == _options[i].mode,
                        onTap: () async {
                          await controller.setThemeMode(_options[i].mode);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                      if (i < _options.length - 1)
                        Divider(
                          height: 1,
                          indent: AppSpacing.lg,
                          endIndent: AppSpacing.lg,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AppearanceOption {
  const _AppearanceOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _AppearanceOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
                    : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(
                option.icon,
                size: 20,
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(option.subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined, size: 22, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
