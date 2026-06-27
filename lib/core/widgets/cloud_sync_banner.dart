import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../bloc/session/session_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'trips_sync_status.dart';

/// Trips-tab banner for cloud sync status and retry.
class CloudSyncBanner extends StatelessWidget {
  const CloudSyncBanner({
    required this.onRetryComplete,
    super.key,
  });

  final VoidCallback onRetryComplete;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, session) {
        return BlocConsumer<CloudSyncBloc, CloudSyncState>(
          listenWhen: (previous, current) =>
              session.isCloudSignedIn &&
              previous.isSyncing &&
              !current.isSyncing &&
              !current.hasError,
          listener: (context, state) => onRetryComplete(),
          builder: (context, sync) {
            final status = TripsSyncStatus.resolve(session: session, sync: sync);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            if (status.isError) {
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
                                status.label,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (status.errorDetail != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  status.errorDetail!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: sync.isSyncing
                              ? null
                              : () => context.read<CloudSyncBloc>().add(
                                    CloudSyncRetryRequested(onComplete: onRetryComplete),
                                  ),
                          child: sync.isSyncing
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

            return Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  if (status.isSyncing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      session.isCloudSignedIn
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      size: 16,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      status.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
