import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/segment_style.dart';
import '../../../../core/widgets/triftly_segment_control.dart';

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

  static const _labels = {
    TripPhase.inProgress: 'Active',
    TripPhase.upcoming: 'Upcoming',
    TripPhase.completed: 'Done',
  };

  static const _icons = {
    TripPhase.inProgress: Icons.flight_takeoff_rounded,
    TripPhase.upcoming: Icons.event_rounded,
    TripPhase.completed: Icons.check_circle_rounded,
  };

  static const _iconsOutlined = {
    TripPhase.inProgress: Icons.flight_takeoff_outlined,
    TripPhase.upcoming: Icons.event_outlined,
    TripPhase.completed: Icons.check_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final items = tripPhaseSegmentOrder.map((phase) {
      return SegmentItem(
        label: _labels[phase]!,
        iconFilled: _icons[phase]!,
        iconOutlined: _iconsOutlined[phase]!,
        toneIndex: phase.toneIndex,
        count: counts[phase],
        showLiveIndicator: phase == TripPhase.inProgress,
      );
    }).toList();

    return TriftlySegmentControl(
      items: items,
      selectedIndex: selected.segmentIndex,
      onChanged: (index) => onChanged(tripPhaseSegmentOrder[index]),
    );
  }
}
