import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/trip_list_bloc.dart';
import '../widgets/trip_card.dart';
import '../bottom_sheets/create_trip_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';

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
      appBar: AppBar(
        title: const Text('Trip App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<TripListBloc, TripListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return _buildLoading();
          }
          if (state.trips.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildTripList(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTrip(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_takeoff, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plan your first adventure',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateTrip(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Trip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList(BuildContext context, TripListState state) {
    final upcoming = state.trips.where((t) => t.isUpcoming || !t.isPast).toList();
    final past = state.trips.where((t) => t.isPast).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text(
            'UPCOMING',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 8),
          ...upcoming.map((trip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TripCard(trip: trip),
              )),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'PAST',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 8),
          ...past.map((trip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: 0.6,
                  child: TripCard(trip: trip),
                ),
              )),
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
}
