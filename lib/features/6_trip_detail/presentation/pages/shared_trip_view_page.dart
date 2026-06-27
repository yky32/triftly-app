import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/bloc/session/session_bloc.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/constants/app_page.dart';
import '../../../../core/environment.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/navigation/share_invite_flow.dart';
import '../../../../core/repositories/hive_trip_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../bottom_sheets/join_trip_bottom_sheet.dart';
import 'trip_detail_page.dart';

/// Shared trip preview at `/s/:token` — routes buddies by install/auth state.
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
  bool _joinSheetShown = false;
  bool _joinPromptDismissed = false;
  bool _redirectedToSignIn = false;

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

  void _redirectToSignIn() {
    if (_redirectedToSignIn) return;
    _redirectedToSignIn = true;
    ShareInviteFlow.beginSignIn(widget.shareToken);
    context.go(AppPage.profile.path);
  }

  Future<void> _promptJoin(Trip trip) async {
    if (_joining || _joinSheetShown) return;
    setState(() {
      _joinSheetShown = true;
      _joinPromptDismissed = false;
    });

    final confirmed = await JoinTripBottomSheet.show(
      context,
      tripName: trip.name,
    );
    if (!mounted) return;

    if (!confirmed) {
      setState(() {
        _joinSheetShown = false;
        _joinPromptDismissed = true;
      });
      return;
    }

    await _performJoin();
  }

  Future<void> _performJoin() async {
    if (_joining) return;

    final session = context.read<SessionBloc>().state;
    if (!session.isCloudSignedIn) {
      _redirectToSignIn();
      return;
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
      ShareInviteFlow.clear();
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
          ShareInviteFlow.clear();
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
          ShareInviteFlow.clear();
          return TripDetailPage(
            tripId: trip.id,
            readOnly: trip.isReadOnlyForCurrentUser,
          );
        }

        if (!session.isCloudSignedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _redirectToSignIn();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!Environment.hasSupabase || !AppBootstrap.supabaseReady) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              expand: true,
              icon: Icons.cloud_off_outlined,
              title: 'Sign in unavailable offline',
              subtitle: 'Connect to the internet to join shared trips.',
              action: () => context.go(AppPage.plan.path),
              actionLabel: 'Go to Trips',
            ),
          );
        }

        if (!_joinSheetShown && !_joining) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _promptJoin(trip);
          });
        }

        return Stack(
          children: [
            TripDetailPage(
              tripId: trip.id,
              readOnly: true,
            ),
            if (_joinPromptDismissed && !_joining)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: SafeArea(
                  top: false,
                  child: FilledButton(
                    onPressed: () => _promptJoin(trip),
                    child: Text('Join “${trip.name}”'),
                  ),
                ),
              ),
            if (_joining)
              const ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_joinError != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.error.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _joinError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ),
                ),
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
