import 'package:flutter/material.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet for adding a spot to the day (triggered by the "Add Spot" icon).
/// Collects all [RoutineSpot] fields and returns the new spot on save.
class RoutineDayAddSpotBottomSheet extends StatefulWidget {
  const RoutineDayAddSpotBottomSheet({
    super.key,
    this.dayIndex,
    this.date,
    this.initialSpot,
  });

  final int? dayIndex;
  final DateTime? date;
  final RoutineSpot? initialSpot;

  static Future<RoutineSpot?> show(
    BuildContext context, {
    int? dayIndex,
    DateTime? date,
    RoutineSpot? initialSpot,
  }) {
    return showAppModalBottomSheet<RoutineSpot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutineDayAddSpotBottomSheet(
        dayIndex: dayIndex,
        date: date,
        initialSpot: initialSpot,
      ),
    );
  }

  @override
  State<RoutineDayAddSpotBottomSheet> createState() =>
      _RoutineDayAddSpotBottomSheetState();
}

class _RoutineDayAddSpotBottomSheetState
    extends State<RoutineDayAddSpotBottomSheet> {
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  static const List<IconData> _iconOptions = [
    Icons.coffee,
    Icons.train,
    Icons.museum_outlined,
    Icons.restaurant_outlined,
    Icons.place_outlined,
    Icons.directions_car_outlined,
    Icons.flight_takeoff_rounded,
    Icons.shopping_bag_outlined,
  ];

  static const List<Color> _colorOptions = [
    Color(0xFFE65100),
    Color(0xFF2E7D32),
    Color(0xFF0277BD),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
    Color(0xFF00838F),
  ];

  IconData _selectedIcon = Icons.place_outlined;
  Color _selectedColor = const Color(0xFF0277BD);

  @override
  void initState() {
    super.initState();
    final s = widget.initialSpot;
    _startTimeController = TextEditingController(text: s?.startTime ?? '');
    _endTimeController = TextEditingController(text: s?.endTime ?? '');
    _titleController = TextEditingController(text: s?.title ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _locationController = TextEditingController(text: s?.location ?? '');
    if (s != null) {
      _selectedIcon = s.icon;
      _selectedColor = s.color;
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSave() {
    final spot = RoutineSpot(
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
    );
    Navigator.of(context).pop(spot);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.initialSpot != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit spot' : 'Add spot',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel(context, 'Start time'),
            const SizedBox(height: 4),
            TextField(
              controller: _startTimeController,
              decoration: _inputDecoration(context, 'e.g. 8:30 AM'),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'End time'),
            const SizedBox(height: 4),
            TextField(
              controller: _endTimeController,
              decoration: _inputDecoration(context, 'e.g. 9:30 AM'),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'Title'),
            const SizedBox(height: 4),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(context, 'e.g. Morning Coffee'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'Description'),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration(context, 'Short description'),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'Location'),
            const SizedBox(height: 4),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration(context, 'Address or place name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            _buildLabel(context, 'Icon'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((icon) {
                final selected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? _selectedColor.withValues(alpha: 0.2)
                          : AppColors.fogGray,
                      border: selected
                          ? Border.all(color: _selectedColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected ? _selectedColor : AppColors.mistGray,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildLabel(context, 'Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final selected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: selected
                          ? Border.all(color: colorScheme.onSurface, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _onSave,
              child: Text(isEditing ? 'Save changes' : 'Add spot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
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
