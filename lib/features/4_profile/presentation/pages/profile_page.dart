import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/triftly_motion.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Me')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryMuted,
                  child: const Icon(Icons.person_rounded, size: 28, color: AppColors.primaryDark),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wayne', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                      Text('Sign in to sync trips', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Sign in')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Preferences'),
          _SettingsGroup(children: [
            _SettingsTile(title: 'Currency', value: 'HKD', onTap: () {}),
            _SettingsTile(title: 'Appearance', value: 'System', onTap: () {}),
            _SettingsTile(title: 'Language', value: 'English', onTap: () {}),
          ]),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Data'),
          _SettingsGroup(children: [
            _SettingsTile(title: 'Export trips', onTap: () {}),
            _SettingsTile(title: 'Clear offline data', onTap: () {}),
          ]),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'About'),
          _SettingsGroup(children: [
            _SettingsTile(title: 'Version', value: '1.1.0', onTap: () {}),
            _SettingsTile(title: 'WY Limited', onTap: () {}),
          ]),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, indent: AppSpacing.lg, color: AppColors.borderLight),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, this.value, required this.onTap});

  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
            if (value != null) Text(value!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
