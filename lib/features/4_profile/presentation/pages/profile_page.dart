import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 28, color: Colors.white),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wayne', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Sign in to sync trips', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences
          Text('PREFERENCES', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, letterSpacing: 1)),
          const SizedBox(height: 8),
          _SettingsTile(title: 'Default Currency', value: 'HKD', onTap: () {}),
          _SettingsTile(title: 'Dark Mode', value: 'Off', onTap: () {}),
          _SettingsTile(title: 'Language', value: 'English', onTap: () {}),
          const SizedBox(height: 24),

          // Data
          Text('DATA', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, letterSpacing: 1)),
          const SizedBox(height: 8),
          _SettingsTile(title: 'Export All Trips', onTap: () {}),
          _SettingsTile(title: 'Clear Offline Data', onTap: () {}),
          const SizedBox(height: 24),

          // About
          Text('ABOUT', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, letterSpacing: 1)),
          const SizedBox(height: 8),
          _SettingsTile(title: 'Version', value: '1.0.0', onTap: () {}),
          _SettingsTile(title: 'Made by WY Limited', onTap: () {}),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsTile({required this.title, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            ),
            if (value != null)
              Text(value!, style: const TextStyle(fontSize: 14, color: AppColors.textTertiary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
