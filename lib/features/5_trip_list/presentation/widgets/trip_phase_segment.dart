import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class _PhaseStyle {
  const _PhaseStyle({
    required this.pillLight,
    required this.pillDark,
    required this.accent,
    required this.accentDark,
    required this.badgeLight,
    required this.badgeDark,
  });

  final Color pillLight;
  final Color pillDark;
  final Color accent;
  final Color accentDark;
  final Color badgeLight;
  final Color badgeDark;

  Color pill(bool isDark) => isDark ? pillDark : pillLight;
  Color foreground(bool isDark) => isDark ? accentDark : accent;
  Color badge(bool isDark) => isDark ? badgeDark : badgeLight;
}

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

  static final _styles = {
    TripPhase.inProgress: _PhaseStyle(
      pillLight: Color(0xFFFFF7ED),
      pillDark: Color(0xFF431407),
      accent: Color(0xFFC2410C),
      accentDark: Color(0xFFFDBA74),
      badgeLight: Color(0xFFFFEDD5),
      badgeDark: Color(0xFF7C2D12),
    ),
    TripPhase.upcoming: _PhaseStyle(
      pillLight: Color(0xFFF0FDF4),
      pillDark: Color(0xFF052E16),
      accent: Color(0xFF15803D),
      accentDark: Color(0xFF86EFAC),
      badgeLight: Color(0xFFDCFCE7),
      badgeDark: Color(0xFF14532D),
    ),
    TripPhase.completed: _PhaseStyle(
      pillLight: Color(0xFFF5F5F4),
      pillDark: Color(0xFF292524),
      accent: Color(0xFF78716C),
      accentDark: Color(0xFFA8A29E),
      badgeLight: Color(0xFFE7E5E4),
      badgeDark: Color(0xFF44403C),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phases = TripPhase.values;
    final selectedStyle = _styles[selected]!;

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
                  final style = _styles[phase]!;
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
