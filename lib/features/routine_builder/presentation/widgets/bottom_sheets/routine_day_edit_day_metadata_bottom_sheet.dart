import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/helpers/helpers.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet for editing day metadata (custom day name). Triggered by the pencil icon or More → Edit.
/// [routineBuilderBloc] must be passed from the caller's context (modal overlay context has no access to it).
class RoutineDayEditDayMetadataBottomSheet extends StatelessWidget {
  const RoutineDayEditDayMetadataBottomSheet({
    super.key,
    required this.dayIndex,
    required this.date,
    required this.routineBuilderBloc,
    required this.labelController,
  });

  final int dayIndex;
  final DateTime date;
  final RoutineBuilderBloc routineBuilderBloc;
  final TextEditingController labelController;

  static Future<void> show(
    BuildContext context, {
    required int dayIndex,
    required DateTime date,
    String? initialLabel,
  }) {
    final bloc = context.read<RoutineBuilderBloc>();
    final controller = TextEditingController(text: initialLabel ?? '');
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoutineDayEditDayMetadataBottomSheet(
        dayIndex: dayIndex,
        date: date,
        routineBuilderBloc: bloc,
        labelController: controller,
      ),
    ).whenComplete(() {
      // Defer dispose until after the route is fully removed and the widget
      // tree has finished teardown (avoids "used after being disposed").
      void disposeController() => controller.dispose();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          disposeController();
        });
      });
    });
  }

  void _onSave(BuildContext context) {
    final label = labelController.text.trim();
    routineBuilderBloc.add(
      DayLabelUpdated(dayIndex: dayIndex, label: label.isEmpty ? null : label),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: TapToUnfocus(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BottomSheetDragHandle(),
            Text(
              'Edit day',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateHelpers.formatWeekdayAndDate(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel(context, 'Day name', icon: Icons.label_outline_rounded),
            const SizedBox(height: 4),
            TextField(
              controller: labelController,
              decoration: _inputDecoration(context, 'e.g. Arrival, Beach day'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _onSave(context),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _onSave(context),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLabel(BuildContext context, String text, {IconData? icon}) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(color: color);
    if (icon == null) {
      return Text(text, style: labelStyle);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: labelStyle),
      ],
    );
  }

  static InputDecoration _inputDecoration(BuildContext context, String hint) {
    final colorScheme = Theme.of(context).colorScheme;
    final underline = colorScheme.onSurface.withValues(alpha: 0.2);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      border: InputBorder.none,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: underline),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      isDense: true,
    );
  }
}
