import 'package:flutter/material.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/3_routine_builder/models/routine_spot.dart';
import 'package:triftly/widgets/design/triftly_layout.dart';
import 'package:triftly/widgets/design/triftly_page_header.dart';

class TriftlyDayChip extends StatelessWidget {
  const TriftlyDayChip({
    super.key,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isToday = false,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TriftlyLayout.chipRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.driftTeal : AppColors.cloudWhite,
              borderRadius: BorderRadius.circular(TriftlyLayout.chipRadius),
              border: Border.all(
                color: selected
                    ? AppColors.driftTeal
                    : AppColors.fogGray.withValues(alpha: 0.9),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.driftTeal.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? Colors.white : AppColors.slate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.22)
                              : AppColors.tealMist.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Today',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.deepTeal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.mistGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TriftlySpotTimelineTile extends StatelessWidget {
  const TriftlySpotTimelineTile({
    super.key,
    required this.spot,
    required this.isFirst,
    required this.isLast,
    required this.onToggle,
  });

  final RoutineSpot spot;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = spot.isCompleted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.fogGray,
                    ),
                  ),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed
                          ? AppColors.driftTeal
                          : AppColors.cloudWhite,
                      border: Border.all(
                        color: completed
                            ? AppColors.driftTeal
                            : AppColors.mistGray,
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.fogGray,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: TriftlySurfaceCard(
                padding: const EdgeInsets.all(14),
                onTap: onToggle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: spot.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(spot.icon, color: spot.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: completed
                                  ? AppColors.mistGray
                                  : AppColors.slate,
                            ),
                          ),
                          if (spot.startTime.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${spot.startTime} – ${spot.endTime}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.driftTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (spot.location.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              spot.location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mistGray,
                              ),
                            ),
                          ],
                          if (spot.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              spot.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mistGray,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
