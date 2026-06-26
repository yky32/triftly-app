import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/repositories/hive_trip_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'trip_detail_page.dart';

/// Public read-only trip view at `/s/:token` (DESIGN_SPEC P1).
class SharedTripViewPage extends StatefulWidget {
  const SharedTripViewPage({required this.shareToken, super.key});

  final String shareToken;

  @override
  State<SharedTripViewPage> createState() => _SharedTripViewPageState();
}

class _SharedTripViewPageState extends State<SharedTripViewPage> {
  late Future<SharedTripLoadResult> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadTrip();
  }

  Future<SharedTripLoadResult> _loadTrip() async {
    final repo = HiveTripRepository.instance;
    final local = repo.tripByShareToken(widget.shareToken);
    if (local != null) return SharedTripLoadResult.found(local);

    final remote = await repo.hydrateSharedTrip(widget.shareToken);
    if (remote != null) return SharedTripLoadResult.found(remote);
    return SharedTripLoadResult.notFound;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedTripLoadResult>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data;
        if (result == null || result.trip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              expand: true,
              icon: Icons.link_off_rounded,
              title: 'Link not found',
              action: () => context.go('/plan'),
              actionLabel: 'Go to Trips',
            ),
          );
        }

        final trip = result.trip!;
        return Column(
          children: [
            Expanded(child: TripDetailPage(tripId: trip.id, readOnly: true)),
            _DownloadBanner(onTap: () => context.go('/plan')),
          ],
        );
      },
    );
  }
}

class SharedTripLoadResult {
  const SharedTripLoadResult._({this.trip});

  final Trip? trip;

  static const notFound = SharedTripLoadResult._();
  static SharedTripLoadResult found(Trip trip) => SharedTripLoadResult._(trip: trip);
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
