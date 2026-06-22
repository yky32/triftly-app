import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../bloc/trip_list_bloc.dart';
import '../widgets/trip_card.dart';
import '../bottom_sheets/create_trip_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('My Trips'),
            actions: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => _showNotifications(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<TripListBloc, TripListState>(
              builder: (context, state) {
                if (state.isLoading) return _buildLoading();
                if (state.trips.isEmpty) return _buildEmpty(context);
                return _buildTripList(context, state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTrip(context),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('New Trip'),
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
      enabled: true,
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TripCard(trip: mockTrip, index: index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: EmptyState(
        icon: Icons.flight_takeoff_rounded,
        title: 'No trips yet',
        subtitle: 'Plan your first adventure — add dates, buddies, and spots',
        action: () => _showCreateTrip(context),
        actionLabel: 'Create Trip',
      ),
    );
  }

  Widget _buildTripList(BuildContext context, TripListState state) {
    final upcoming = state.trips.where((t) => t.isUpcoming || !t.isPast).toList();
    final past = state.trips.where((t) => t.isPast).toList();
    var index = 0;

    return Padding(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (upcoming.isNotEmpty) ...[
            const SectionHeader(title: 'UPCOMING'),
            ...upcoming.map((trip) {
              final card = Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TripCard(trip: trip, index: index),
              );
              index++;
              return card;
            }),
          ],
          if (past.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(title: 'PAST'),
            ...past.map((trip) {
              final card = Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Opacity(
                  opacity: 0.72,
                  child: TripCard(trip: trip, index: index),
                ),
              );
              index++;
              return card;
            }),
          ],
        ],
      ),
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
        content: const Text('You\'re all caught up — no new notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
