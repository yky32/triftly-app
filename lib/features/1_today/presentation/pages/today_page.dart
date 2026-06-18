import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:triftly/core/constants/layout_constants.dart';
import 'package:triftly/core/navigation/app_navigation.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/1_today/bloc/today_bloc.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/widgets/design/triftly_day_chip.dart';
import 'package:triftly/widgets/design/triftly_layout.dart';
import 'package:triftly/widgets/design/triftly_page_header.dart';

/// **Day** tab — browse each day of the trip and follow the spot timeline.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodayBloc(
        repository: context.read<RoutineRepository>(),
      )..add(const TodayLoaded()),
      child: const _DayView(),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<TodayBloc, TodayState>(
          builder: (context, state) {
            return Skeletonizer(
              enabled: state.isLoading,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      TriftlyLayout.pagePadding,
                      16,
                      TriftlyLayout.pagePadding,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        TriftlyPageHeader(
                          title: 'Day',
                          subtitle: state.hasTrip && state.trip != null
                              ? state.trip!.trip.name
                              : 'Spot-by-spot itinerary',
                          trailing: IconButton(
                            onPressed: () =>
                                context.push(AppPage.settings.path),
                            icon: const Icon(Icons.settings_outlined),
                            color: AppColors.mistGray,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!state.hasTrip && !state.isLoading)
                          TriftlyEmptyState(
                            icon: Icons.view_timeline_rounded,
                            title: 'No trip to explore',
                            message:
                                'Plan a trip first, then come back to follow each day.',
                            action: FilledButton.icon(
                              onPressed: () =>
                                  AppNavigation.openTripPlanner(context),
                              icon: const Icon(Icons.edit_calendar_outlined),
                              label: const Text('Plan a trip'),
                            ),
                          )
                        else if (state.hasTrip && state.trip != null) ...[
                          _TripHeroCard(state: state),
                          const SizedBox(height: 20),
                          _DaySelector(state: state),
                          const SizedBox(height: 16),
                          if (state.daySpots.isEmpty)
                            TriftlyEmptyState(
                              icon: Icons.place_outlined,
                              title: 'No spots this day',
                              message: 'Add stops in the planner.',
                              action: TextButton(
                                onPressed: () =>
                                    AppNavigation.openTripPlanner(context),
                                child: const Text('Open planner'),
                              ),
                            )
                          else
                            ...List.generate(
                              state.daySpots.length,
                              (i) => TriftlySpotTimelineTile(
                                spot: state.daySpots[i],
                                isFirst: i == 0,
                                isLast: i == state.daySpots.length - 1,
                                onToggle: () => context.read<TodayBloc>().add(
                                      TodaySpotToggled(spotIndex: i),
                                    ),
                              ),
                            ),
                        ],
                        SizedBox(
                          height: LayoutConstants.scrollPaddingBelowNavBar(
                            context,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TripHeroCard extends StatelessWidget {
  const _TripHeroCard({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = state.trip!;
    final dayLabel = trip.dayLabels[state.selectedDayIndex];
    final displayDay = dayLabel?.isNotEmpty == true
        ? dayLabel!
        : 'Day ${state.selectedDayIndex + 1}';

    return TriftlySurfaceCard(
      gradient: TriftlyLayout.gradientPrimary,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayDay,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.completedDayCount}/${state.totalDayCount} spots done today',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.dayProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (state.daysRemaining > 0) ...[
            const SizedBox(height: 10),
            Text(
              '${state.daysRemaining} day${state.daysRemaining == 1 ? '' : 's'} left in trip',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final trip = state.trip!;
    final dayCount = trip.trip.daysOfTrip;
    if (dayCount <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TriftlySectionLabel(title: 'Select day'),
        SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dayCount,
            itemBuilder: (context, index) {
              final date = trip.trip.startDate.add(Duration(days: index));
              final subtitle = MaterialLocalizations.of(context)
                  .formatShortDate(date);
              final label = trip.dayLabels[index]?.isNotEmpty == true
                  ? trip.dayLabels[index]!
                  : 'Day ${index + 1}';

              return TriftlyDayChip(
                label: label,
                subtitle: subtitle,
                selected: state.selectedDayIndex == index,
                isToday: state.todayDayIndex == index,
                onTap: () => context
                    .read<TodayBloc>()
                    .add(TodayDaySelected(index)),
              );
            },
          ),
        ),
      ],
    );
  }
}
