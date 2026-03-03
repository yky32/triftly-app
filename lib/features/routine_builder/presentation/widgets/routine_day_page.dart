import 'package:flutter/material.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_day_item_bottom_sheet.dart';

/// One swipeable page per day of the trip (stateless).
class RoutineDayPage extends StatelessWidget {
  const RoutineDayPage({
    super.key,
    required this.dayIndex,
    required this.date,
    required this.totalDays,
  });

  final int dayIndex;
  final DateTime date;
  final int totalDays;

  static const List<_PlaceholderSpot> _placeholderSpots = [
    _PlaceholderSpot(
      time: '8:30 AM',
      title: 'Morning Coffee at Ikigai Arabica',
      description: 'Start the day with a specialty pour-over and light pastry.',
      location: '1-1-3 Jinnan, Shibuya-ku, Tokyo',
      icon: Icons.coffee,
      color: Color(0xFFE65100),
    ),
    _PlaceholderSpot(
      time: '10:00 AM',
      title: 'Tokyo Station → Odawara Station',
      description: 'JR Tokaido Line. Reserved seat recommended for Hakone direction.',
      location: '1-9-1 Marunouchi, Chiyoda-ku, Tokyo',
      icon: Icons.train,
      color: Color(0xFF2E7D32),
    ),
    _PlaceholderSpot(
      time: '12:00 PM',
      title: 'Hakone Open-Air Museum',
      description: 'Art and nature. Allow 2–3 hours. Café on site.',
      location: '1121 Ninotaira, Hakone-machi',
      icon: Icons.museum_outlined,
      color: Color(0xFF0277BD),
    ),
    _PlaceholderSpot(
      time: '5:00 PM',
      title: 'Odawara Station → Shibuya Station',
      description: 'Return leg. Direct trains available.',
      location: '1-1-1 Odawara, Kanagawa',
      icon: Icons.train,
      color: Color(0xFF2E7D32),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  '${_formatWeekday(date)}, ${_formatDate(date)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
              Material(
                color: AppColors.fogGray,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => RoutineDayItemBottomSheet.show(
                    context,
                    dayIndex: dayIndex,
                    date: date,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.add, size: 20, color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ItineraryTimeline(
            spots: _placeholderSpots,
            theme: theme,
          ),
        ],
      ),
    );
  }

  String _formatWeekday(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[d.weekday - 1];
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _PlaceholderSpot {
  const _PlaceholderSpot({
    required this.time,
    required this.title,
    required this.description,
    required this.location,
    required this.icon,
    required this.color,
  });
  final String time;
  final String title;
  final String description;
  final String location;
  final IconData icon;
  final Color color;
}

/// Vertical itinerary timeline: icon-in-circle on light gray line, white cards with title + time | location.
class _ItineraryTimeline extends StatelessWidget {
  const _ItineraryTimeline({
    required this.spots,
    required this.theme,
  });

  final List<_PlaceholderSpot> spots;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  width: _circleSize + 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: spots[i].color,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
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
                      if (i < spots.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Center(
                            child: Container(
                              width: _lineWidth,
                              height: 48,
                              color: lineColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.fogGray.withValues(alpha: 0.8),
                        width: 1,
                      ),
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
                              spots[i].time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mistGray,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('|', style: TextStyle(color: AppColors.mistGray, fontSize: 12)),
                            ),
                            Expanded(
                              child: Row(
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
