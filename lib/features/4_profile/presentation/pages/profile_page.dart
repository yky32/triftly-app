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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profile'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 24, bottom: 48),
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(Icons.flight, size: 80, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileCard().fadeSlideIn(),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'PREFERENCES'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(icon: Icons.payments_outlined, title: 'Default Currency', value: 'HKD', onTap: () {}),
                      _SettingsTile(icon: Icons.dark_mode_outlined, title: 'Appearance', value: 'System', onTap: () {}),
                      _SettingsTile(icon: Icons.language_outlined, title: 'Language', value: 'English', onTap: () {}),
                    ],
                  ).staggerIn(1),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'DATA'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(icon: Icons.upload_outlined, title: 'Export All Trips', onTap: () {}),
                      _SettingsTile(icon: Icons.delete_outline_rounded, title: 'Clear Offline Data', onTap: () {}),
                    ],
                  ).staggerIn(2),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'ABOUT'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(icon: Icons.info_outline_rounded, title: 'Version', value: '1.1.0', onTap: () {}),
                      _SettingsTile(icon: Icons.favorite_outline_rounded, title: 'Made by WY Limited', onTap: () {}),
                    ],
                  ).staggerIn(3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wayne', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17)),
                const SizedBox(height: 2),
                Text('Sign in to sync trips across devices', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Sign in'),
          ),
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
              Divider(
                height: 1,
                indent: 52,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color)),
            ),
            if (value != null) ...[
              Text(value!, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
