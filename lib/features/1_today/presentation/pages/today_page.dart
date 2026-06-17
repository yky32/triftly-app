import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/1_today/bloc/today_bloc.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/features/3_routine_builder/models/routine_spot.dart';
import 'package:triftly/router/app_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodayBloc(
        repository: context.read<RoutineRepository>(),
      )..add(const TodayLoaded()),
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<TodayBloc, TodayState>(
          builder: (context, state) {
            return Skeletonizer(
              enabled: state.isLoading,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ───────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(now),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.page_today,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$greeting, Traveller ✈️',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_outlined,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () =>
                              context.push(AppPage.settings.path),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Active Trip Banner ──────────────────────────────
                    if (state.hasActiveTrip && state.activeTrip != null)
                      _ActiveTripBanner(
                        trip: state.activeTrip!,
                        todayProgress: state.todayProgress,
                        tripProgress: state.tripProgress,
                        completedToday: state.completedTodayCount,
                        totalToday: state.totalTodayCount,
                        daysRemaining: state.daysRemaining,
                        onTap: () =>
                            context.goNamed(AppPage.routine.name),
                      )
                    else if (!state.isLoading)
                      _EmptyTripBanner(
                        onTap: () =>
                            context.goNamed(AppPage.routine.name),
                      )
                    else
                      _ActiveTripBanner.skeleton(),

                    const SizedBox(height: 24),

                    // ── Today's Schedule ─────────────────────────────────
                    _SectionHeader(title: "Today's Schedule"),
                    const SizedBox(height: 12),
                    if (state.hasActiveTrip && state.todaySpots.isNotEmpty)
                      _TodaySchedule(
                        spots: state.todaySpots,
                        onToggle: (index) => context
                            .read<TodayBloc>()
                            .add(TodaySpotToggled(spotIndex: index)),
                      )
                    else if (state.hasActiveTrip &&
                        state.todaySpots.isEmpty)
                      _EmptyTodaySchedule(
                        onAdd: () =>
                            context.goNamed(AppPage.routine.name),
                      )
                    else if (!state.isLoading)
                      _NoTripSchedule(
                        onCreate: () =>
                            context.goNamed(AppPage.routine.name),
                      )
                    else
                      _TodaySchedule.skeleton(),

                    const SizedBox(height: 24),

                    // ── Trip Progress ────────────────────────────────────
                    if (state.hasActiveTrip && state.totalTripSpots > 0) ...[
                      _SectionHeader(title: 'Trip Progress'),
                      const SizedBox(height: 12),
                      _TripProgressCard(
                        tripProgress: state.tripProgress,
                        completedCount: state.totalTripCompleted,
                        totalCount: state.totalTripSpots,
                        todayProgress: state.todayProgress,
                        completedToday: state.completedTodayCount,
                        totalToday: state.totalTodayCount,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Quick Actions ────────────────────────────────────
                    _SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _QuickActionsGrid(
                      actions: [
                        _QuickAction(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'New Trip',
                          color: AppColors.driftTeal,
                          onTap: () =>
                              context.goNamed(AppPage.routine.name),
                        ),
                        _QuickAction(
                          icon: Icons.luggage_rounded,
                          label: 'My Trips',
                          color: AppColors.calmGreen,
                          onTap: () =>
                              context.goNamed(AppPage.trips.name),
                        ),
                        _QuickAction(
                          icon: Icons.map_outlined,
                          label: 'Map',
                          color: AppColors.softAmber,
                          onTap: () =>
                              context.goNamed(AppPage.map.name),
                        ),
                        _QuickAction(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Spend',
                          color: AppColors.sunsetCoral,
                          onTap: () =>
                              context.goNamed(AppPage.spend.name),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$weekday, $month ${dt.day}';
  }
}

// ── Active Trip Banner ──────────────────────────────────────────────────────

class _ActiveTripBanner extends StatelessWidget {
  const _ActiveTripBanner({
    required this.trip,
    required this.todayProgress,
    required this.tripProgress,
    required this.completedToday,
    required this.totalToday,
    required this.daysRemaining,
    required this.onTap,
  });

  final SavedRoutine trip;
  final double todayProgress;
  final double tripProgress;
  final int completedToday;
  final int totalToday;
  final int daysRemaining;
  final VoidCallback onTap;

  static Widget skeleton() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.fogGray.withValues(alpha: 0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final startLabel = localizations.formatShortDate(trip.trip.startDate);
    final endLabel = localizations.formatShortDate(trip.trip.endDate);
    final dateLabel = trip.trip.startDate == trip.trip.endDate
        ? startLabel
        : '$startLabel – $endLabel';
    final dayLabel =
        daysRemaining == 1 ? '1 day left' : '$daysRemaining days left';
    final countriesText = trip.trip.countries.join(' · ');

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.deepTeal, AppColors.driftTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTIVE TRIP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dayLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  trip.trip.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (countriesText.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.place_rounded,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          countriesText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                // Today progress
                if (totalToday > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.today_rounded,
                          size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'Today: $completedToday/$totalToday done',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: todayProgress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Open Routine',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty Trip Banner ────────────────────────────────────────────────────────

class _EmptyTripBanner extends StatelessWidget {
  const _EmptyTripBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.fogGray.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.flight_takeoff_rounded,
                    size: 40, color: AppColors.mistGray),
                const SizedBox(height: 12),
                Text(
                  'No active trip',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan your next adventure',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Today's Schedule ─────────────────────────────────────────────────────────

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule({required this.spots, required this.onToggle});

  final List<RoutineSpot> spots;
  final void Function(int index) onToggle;

  static Widget skeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: spots.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 56,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) =>
            _ScheduleTile(spot: spots[index], onToggle: () => onToggle(index)),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.spot, required this.onToggle});
  final RoutineSpot spot;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: spot.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(spot.icon, size: 18, color: spot.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: spot.isCompleted
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    decoration:
                        spot.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${spot.startTime} – ${spot.endTime}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: spot.isCompleted
                    ? AppColors.calmGreen
                    : Colors.transparent,
                border: Border.all(
                  color: spot.isCompleted
                      ? AppColors.calmGreen
                      : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: spot.isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty states ─────────────────────────────────────────────────────────────

class _EmptyTodaySchedule extends StatelessWidget {
  const _EmptyTodaySchedule({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded,
              size: 32, color: AppColors.mistGray),
          const SizedBox(height: 8),
          Text(
            'No activities planned for today',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add to routine'),
          ),
        ],
      ),
    );
  }
}

class _NoTripSchedule extends StatelessWidget {
  const _NoTripSchedule({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 32, color: AppColors.mistGray),
          const SizedBox(height: 8),
          Text(
            'Create a trip to see your daily schedule',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Plan a trip'),
          ),
        ],
      ),
    );
  }
}

// ── Trip Progress Card ───────────────────────────────────────────────────────

class _TripProgressCard extends StatelessWidget {
  const _TripProgressCard({
    required this.tripProgress,
    required this.completedCount,
    required this.totalCount,
    required this.todayProgress,
    required this.completedToday,
    required this.totalToday,
  });

  final double tripProgress;
  final int completedCount;
  final int totalCount;
  final double todayProgress;
  final int completedToday;
  final int totalToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall trip progress
          Row(
            children: [
              Icon(Icons.terrain_rounded,
                  size: 18, color: AppColors.driftTeal),
              const SizedBox(width: 8),
              Text(
                'Overall',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount / $totalCount',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tripProgress,
              minHeight: 6,
              backgroundColor: AppColors.driftTeal.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.driftTeal),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(tripProgress * 100).toInt()}% complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.driftTeal,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          if (totalToday > 0) ...[
            const SizedBox(height: 16),
            // Today progress
            Row(
              children: [
                Icon(Icons.today_rounded,
                    size: 18, color: AppColors.calmGreen),
                const SizedBox(width: 8),
                Text(
                  'Today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completedToday / $totalToday',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: todayProgress,
                minHeight: 6,
                backgroundColor: AppColors.calmGreen.withValues(alpha: 0.15),
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.calmGreen),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});
  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: actions.map((a) => _QuickActionTile(action: a)).toList(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: action.color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 24),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
