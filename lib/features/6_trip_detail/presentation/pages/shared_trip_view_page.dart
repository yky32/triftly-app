import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/bloc/session/session_bloc.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/constants/app_page.dart';
import '../../../../core/environment.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/repositories/hive_trip_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../../4_profile/presentation/bottom_sheets/sign_in_bottom_sheet.dart';
import 'trip_detail_page.dart';

/// Shared trip preview at `/s/:token` — join to add to Trips list.
class SharedTripViewPage extends StatefulWidget {
  const SharedTripViewPage({required this.shareToken, super.key});

  final String shareToken;

  @override
  State<SharedTripViewPage> createState() => _SharedTripViewPageState();
}

class _SharedTripViewPageState extends State<SharedTripViewPage> {
  late Future<SharedTripLoadResult> _loadFuture;
  bool _joining = false;
  String? _joinError;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadTrip();
  }

  Future<SharedTripLoadResult> _loadTrip() async {
    final repo = HiveTripRepository.instance;
    final local = repo.tripByShareToken(widget.shareToken);
    if (local != null && !local.isPreviewShare) {
      return SharedTripLoadResult.found(local, alreadyJoined: true);
    }

    final remote = await repo.hydrateSharedTrip(widget.shareToken);
    if (remote != null) {
      return SharedTripLoadResult.found(remote, alreadyJoined: !remote.isPreviewShare);
    }
    return SharedTripLoadResult.notFound;
  }

  Future<void> _joinTrip(SessionState session) async {
    if (_joining) return;

    if (!session.isCloudSignedIn) {
      await SignInBottomSheet.show(context);
      if (!mounted) return;
      final updated = context.read<SessionBloc>().state;
      if (!updated.isCloudSignedIn) return;
      return _joinTrip(updated);
    }

    setState(() {
      _joining = true;
      _joinError = null;
    });

    try {
      final userId = session.user!.id;
      final trip = await HiveTripRepository.instance.joinTripFromShare(
        widget.shareToken,
        userId,
      );
      if (!mounted) return;
      if (trip == null) {
        setState(() {
          _joining = false;
          _joinError = 'This link is invalid or expired';
        });
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('“${trip.name}” added to Trips'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('${AppPage.plan.path}/${trip.id}');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _joining = false;
        _joinError = _friendlyJoinError(error);
      });
    }
  }

  static String _friendlyJoinError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('not authenticated')) {
      return 'Sign in to join this trip';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
      return 'Couldn’t reach the server — try again';
    }
    return 'Couldn’t join — check the link and try again';
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
              action: () => context.go(AppPage.plan.path),
              actionLabel: 'Go to Trips',
            ),
          );
        }

        final trip = result.trip!;
        final session = context.watch<SessionBloc>().state;
        final isOwner = session.user?.id == trip.ownerId;
        final alreadyJoined = result.alreadyJoined || trip.isJoinedMember || isOwner;

        if (alreadyJoined) {
          return TripDetailPage(
            tripId: trip.id,
            readOnly: trip.isReadOnlyForCurrentUser,
          );
        }

        return Column(
          children: [
            Expanded(
              child: TripDetailPage(
                tripId: trip.id,
                readOnly: true,
              ),
            ),
            _JoinBanner(
              tripName: trip.name,
              joining: _joining,
              error: _joinError,
              supabaseReady: Environment.hasSupabase && AppBootstrap.supabaseReady,
              onJoin: () => _joinTrip(session),
            ),
          ],
        );
      },
    );
  }
}

class SharedTripLoadResult {
  const SharedTripLoadResult._({this.trip, this.alreadyJoined = false});

  final Trip? trip;
  final bool alreadyJoined;

  static const notFound = SharedTripLoadResult._();
  static SharedTripLoadResult found(Trip trip, {bool alreadyJoined = false}) =>
      SharedTripLoadResult._(trip: trip, alreadyJoined: alreadyJoined);
}

class _JoinBanner extends StatelessWidget {
  const _JoinBanner({
    required this.tripName,
    required this.joining,
    required this.supabaseReady,
    required this.onJoin,
    this.error,
  });

  final String tripName;
  final bool joining;
  final bool supabaseReady;
  final VoidCallback onJoin;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error != null) ...[
              Text(
                error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Pressable(
              onTap: joining || !supabaseReady ? null : onJoin,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: supabaseReady ? AppColors.primary : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (joining)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Text(
                        supabaseReady
                            ? 'Join “$tripName”'
                            : 'Sign in unavailable offline',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              supabaseReady
                  ? 'Join as a viewer — plan, spend, and map sync to your Trips. The owner can promote you to editor.'
                  : 'Connect Supabase to join shared trips.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
