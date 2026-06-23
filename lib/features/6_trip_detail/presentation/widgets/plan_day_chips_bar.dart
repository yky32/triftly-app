import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Horizontal day picker — pinned under Plan · Spend · Map on the Plan tab.
class PlanDayChipsBar extends StatelessWidget {
  const PlanDayChipsBar({
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
    super.key,
  });

  final List<TripDay> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  static const _padBottom = AppSpacing.sm * 0.85;

  /// Height below the Plan · Spend · Map segment.
  static const chipsExtent = 55.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: chipsExtent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          _padBottom,
        ),
        child: Align(
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < days.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        PlanDayChip(
                          day: days[i],
                          isSelected: i == selectedIndex,
                          onSelected: () => onDaySelected(i),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PlanDayChip extends StatelessWidget {
  const PlanDayChip({
    required this.day,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final TripDay day;
  final bool isSelected;
  final VoidCallback onSelected;

  IconData? get _icon => switch (day.title) {
        'Arrival' => Icons.flight_land_rounded,
        'Departure' => Icons.flight_takeoff_rounded,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final icon = _icon;
    final fg = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    if (icon != null) {
      return FilterChip(
        label: Icon(icon, size: 18, color: fg),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        labelPadding: EdgeInsets.zero,
        labelStyle: TextStyle(color: fg),
      );
    }

    return FilterChip(
      label: Text(day.displayTitle),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: fg,
      ),
    );
  }
}
