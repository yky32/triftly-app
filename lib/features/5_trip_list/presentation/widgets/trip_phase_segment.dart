import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'trip_phase_style.dart';

/// Segmented control to filter trips by phase.
class TripPhaseSegment extends StatelessWidget {
  const TripPhaseSegment({
    required this.selected,
    required this.counts,
    required this.onChanged,
    super.key,
  });

  final TripPhase selected;
  final Map<TripPhase, int> counts;
  final ValueChanged<TripPhase> onChanged;

  static final _labels = {
    TripPhase.inProgress: 'Active',
    TripPhase.upcoming: 'Upcoming',
    TripPhase.completed: 'Done',
  };

  static final _icons = {
    TripPhase.inProgress: Icons.flight_takeoff_rounded,
    TripPhase.upcoming: Icons.event_rounded,
    TripPhase.completed: Icons.check_circle_rounded,
  };

  static final _iconsOutlined = {
    TripPhase.inProgress: Icons.flight_takeoff_outlined,
    TripPhase.upcoming: Icons.event_outlined,
    TripPhase.completed: Icons.check_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phases = TripPhase.values;
    final selectedStyle = TripPhaseStyle.of(selected);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / phases.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: selected.index * slotWidth,
                top: 0,
                bottom: 0,
                width: slotWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selectedStyle.pill(isDark),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: [
                      BoxShadow(
                        color: selectedStyle.foreground(isDark).withValues(alpha: isDark ? 0.2 : 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: phases.map((phase) {
                  final isSelected = phase == selected;
                  final count = counts[phase] ?? 0;
                  final style = TripPhaseStyle.of(phase);
                  final fg = isSelected ? style.foreground(isDark) : AppColors.textTertiary;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (phase == selected) return;
                        HapticFeedback.selectionClick();
                        onChanged(phase);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? _icons[phase]! : _iconsOutlined[phase]!,
                              size: 16,
                              color: fg,
                            ),
                            const SizedBox(width: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: fg,
                              ),
                              child: Text(_labels[phase]!),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 5),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? style.badge(isDark)
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  borderRadius: BorderRadius.circular(AppRadii.pill),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: fg,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
