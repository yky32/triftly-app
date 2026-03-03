import 'package:flutter/material.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/widgets/bottom_sheets/routine_builder_bottom_sheet/routine_builder_bottom_sheet.dart';

class RoutineBuilderPage extends StatelessWidget {
  const RoutineBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  context.l10n.page_routine_builder,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result =
                        await RoutineBuilderBottomSheet.show(context);
                    if (result != null && context.mounted) {
                      // TODO: create routine with result.startDate, result.endDate, result.daysOfTrip
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
