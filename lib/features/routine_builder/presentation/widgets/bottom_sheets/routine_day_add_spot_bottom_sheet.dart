import 'package:flutter/material.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet for adding a spot to the day (triggered by the "Add Spot" icon).
class RoutineDayAddSpotBottomSheet extends StatelessWidget {
  const RoutineDayAddSpotBottomSheet({
    super.key,
    this.dayIndex,
    this.date,
  });

  final int? dayIndex;
  final DateTime? date;

  static Future<void> show(
    BuildContext context, {
    int? dayIndex,
    DateTime? date,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutineDayAddSpotBottomSheet(
        dayIndex: dayIndex,
        date: date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit day',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
