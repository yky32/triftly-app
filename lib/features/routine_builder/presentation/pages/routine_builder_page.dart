import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_add_spot_bottom_sheet.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/routine_day_carousel.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

class RoutineBuilderPage extends StatelessWidget {
  const RoutineBuilderPage({super.key, this.pendingSpotFromMap});

  /// When non-null, opened from map "Add to routine"; add-spot sheet is shown with this as initial.
  final RoutineSpot? pendingSpotFromMap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoutineBuilderBloc(pendingSpotFromMap: pendingSpotFromMap),
      child: const _RoutineBuilderView(),
    );
  }
}

class _RoutineBuilderView extends StatefulWidget {
  const _RoutineBuilderView();

  @override
  State<_RoutineBuilderView> createState() => _RoutineBuilderViewState();
}

class _RoutineBuilderViewState extends State<_RoutineBuilderView> {
  static const double _scrollThresholdHide = 80;
  static const double _scrollThresholdShow = 30;
  bool _headerVisible = true;

  bool _onScrollNotification(ScrollNotification n) {
    if (n is! ScrollUpdateNotification) return false;
    final p = n.metrics.pixels;
    if (p > _scrollThresholdHide && _headerVisible) {
      setState(() => _headerVisible = false);
    } else if (p < _scrollThresholdShow && !_headerVisible) {
      setState(() => _headerVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<RoutineBuilderBloc, RoutineBuilderState>(
          listenWhen: (prev, curr) =>
              (curr.pendingSpotToAddFromMap != null &&
                  prev.pendingSpotToAddFromMap != curr.pendingSpotToAddFromMap) ||
              prev.trip != curr.trip ||
              prev.currentDayPageIndex != curr.currentDayPageIndex,
          listener: (context, state) {
            final spot = state.pendingSpotToAddFromMap;
            if (spot != null) {
              context.read<RoutineBuilderBloc>().add(PendingSpotFromMapConsumed());
              final date = state.trip?.startDate ?? DateTime.now();
              RoutineDayAddSpotBottomSheet.show(
                context,
                dayIndex: 0,
                date: date,
                initialSpot: spot,
              ).then((saved) {
                if (saved != null && context.mounted) {
                  context
                      .read<RoutineBuilderBloc>()
                      .add(SpotAdded(dayIndex: 0, spot: saved));
                }
              });
            } else {
              setState(() => _headerVisible = true);
            }
          },
          buildWhen: (prev, curr) =>
              prev.trip != curr.trip ||
              prev.currentDayPageIndex != curr.currentDayPageIndex ||
              prev.spotsByDay != curr.spotsByDay,
          builder: (context, state) {
            final hasTrip = state.trip != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _headerVisible
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: _buildHeader(
                            context,
                            trip: state.trip,
                            onNewRoutine: () => _openTripSheet(context),
                            onEdit: state.trip != null
                                ? () => _openTripSheetForEdit(context, state.trip!)
                                : null,
                            onDelete: state.trip != null
                                ? () => _confirmAndDeleteRoutine(context)
                                : null,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (hasTrip)
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: RoutineDayCarousel(
                        trip: state.trip!,
                        currentPageIndex: state.currentDayPageIndex,
                        onPageChanged: (index) => context
                            .read<RoutineBuilderBloc>()
                            .add(CarouselPageChanged(index)),
                        spotsForDay: state.spotsForDay,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _buildEmptyStateNotice(context),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildEmptyStateNotice(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.explore_rounded,
          size: 52,
          color: colorScheme.primary.withValues(alpha: 0.75),
        ),
        const SizedBox(height: 20),
        Text(
          'Plan your trip in a few steps',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _EmptyStateStep(
          icon: Icons.add_circle_outline,
          text: 'Tap the top-right + to create a trip routine, select your dates, and see day-by-day pages.',
          color: onSurfaceVariant,
        ),
        const SizedBox(height: 14),
        _EmptyStateStep(
          icon: Icons.edit_calendar_outlined,
          text: 'Configure each day: add spots, set times, and name your days.',
          color: onSurfaceVariant,
        ),
        const SizedBox(height: 14),
        _EmptyStateStep(
          icon: Icons.flight_takeoff_rounded,
          text: 'Swipe between days and build your itinerary before you go.',
          color: onSurfaceVariant,
        ),
      ],
    );
  }

Widget _buildHeader(
    BuildContext context, {
    required RoutineTripResult? trip,
    required VoidCallback onNewRoutine,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final theme = Theme.of(context);
    final title = trip != null && trip.name.isNotEmpty
        ? trip.name
        : context.l10n.page_routine_builder;
    final hasCountries = trip != null && trip.countries.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasCountries) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.countries.join(', '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trip != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Routine',
              onPressed: onNewRoutine,
            ),
        ],
      ),
    );
  }

Future<void> _openTripSheet(BuildContext context) async {
    final result = await RoutineBuilderBottomSheet.show(context);
    if (result != null && context.mounted) {
      context.read<RoutineBuilderBloc>().add(TripSelected(result));
    }
  }

Future<void> _openTripSheetForEdit(
      BuildContext context, RoutineTripResult currentTrip) async {
    final result = await RoutineBuilderBottomSheet.show(
      context,
      initialStartDate: currentTrip.startDate,
      initialEndDate: currentTrip.endDate,
      initialName: currentTrip.name,
      initialCountries: currentTrip.countries,
    );
    if (result != null && context.mounted) {
      context.read<RoutineBuilderBloc>().add(TripSelected(result));
    }
  }

Future<void> _confirmAndDeleteRoutine(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete routine?'),
        content: const Text(
          'This will remove the current trip and all its days. You can create a new routine anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<RoutineBuilderBloc>().add(TripCleared());
    }
  }

class _EmptyStateStep extends StatelessWidget {
  const _EmptyStateStep({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
