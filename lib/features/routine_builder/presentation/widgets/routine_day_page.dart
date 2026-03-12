import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/constants/layout_constants.dart';
import 'package:triftly/core/helpers/helpers.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_add_spot_bottom_sheet.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_edit_day_metadata_bottom_sheet.dart';

/// Horizontal padding for day content; match routine builder for right-edge alignment.
const double _kDayHorizontalPadding = 24;

/// One swipeable page per day of the trip (stateless).
class RoutineDayPage extends StatelessWidget {
  const RoutineDayPage({
    super.key,
    required this.dayIndex,
    required this.date,
    required this.totalDays,
    this.addedSpots = const [],
    this.dayLabel,
  });

  final int dayIndex;
  final DateTime date;
  final int totalDays;
  /// All spots for this day (from bloc; may be default placeholders + user-added).
  final List<RoutineSpot> addedSpots;
  /// Optional custom label (e.g. "Arrival"). When null, header shows "Day N".
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _kDayHorizontalPadding,
        6,
        _kDayHorizontalPadding,
        LayoutConstants.scrollPaddingBelowNavBar(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Day ${dayIndex + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateHelpers.formatWeekdayAndDate(date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // Edit Day Metadata icon (pencil) — zero padding so press overlay is centered on icon
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => RoutineDayEditDayMetadataBottomSheet.show(
                  context,
                  dayIndex: dayIndex,
                  date: date,
                  initialLabel: dayLabel,
                ),
                tooltip: 'Edit day name',
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          if (dayLabel != null && dayLabel!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dayLabel!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Spots & Activities',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Add + More aligned to the right as a group
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add Spot icon — same 40×40 size as header actions for alignment
                  Material(
                    color: AppColors.fogGray,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        final spot = await RoutineDayAddSpotBottomSheet.show(
                          context,
                          dayIndex: dayIndex,
                          date: date,
                        );
                        if (spot != null && context.mounted) {
                          context.read<RoutineBuilderBloc>().add(
                                SpotAdded(dayIndex: dayIndex, spot: spot),
                              );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                      splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(Icons.add,
                              size: 20, color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ),
                  // More — Select / Delete All (liquid glass menu)
                  _DaySpotsMoreButton(
                    dayIndex: dayIndex,
                    date: date,
                    dayLabel: dayLabel,
                    spotCount: addedSpots.length,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ItineraryTimeline(
            spots: addedSpots,
            dayIndex: dayIndex,
            date: date,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

/// More (⋮) button next to Add; same menu behavior as routine builder (Edit, Delete).
class _DaySpotsMoreButton extends StatelessWidget {
  const _DaySpotsMoreButton({
    required this.dayIndex,
    required this.date,
    this.dayLabel,
    required this.spotCount,
  });

  final int dayIndex;
  final DateTime date;
  final String? dayLabel;
  final int spotCount;

  static const double _menuGap = 10;
  static const double _menuRadius = 16;
  static const double _menuElevation = 12;

  Future<void> _showMenu(BuildContext context) async {
    final theme = Theme.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final anchorTop = position.dy + size.height + _menuGap;
    final buttonRect = RelativeRect.fromLTRB(
      position.dx,
      anchorTop,
      position.dx + size.width,
      anchorTop + 1,
    );

    final result = await showMenu<String>(
      context: context,
      position: buttonRect,
      elevation: _menuElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_menuRadius),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerHigh
          : AppColors.cloudWhite,
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 22, color: theme.colorScheme.onSurface),
              const SizedBox(width: 14),
              Text('Edit', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 22, color: theme.colorScheme.error),
              const SizedBox(width: 14),
              Text('Delete', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
            ],
          ),
        ),
      ],
    );
    if (!context.mounted) return;
    if (result == 'edit') {
      RoutineDayEditDayMetadataBottomSheet.show(
        context,
        dayIndex: dayIndex,
        date: date,
        initialLabel: dayLabel,
      );
    }
    if (result == 'delete') {
      await _confirmDeleteAllSpots(context, dayIndex: dayIndex, spotCount: spotCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showMenu(context),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

Future<void> _confirmDeleteAllSpots(
  BuildContext context, {
  required int dayIndex,
  required int spotCount,
}) async {
  if (spotCount == 0) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete all spots?'),
      content: Text(
        'Remove all $spotCount spot${spotCount == 1 ? '' : 's'} from this day?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Delete All',
            style: TextStyle(color: Theme.of(ctx).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    context.read<RoutineBuilderBloc>().add(SpotsClearedForDay(dayIndex));
  }
}

Future<void> _confirmRemoveSpot(
  BuildContext context, {
  required int dayIndex,
  required int spotIndex,
  required String spotTitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove spot?'),
      content: Text(
        'Remove "${spotTitle.length > 40 ? '${spotTitle.substring(0, 40)}...' : spotTitle}" from this day?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Remove',
            style: TextStyle(color: Theme.of(ctx).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    context.read<RoutineBuilderBloc>().add(
          SpotRemoved(dayIndex: dayIndex, spotIndex: spotIndex),
        );
  }
}

/// Vertical itinerary timeline: icon-in-circle on light gray line, white cards with title + time | location.
/// Tapping a card opens the add/edit spot sheet; long-press shows remove option.
class _ItineraryTimeline extends StatelessWidget {
  const _ItineraryTimeline({
    required this.spots,
    required this.dayIndex,
    required this.date,
    required this.theme,
  });

  final List<RoutineSpot> spots;
  final int dayIndex;
  final DateTime date;
  final ThemeData theme;

  static const double _lineWidth = 2;
  static const double _circleSize = 28;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      final height = MediaQuery.sizeOf(context).height * 0.5;
      return SizedBox(
        height: height,
        child: Center(
          child: _DayEmptyState(theme: theme),
        ),
      );
    }

    final lineColor = AppColors.mistGray.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < spots.length; i++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    width: _circleSize + 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: _circleSize,
                          height: _circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: spots[i].color.withValues(alpha: 0.18),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow
                                    .withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            spots[i].icon,
                            size: 16,
                            color: spots[i].color,
                          ),
                        ),
                        if (i == spots.length - 1) ...[
                          const SizedBox(height: 6),
                          Text(
                            'End',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mistGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (i < spots.length - 1) ...[
                          const SizedBox(height: 4),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: _lineWidth,
                                color: lineColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () async {
                          final saved = await RoutineDayAddSpotBottomSheet.show(
                            context,
                            dayIndex: dayIndex,
                            date: date,
                            initialSpot: spots[i],
                          );
                          if (saved != null && context.mounted) {
                            context.read<RoutineBuilderBloc>().add(
                                  SpotUpdated(
                                    dayIndex: dayIndex,
                                    spotIndex: i,
                                    spot: saved,
                                  ),
                                );
                          }
                        },
                        onLongPress: () => _confirmRemoveSpot(
                          context,
                          dayIndex: dayIndex,
                          spotIndex: i,
                          spotTitle: spots[i].title,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow
                                    .withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                spots[i].title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                spots[i].description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 14,
                                    color: AppColors.mistGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${spots[i].startTime} – ${spots[i].endTime}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.mistGray,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.mistGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      spots[i].location,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.mistGray,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Empty state when the day has no spots; style aligned with routine_builder empty notice.
class _DayEmptyState extends StatelessWidget {
  const _DayEmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_location_alt_outlined,
            size: 44,
            color: colorScheme.primary.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 16),
          Text(
            "Tap 'Add' to start your trip",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
