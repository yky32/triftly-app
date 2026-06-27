import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/bloc/cloud_sync/cloud_sync_bloc.dart';
import '../../../../core/bloc/session/session_bloc.dart';
import '../../../../core/bootstrap/app_scope.dart';
import '../../bloc/trip_list_bloc.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_phase_segment.dart';
import '../bottom_sheets/create_trip_bottom_sheet.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/cloud_sync_banner.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppScopeBlocs.createTripListBloc()
        ..add(const TripListLoadRequested(syncCloud: false)),
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  TripPhase? _selectedPhase;

  TripPhase _defaultPhase(TripListSections sections) {
    if (sections.inProgress.isNotEmpty) return TripPhase.inProgress;
    if (sections.upcoming.isNotEmpty) return TripPhase.upcoming;
    return TripPhase.completed;
  }

  List<Trip> _tripsForPhase(TripListSections sections, TripPhase phase) {
    switch (phase) {
      case TripPhase.inProgress:
        return sections.inProgress;
      case TripPhase.upcoming:
        return sections.upcoming;
      case TripPhase.completed:
        return sections.completed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (prev, next) =>
          prev.isCloudSignedIn != next.isCloudSignedIn ||
          prev.user?.id != next.user?.id,
      listener: (context, session) {
        context.read<TripListBloc>().add(
              TripListLoadRequested(syncCloud: session.isCloudSignedIn),
            );
      },
      child: Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const TriftlyAppBarTitle(title: 'Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateTrip(context),
            tooltip: 'New trip',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CloudSyncBanner(
            onRetryComplete: () {
              context
                  .read<TripListBloc>()
                  .add(const TripListLoadRequested(syncCloud: false));
            },
          ),
          Expanded(
            child: RefreshIndicator(
        onRefresh: () async {
          final session = context.read<SessionBloc>().state;
          if (session.isCloudSignedIn) {
            final sync = context.read<CloudSyncBloc>();
            sync.add(CloudSyncRetryRequested(
              onComplete: () {
                if (!context.mounted) return;
                context.read<TripListBloc>().add(
                      const TripListLoadRequested(syncCloud: false),
                    );
              },
            ));
            await sync.stream.firstWhere((s) => !s.isSyncing);
            return;
          }
          context.read<TripListBloc>().add(
                const TripListLoadRequested(syncCloud: false),
              );
        },
        child: BlocBuilder<TripListBloc, TripListState>(
          builder: (context, state) {
            if (state.isLoading && state.trips.isEmpty) return _buildLoading();
            if (state.trips.isEmpty) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmpty(context),
                  ),
                ],
              );
            }
            return _buildTripList(context, state);
          },
        ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildLoading() {
    final now = DateTime.now();
    final mockTrip = Trip(
      id: 'mock-1',
      name: 'Loading...',
      destination: '...',
      startDate: now,
      endDate: now.add(const Duration(days: 5)),
      defaultCurrency: 'USD',
      createdAt: now,
    );

    return Skeletonizer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => TripCard(trip: mockTrip),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyState(
      expand: true,
      icon: Icons.luggage_outlined,
      title: 'No trips yet',
      action: () => _showCreateTrip(context),
      actionLabel: 'Create trip',
    );
  }

  Widget _buildTripList(BuildContext context, TripListState state) {
    final sections = TripListSections.from(state.trips);
    final selected = _selectedPhase ?? _defaultPhase(sections);
    final trips = _tripsForPhase(sections, selected);

    final counts = {
      TripPhase.inProgress: sections.inProgress.length,
      TripPhase.upcoming: sections.upcoming.length,
      TripPhase.completed: sections.completed.length,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
          child: TripPhaseSegment(
            selected: selected,
            counts: counts,
            onChanged: (TripPhase phase) => setState(() => _selectedPhase = phase),
          ),
        ),
        Expanded(
          child: trips.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: constraints.maxHeight,
                          child: Center(child: _buildPhaseEmpty(selected)),
                        ),
                      ],
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
                  itemCount: trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, index) => TripCard(trip: trips[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildPhaseEmpty(TripPhase phase) {
    final (icon, title) = switch (phase) {
      TripPhase.inProgress => (
          Icons.flight_takeoff_outlined,
          'Nothing in progress',
        ),
      TripPhase.upcoming => (
          Icons.event_outlined,
          'No upcoming trips',
        ),
      TripPhase.completed => (
          Icons.check_circle_outline_rounded,
          'No completed trips',
        ),
    };

    return EmptyState(
      compact: true,
      icon: icon,
      title: title,
    );
  }

  void _showCreateTrip(BuildContext context) {
    final tripListBloc = context.read<TripListBloc>();

    TriftlyBottomSheet.show<bool>(
      context,
      child: BlocProvider.value(
        value: tripListBloc,
        child: const CreateTripBottomSheet(),
      ),
    ).then((created) {
      if (!context.mounted) return;
      if (created == true) {
        tripListBloc.add(const TripListLoadRequested(syncCloud: false));
      }
    });
  }

  void _showNotifications(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('You\'re all caught up.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
