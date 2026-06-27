import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../bloc/session/session_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'glass_surface.dart';
import 'trips_sync_status.dart';

/// Centered sync pill for the Trips app bar.
class TripsSyncCenterBanner extends StatelessWidget {
  const TripsSyncCenterBanner({
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
            final tertiary =
                isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

            void retry() {
              context.read<CloudSyncBloc>().add(
                    CloudSyncRetryRequested(onComplete: onRetryComplete),
                  );
            }

            final icon = status.isSyncing
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: status.isError ? AppColors.error : tertiary,
                    ),
                  )
                : Icon(
                    status.isError
                        ? Icons.cloud_off_outlined
                        : session.isCloudSignedIn
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                    size: 14,
                    color: status.isError ? AppColors.error : tertiary,
                  );

            final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: status.isError ? AppColors.error : tertiary,
                  fontWeight: FontWeight.w500,
                );

            final pill = GlassSurface(
              blur: 18,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              tint: status.isError
                  ? AppColors.error.withValues(alpha: isDark ? 0.18 : 0.08)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      status.centerLabel,
                      style: labelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status.isError) ...[
                    const SizedBox(width: 4),
                    Text(
                      '· Retry',
                      style: labelStyle?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            );

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 168),
              child: status.isError
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: sync.isSyncing ? null : retry,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: pill,
                      ),
                    )
                  : pill,
            );
          },
        );
      },
    );
  }
}
