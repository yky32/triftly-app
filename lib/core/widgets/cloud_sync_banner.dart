import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../bootstrap/app_bootstrap.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Trips-tab banner for cloud sync status and retry.
class CloudSyncBanner extends StatelessWidget {
  const CloudSyncBanner({
    required this.onRetryComplete,
    super.key,
  });

  final VoidCallback onRetryComplete;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CloudSyncBloc, CloudSyncState>(
      listenWhen: (previous, current) =>
          previous.isSyncing &&
          !current.isSyncing &&
          !current.hasError,
      listener: (context, state) => onRetryComplete(),
      builder: (context, state) {
        final session = AppBootstrap.userSession;
        if (!state.isConfigured || !session.isCloudSignedIn) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (state.hasError) {
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
                            state.lastError!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: state.isSyncing
                          ? null
                          : () => context.read<CloudSyncBloc>().add(
                                CloudSyncRetryRequested(onComplete: onRetryComplete),
                              ),
                      child: state.isSyncing
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

        if (state.isSyncing) {
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

        if (state.lastSuccessAt == null) return const SizedBox.shrink();

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
                state.lastSuccessLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
