import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:triftly/core/constants/app_config.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/theme/theme_bloc.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';
import 'package:triftly/features/_standalone/login/bloc/login_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppConfig.defaultPage.path);
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                  Text(
                    context.l10n.page_settings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<ThemeBloc, ThemeMode>(
                builder: (context, themeMode) {
                  final themeSubtitle = themeMode == ThemeMode.dark
                      ? context.l10n.settings_theme_dark
                      : context.l10n.settings_theme_light;
                  return _SettingsIsland(
                    icon: Icons.palette_outlined,
                    title: context.l10n.settings_theme,
                    subtitle: themeSubtitle,
                    colorScheme: colorScheme,
                    textTheme: theme.textTheme,
                    onTap: () => _showThemePicker(context),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsIsland(
                icon: Icons.language,
                title: context.l10n.settings_language,
                subtitle: context.l10n.settings_language_value,
                colorScheme: colorScheme,
                textTheme: theme.textTheme,
              ),
              const SizedBox(height: 12),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                      : '—';
                  return _SettingsIsland(
                    icon: Icons.info_outline,
                    title: context.l10n.settings_app_version,
                    subtitle: version,
                    colorScheme: colorScheme,
                    textTheme: theme.textTheme,
                  );
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  if (state is LoginSuccess) {
                    return TextButton(
                      onPressed: () => _handleLogout(context),
                      child: const Text('Sign Out'),
                    );
                  }
                  return TextButton(
                    onPressed: () => context.go(AppConfig.loginPage.path),
                    child: const Text('Sign In'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragHandle(),
              ListTile(
                leading: Icon(Icons.light_mode, color: colorScheme.primary),
                title: Text(context.l10n.settings_theme_light),
                onTap: () {
                  themeBloc.add(ThemeModeRequested(ThemeMode.light));
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: colorScheme.primary),
                title: Text(context.l10n.settings_theme_dark),
                onTap: () {
                  themeBloc.add(ThemeModeRequested(ThemeMode.dark));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<LoginBloc>().add(LogoutRequest());
              context.go(AppConfig.loginPage.path);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// One island for one function. [icon] [title / subtitle]. Optional [onTap] for tappable row.
class _SettingsIsland extends StatelessWidget {
  const _SettingsIsland({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: row,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: row,
    );
  }
}
