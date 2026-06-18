import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:triftly/core/constants/layout_constants.dart';
import 'package:triftly/core/navigation/app_navigation.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/2_trips/bloc/trips_bloc.dart';
import 'package:triftly/features/2_trips/presentation/widgets/bottom_sheets/trip_details_bottom_sheet.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/widgets/design/triftly_layout.dart';
import 'package:triftly/widgets/design/triftly_page_header.dart';

/// **Plan** tab — trip library and entry to the day/spot planner.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripsBloc(
        repository: context.read<RoutineRepository>(),
      ),
      child: const _PlanView(),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TriftlyLayout.pagePadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TriftlyPageHeader(
                title: 'Plan',
                subtitle: 'Trips, days, and spots',
                trailing: IconButton(
                  onPressed: () => context
                      .read<TripsBloc>()
                      .add(const TripsReloadRequested()),
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppColors.driftTeal,
                  tooltip: 'Refresh',
                ),
              ),
              const SizedBox(height: 20),
              TriftlySurfaceCard(
                gradient: TriftlyLayout.gradientPrimary,
                onTap: () => AppNavigation.openTripPlanner(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New trip',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pick dates, add spots per day',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const TriftlySectionLabel(title: 'Your trips'),
              Expanded(
                child: BlocBuilder<TripsBloc, TripsState>(
                  builder: (context, state) {
                    final isLoading = state.isLoading;
                    return Skeletonizer(
                      enabled: isLoading,
                      child: state.trips.isEmpty && !isLoading
                          ? TriftlyEmptyState(
                              icon: Icons.luggage_outlined,
                              title: 'No trips yet',
                              message:
                                  'Start with a name, dates, and your first spots.',
                              action: FilledButton(
                                onPressed: () =>
                                    AppNavigation.openTripPlanner(context),
                                child: const Text('Plan your first trip'),
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.only(
                                bottom: LayoutConstants.scrollPaddingBelowNavBar(
                                  context,
                                ),
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: isLoading ? 4 : state.trips.length,
                              itemBuilder: (context, index) {
                                if (isLoading) {
                                  return const _TripGridCard.placeholder();
                                }
                                final trip = state.trips[index];
                                return _TripGridCard(
                                  trip: trip,
                                  onTap: () => TripDetailsBottomSheet.show(
                                    context,
                                    trip,
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripGridCard extends StatelessWidget {
  const _TripGridCard({required this.trip, required this.onTap});

  const _TripGridCard.placeholder()
      : trip = null,
        onTap = null;

  final SavedTripSummary? trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = trip;
    final name = t == null
        ? 'Trip name'
        : (t.name.trim().isEmpty ? 'Untitled trip' : t.name);
    final country = t?.countries.isNotEmpty == true
        ? t!.countries.first
        : 'Destination';
    final days = t == null
        ? '7 days'
        : '${t.endDate.difference(t.startDate).inDays + 1} days';

    return TriftlySurfaceCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 88,
            decoration: const BoxDecoration(
              gradient: TriftlyLayout.gradientWarm,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.all(14),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                country,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  days,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mistGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
