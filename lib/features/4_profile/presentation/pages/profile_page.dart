import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/bloc/cloud_sync/cloud_sync_bloc.dart';
import '../../../../core/bloc/session/session_bloc.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/environment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/confirm_bottom_sheet.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../bottom_sheets/appearance_bottom_sheet.dart';
import '../bottom_sheets/default_currency_bottom_sheet.dart';
import '../bottom_sheets/sign_in_bottom_sheet.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_identity_island.dart';
import '../widgets/profile_settings_glass_group.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _versionLabel = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _versionLabel = '${info.version} (${info.buildNumber})');
  }

  Future<void> _exportTrips(BuildContext context) async {
    final json = await AppBootstrap.tripRepository.exportCreatedTripsJson();
    if (!context.mounted) return;
    await Share.share(json, subject: 'Triftly trips export');
  }

  Future<void> _confirmClearOfflineData(BuildContext context, SessionState session) async {
    final confirmed = await ConfirmBottomSheet.show(
      context,
      title: 'Clear offline data?',
      message:
          'Removes cached trips from this device. Cloud trips will be downloaded again if you are signed in.',
      confirmLabel: 'Clear',
      icon: Icons.storage_outlined,
    );
    if (!confirmed || !context.mounted) return;

    final user = session.user;
    final cloudUserId =
        user != null && !user.id.startsWith('local-') ? user.id : null;
    await AppBootstrap.tripRepository.clearOfflineData(cloudUserId: cloudUserId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offline trip cache cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeScope.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const TriftlyAppBarTitle(title: 'Me')),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, session) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.listBottomInset(context),
            ),
            children: [
              _IdentityCard(session: session),
              const SizedBox(height: AppSpacing.xl),
              const _MeSectionHeader(title: 'Preferences'),
              ListenableBuilder(
                listenable: themeController,
                builder: (context, _) {
                  return _SettingsGroup(children: [
                    _SettingsTile(
                      title: 'Currency',
                      value: session.defaultCurrency,
                      onTap: () => DefaultCurrencyBottomSheet.show(
                        context,
                        selected: session.defaultCurrency,
                      ),
                    ),
                    _SettingsTile(
                      title: 'Appearance',
                      value: themeController.label,
                      onTap: () => AppearanceBottomSheet.show(context),
                    ),
                    _SettingsTile(
                      title: 'Language',
                      value: 'English',
                      subtitle: 'Coming soon',
                      enabled: false,
                      showChevron: false,
                      onTap: () {},
                    ),
                  ]);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const _MeSectionHeader(title: 'Data'),
              _SettingsGroup(children: [
                if (session.isCloudSignedIn) const _CloudSyncSettingsTile(),
                _SettingsTile(
                  title: 'Export trips',
                  subtitle: session.isCloudSignedIn ? null : 'Sign in to export',
                  enabled: session.isCloudSignedIn,
                  showChevron: session.isCloudSignedIn,
                  onTap: () => _exportTrips(context),
                ),
                _SettingsTile(
                  title: 'Clear offline data',
                  subtitle: session.isCloudSignedIn ? null : 'Sign in to clear cache',
                  enabled: session.isCloudSignedIn,
                  showChevron: session.isCloudSignedIn,
                  onTap: () => _confirmClearOfflineData(context, session),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const _MeSectionHeader(title: 'About'),
              _SettingsGroup(children: [
                _SettingsTile(
                  title: 'Version',
                  value: _versionLabel,
                  showChevron: false,
                  onTap: () {},
                ),
                _SettingsTile(title: 'WY Limited', showChevron: false, onTap: () {}),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.session});

  final SessionState session;

  @override
  Widget build(BuildContext context) {
    final user = session.user;
    final isCloudSignedIn = session.isCloudSignedIn;
    final isLocalGuest = user != null && user.id.startsWith('local-');

    if (isCloudSignedIn && user != null) {
      return ProfileIdentityIsland(user: user);
    }

    final String title;
    final String subtitle;
    if (isLocalGuest) {
      title = user.displayName;
      subtitle = 'Local only — Supabase not configured';
    } else if (!Environment.hasSupabase) {
      title = 'Guest';
      subtitle = 'Add secrets to env/.env.local for cloud sign-in';
    } else {
      title = 'Guest';
      subtitle = 'Sign in to sync trips';
    }

    return ProfileGuestGlassCard(
      child: Row(
        children: [
          ProfileAvatar(user: user, isCloudSignedIn: isCloudSignedIn),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => SignInBottomSheet.show(context),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

class _CloudSyncSettingsTile extends StatelessWidget {
  const _CloudSyncSettingsTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudSyncBloc, CloudSyncState>(
      builder: (context, state) {
        final hasError = state.hasError;

        return _SettingsTile(
          title: 'Trip sync',
          subtitle: hasError ? state.lastError : null,
          value: state.isSyncing
              ? 'Syncing…'
              : hasError
                  ? 'Failed'
                  : state.lastSuccessLabel,
          showChevron: hasError && !state.isSyncing,
          onTap: hasError && !state.isSyncing
              ? () => context.read<CloudSyncBloc>().add(const CloudSyncRetryRequested())
              : () {},
        );
      },
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsGlassGroup(children: children);
  }
}

class _MeSectionHeader extends StatelessWidget {
  const _MeSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4, left: 2),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.value,
    this.subtitle,
    this.enabled = true,
    this.showChevron = true,
    required this.onTap,
  });

  final String title;
  final String? value;
  final String? subtitle;
  final bool enabled;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: enabled ? null : AppColors.textTertiary,
                      ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (value != null) Text(value!, style: Theme.of(context).textTheme.bodySmall),
          if (showChevron && enabled) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (!enabled) return Opacity(opacity: 0.55, child: content);
    return Pressable(onTap: onTap, child: content);
  }
}
