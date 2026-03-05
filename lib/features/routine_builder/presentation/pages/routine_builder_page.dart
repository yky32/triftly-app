import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/routine_day_carousel.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

class RoutineBuilderPage extends StatelessWidget {
  const RoutineBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoutineBuilderBloc(),
      child: const _RoutineBuilderView(),
    );
  }
}

class _RoutineBuilderView extends StatelessWidget {
  const _RoutineBuilderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<RoutineBuilderBloc, RoutineBuilderState>(
          builder: (context, state) {
            final hasTrip = state.trip != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
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
                ),
                if (hasTrip)
                  Expanded(
                    child: RoutineDayCarousel(
                      trip: state.trip!,
                      currentPageIndex: state.currentDayPageIndex,
                      onPageChanged: (index) => context
                          .read<RoutineBuilderBloc>()
                          .add(CarouselPageChanged(index)),
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
    final title = trip != null && trip.name.isNotEmpty
        ? trip.name
        : context.l10n.page_routine_builder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
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
