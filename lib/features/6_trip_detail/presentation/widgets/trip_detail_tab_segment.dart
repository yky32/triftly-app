import 'package:flutter/material.dart';
import '../../../../core/widgets/triftly_segment_control.dart';

/// Plan · Spend · Map — same tones as Active · Upcoming · Done.
class TripDetailTabSegment extends StatelessWidget {
  const TripDetailTabSegment({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const items = [
    SegmentItem(
      label: 'Plan',
      iconFilled: Icons.event_note_rounded,
      iconOutlined: Icons.event_note_outlined,
      toneIndex: 0,
    ),
    SegmentItem(
      label: 'Spend',
      iconFilled: Icons.payments_rounded,
      iconOutlined: Icons.payments_outlined,
      toneIndex: 1,
    ),
    SegmentItem(
      label: 'Map',
      iconFilled: Icons.map_rounded,
      iconOutlined: Icons.map_outlined,
      toneIndex: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TriftlySegmentControl(
      items: items,
      selectedIndex: selectedIndex,
      onChanged: onChanged,
    );
  }
}
