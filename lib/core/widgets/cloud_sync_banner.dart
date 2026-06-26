import 'package:flutter/material.dart';

import '../bootstrap/app_bootstrap.dart';
import '../repositories/cloud_trip_sync.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Trips-tab banner for cloud sync status and retry.
class CloudSyncBanner extends StatelessWidget {
  const CloudSyncBanner({
    required this.onRetryComplete,
    super.key,
  });

  final VoidCallback onRetryComplete;

  Future<void> _retry(BuildContext context) async {
    final user = AppBootstrap.userSession.currentUser;
    if (user == null) return;

    try {
      await CloudTripSync.syncForUser(
        user,
        AppBootstrap.tripRepository,
        syncStatus: AppBootstrap.cloudSyncStatus,
      );
      onRetryComplete();
      if (!context.mounted) return;
      if (!AppBootstrap.cloudSyncStatus.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trips synced')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppBootstrap.cloudSyncStatus.lastError ?? 'Could not sync trips',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppBootstrap.cloudSyncStatus,
      builder: (context, _) {
        final status = AppBootstrap.cloudSyncStatus;
        final session = AppBootstrap.userSession;
        if (!status.isConfigured || !session.isCloudSignedIn) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (status.hasError) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Material(
              color: AppColors.error.withValues(alpha: isDark ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Could not sync trips',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status.lastError!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: status.isSyncing ? null : () => _retry(context),
                      child: status.isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (status.isSyncing) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Syncing trips…',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        if (status.lastSuccessAt == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 16,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                status.lastSuccessLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
