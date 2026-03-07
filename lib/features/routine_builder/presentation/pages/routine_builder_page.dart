import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_add_spot_bottom_sheet.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/routine_day_carousel.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

/// Horizontal padding for routine builder content; use for header and alignment of actions.
const double _kPageHorizontalPadding = 24;

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

class _RoutineBuilderView extends StatelessWidget {
  const _RoutineBuilderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<RoutineBuilderBloc, RoutineBuilderState>(
          listenWhen: (prev, curr) =>
              curr.pendingSpotToAddFromMap != null &&
              prev.pendingSpotToAddFromMap != curr.pendingSpotToAddFromMap,
          listener: (context, state) {
            final spot = state.pendingSpotToAddFromMap;
            if (spot == null) return;
            context
                .read<RoutineBuilderBloc>()
                .add(PendingSpotFromMapConsumed());
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _kPageHorizontalPadding,
                    16,
                    _kPageHorizontalPadding,
                    0,
                  ),
                  child: _buildHeader(
                    context,
                    trip: state.trip,
                    onNewRoutine: () => _openTripSheet(context),
                    onSave: state.trip != null ? () => _saveRoutine(context) : null,
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
                      spotsForDay: state.spotsForDay,
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _kPageHorizontalPadding,
                          ),
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
        text:
            'Tap the top-right + to create a trip routine, select your dates, and see day-by-day pages.',
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
  VoidCallback? onSave,
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
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Save',
            onPressed: onSave,
            style: IconButton.styleFrom(
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          _RoutineMoreButton(
            onEdit: onEdit!,
            onDelete: onDelete!,
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Routine',
            onPressed: onNewRoutine,
            style: IconButton.styleFrom(
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.only(left: 8, right: 0),
            ),
          ),
      ],
    ),
  );
}

void _saveRoutine(BuildContext context) {
  // TODO: Persist current trip and spots (e.g. dispatch SaveRoutine to bloc or call repo).
}

/// More (⋮) button that opens an iOS-style liquid glass menu with Edit and Delete.
class _RoutineMoreButton extends StatelessWidget {
  const _RoutineMoreButton({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const double _menuRadius = 20;
  static const double _menuWidth = 160;
  static const double _menuGap = 6;

  void _openGlassMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final top = position.dy + size.height + _menuGap;
    final right = position.dx + size.width;
    final left = right - _menuWidth;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => _LiquidGlassMenu(
        left: left,
        top: top,
        width: _menuWidth,
        borderRadius: _menuRadius,
        onEdit: () {
          Navigator.of(ctx).pop();
          onEdit();
        },
        onDelete: () {
          Navigator.of(ctx).pop();
          onDelete();
        },
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert),
      onPressed: () => _openGlassMenu(context),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.only(left: 8, right: 0),
      ),
    );
  }
}

/// iOS-style liquid glass popup: blur + light transparent tint, rounded corners.
class _LiquidGlassMenu extends StatelessWidget {
  const _LiquidGlassMenu({
    required this.left,
    required this.top,
    required this.width,
    required this.borderRadius,
    required this.onEdit,
    required this.onDelete,
    required this.onDismiss,
  });

  final double left;
  final double top;
  final double width;
  final double borderRadius;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDismiss;

  static const double _blurSigma = 24;
  static const double _glassTintOpacity = 0.18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tintColor = isDark ? Colors.white : Colors.white;
    final tint = tintColor.withValues(alpha: _glassTintOpacity);

    return Stack(
      children: [
        GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassMenuItem(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        iconColor: theme.colorScheme.onSurface,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        onTap: onEdit,
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.08),
                      ),
                      _GlassMenuItem(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        iconColor: theme.colorScheme.error,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassMenuItem extends StatelessWidget {
  const _GlassMenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textStyle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          child: Text('Delete',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
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
