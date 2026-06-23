import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/trip_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'trip_detail_page.dart';

/// Public read-only trip view at `/s/:token` (DESIGN_SPEC P1).
class SharedTripViewPage extends StatelessWidget {
  const SharedTripViewPage({required this.shareToken, super.key});

  final String shareToken;

  @override
  Widget build(BuildContext context) {
    final trip = TripStore.instance.tripByShareToken(shareToken);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.link_off_rounded,
          title: 'Trip not found',
          subtitle: 'This share link may have expired or been removed.',
          action: () => context.go('/plan'),
          actionLabel: 'Go to trips',
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: TripDetailPage(tripId: trip.id, readOnly: true)),
        _DownloadBanner(onTap: () => context.go('/plan')),
      ],
    );
  }
}

class _DownloadBanner extends StatelessWidget {
  const _DownloadBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
        child: Pressable(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Plan your own trip on Triftly',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
