import 'package:flutter/material.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet for editing a single day item in the routine.
class RoutineDayItemBottomSheet extends StatelessWidget {
  const RoutineDayItemBottomSheet({
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
      builder: (context) => RoutineDayItemBottomSheet(
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
