import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

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
                      SheetOptionRow(
                        icon: _options[i].icon,
                        title: _options[i].title,
                        subtitle: _options[i].subtitle,
                        selected: controller.themeMode == _options[i].mode,
                        onTap: () async {
                          await controller.setThemeMode(_options[i].mode);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                      if (i < _options.length - 1) const SheetSoftListDivider(),
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
