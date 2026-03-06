import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/constants/layout_constants.dart';
import 'package:triftly/core/helpers/helpers.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/features/routine_builder/data/default_spots.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_add_spot_bottom_sheet.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_edit_day_metadata_bottom_sheet.dart';

/// One swipeable page per day of the trip (stateless).
class RoutineDayPage extends StatelessWidget {
  const RoutineDayPage({
    super.key,
    required this.dayIndex,
    required this.date,
    required this.totalDays,
    this.addedSpots = const [],
  });

  final int dayIndex;
  final DateTime date;
  final int totalDays;
  /// All spots for this day (from bloc; may be default placeholders + user-added).
  final List<RoutineSpot> addedSpots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 6, 24, LayoutConstants.scrollPaddingBelowNavBar(context)),
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
              // Edit Day Metadata icon (pencil)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => RoutineDayEditDayMetadataBottomSheet.show(
                  context,
                  dayIndex: dayIndex,
                  date: date,
                ),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
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
              // Add Spot icon
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
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.add,
                        size: 20, color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ItineraryTimeline(
            spots: addedSpots.isEmpty ? kDefaultRoutineSpots : addedSpots,
            dayIndex: dayIndex,
            date: date,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

/// Vertical itinerary timeline: icon-in-circle on light gray line, white cards with title + time | location.
/// Tapping a card opens the add/edit spot sheet.
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
                        borderRadius: BorderRadius.circular(16),
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
