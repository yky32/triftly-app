import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../bloc/trip_list_bloc.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_phase_segment.dart';
import '../bottom_sheets/create_trip_bottom_sheet.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/widgets/empty_state.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripListBloc()..add(TripListLoadRequested()),
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
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Trips'),
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
      body: BlocBuilder<TripListBloc, TripListState>(
        builder: (context, state) {
          if (state.isLoading) return _buildLoading();
          if (state.trips.isEmpty) return _buildEmpty(context);
          return _buildTripList(context, state);
        },
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
      icon: Icons.luggage_outlined,
      title: 'No trips yet',
      subtitle: 'Start planning your next trip',
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
              ? _buildPhaseEmpty(selected)
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
    final (icon, title, subtitle) = switch (phase) {
      TripPhase.inProgress => (
          Icons.flight_takeoff_rounded,
          'Nothing in progress',
          'Trips you\'re on right now show up here',
        ),
      TripPhase.upcoming => (
          Icons.event_rounded,
          'No upcoming trips',
          'Plan your next adventure',
        ),
      TripPhase.completed => (
          Icons.check_circle_outline_rounded,
          'No completed trips',
          'Past trips will appear here',
        ),
    };

    return EmptyState(icon: icon, title: title, subtitle: subtitle);
  }

  void _showCreateTrip(BuildContext context) {
    final tripListBloc = context.read<TripListBloc>();

    showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: tripListBloc,
        child: const CreateTripBottomSheet(),
      ),
    ).then((created) {
      if (!context.mounted) return;
      if (created == true) {
        tripListBloc.add(TripListLoadRequested());
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
