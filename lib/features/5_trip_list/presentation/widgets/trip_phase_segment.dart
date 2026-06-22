import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phases = TripPhase.values;

    return Container(
      height: 44,
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
                    color: isDark ? AppColors.surfaceCardDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                        blurRadius: 8,
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
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.primaryDark : AppColors.textTertiary,
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
                                      ? AppColors.primaryMuted
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  borderRadius: BorderRadius.circular(AppRadii.pill),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.primaryDark : AppColors.textTertiary,
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

extension TripPhaseIndex on TripPhase {
  int get index {
    switch (this) {
      case TripPhase.inProgress:
        return 0;
      case TripPhase.upcoming:
        return 1;
      case TripPhase.completed:
        return 2;
    }
  }
}
