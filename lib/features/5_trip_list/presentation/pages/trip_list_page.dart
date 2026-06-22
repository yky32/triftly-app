import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../bloc/trip_list_bloc.dart';
import '../widgets/trip_card.dart';
import '../bottom_sheets/create_trip_bottom_sheet.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';

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

class _View extends StatelessWidget {
  const _View();

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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.navIslandClearance),
        child: FloatingActionButton(
          onPressed: () => _showCreateTrip(context),
          child: const Icon(Icons.add_rounded),
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
      icon: Icons.luggage_outlined,
      title: 'No trips yet',
      subtitle: 'Start planning your next trip',
      action: () => _showCreateTrip(context),
      actionLabel: 'Create trip',
    );
  }

  Widget _buildTripList(BuildContext context, TripListState state) {
    final upcoming = state.trips.where((t) => t.isUpcoming || !t.isPast).toList();
    final past = state.trips.where((t) => t.isPast).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        if (upcoming.isNotEmpty) ...[
          const SectionHeader(title: 'Upcoming'),
          ...upcoming.map(
            (trip) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TripCard(trip: trip),
            ),
          ),
        ],
        if (past.isNotEmpty) ...[
          const SectionHeader(title: 'Past'),
          ...past.map(
            (trip) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Opacity(opacity: 0.65, child: TripCard(trip: trip)),
            ),
          ),
        ],
      ],
    );
  }

  void _showCreateTrip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTripBottomSheet(),
    ).then((_) {
      if (context.mounted) {
        context.read<TripListBloc>().add(TripListLoadRequested());
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
