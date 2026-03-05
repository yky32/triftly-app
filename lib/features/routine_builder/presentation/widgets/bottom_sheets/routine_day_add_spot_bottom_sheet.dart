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

  /// Parses "8:30 AM" / "12:00 PM" style string to [TimeOfDay]. Returns null if invalid.
  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length < 2) return null;
    final timePart = parts[0];
    final ampm = parts[1].toUpperCase();
    final hm = timePart.split(':');
    if (hm.length < 2) return null;
    final hour = int.tryParse(hm[0]);
    final minute = int.tryParse(hm[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 12 || minute < 0 || minute > 59) return null;
    var h = hour;
    if (ampm == 'PM' && hour != 12) h = hour + 12;
    if (ampm == 'AM' && hour == 12) h = 0;
    return TimeOfDay(hour: h, minute: minute);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }

  Future<void> _pickTime(
    BuildContext context, {
    required TextEditingController controller,
    required TimeOfDay initial,
  }) async {
    final picked = await _TimePickerSheet.show(context, initialTime: initial);
    if (picked != null && context.mounted) {
      controller.text = _formatTime(picked);
      setState(() {});
    }
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
            const BottomSheetDragHandle(),
            Text(
              isEditing ? 'Edit spot' : 'Add spot',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel(context, 'Time', icon: Icons.schedule_rounded),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerField(
                    context,
                    controller: _startTimeController,
                    hint: 'From',
                    defaultTime: const TimeOfDay(hour: 8, minute: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePickerField(
                    context,
                    controller: _endTimeController,
                    hint: 'To',
                    defaultTime: const TimeOfDay(hour: 9, minute: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'Title', icon: Icons.short_text_rounded),
            const SizedBox(height: 4),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(context, 'e.g. Morning Coffee'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'Description', icon: Icons.notes_rounded),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration(context, 'Short description'),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            _buildLabel(context, 'Location', icon: Icons.location_on_outlined),
            const SizedBox(height: 4),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration(context, 'Address or place name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            _buildLabel(context, 'Icon', icon: Icons.category_outlined),
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
            _buildLabel(context, 'Color', icon: Icons.palette_outlined),
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

  Widget _buildLabel(BuildContext context, String text, {IconData? icon}) {
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

  Widget _buildTimePickerField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required TimeOfDay defaultTime,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasValue = controller.text.trim().isNotEmpty;
    final initial = _parseTime(controller.text) ?? defaultTime;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickTime(context, controller: controller, initial: initial),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 22,
                color: hasValue
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? controller.text : hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasValue
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
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

/// Custom time picker sheet: wheel picker + presets + Done (benchmarked from reference UX).
class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  static Future<TimeOfDay?> show(BuildContext context, {required TimeOfDay initialTime}) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimePickerSheet(initialTime: initialTime),
    );
  }

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  static const double _itemExtent = 48.0;
  static const int _visibleItems = 5;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _ampmController;

  late int _initialHourIndex;
  late int _initialMinuteIndex;
  late int _initialAmpmIndex;

  int _indexFromOffset(ScrollController c, int count, int fallback) {
    if (!c.hasClients) return fallback;
    return (c.offset / _itemExtent).round().clamp(0, count - 1);
  }

  int get _hourIndex => _indexFromOffset(_hourController, 12, _initialHourIndex);
  int get _minuteIndex => _indexFromOffset(_minuteController, 60, _initialMinuteIndex);
  int get _ampmIndex => _indexFromOffset(_ampmController, 2, _initialAmpmIndex);

  TimeOfDay get _currentTime {
    final hour12 = _hourIndex + 1;
    final minute = _minuteIndex;
    final isAm = _ampmIndex == 0;
    final hour24 = hour12 == 12
        ? (isAm ? 0 : 12)
        : (isAm ? hour12 : hour12 + 12);
    return TimeOfDay(hour: hour24, minute: minute);
  }

  void _selectPreset(TimeOfDay t) {
    final hour12 = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final isAm = t.hour < 12;
    _hourController.jumpToItem(hour12 - 1);
    _minuteController.jumpToItem(t.minute);
    _ampmController.jumpToItem(isAm ? 0 : 1);
    setState(() {});
  }

  bool _presetMatches(TimeOfDay preset) {
    final c = _currentTime;
    return c.hour == preset.hour && c.minute == preset.minute;
  }

  void _onScroll() => setState(() {});

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime;
    final hour12 = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final isAm = t.hour < 12;
    _initialHourIndex = hour12 - 1;
    _initialMinuteIndex = t.minute;
    _initialAmpmIndex = isAm ? 0 : 1;
    _hourController = FixedExtentScrollController(initialItem: _initialHourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _initialMinuteIndex);
    _ampmController = FixedExtentScrollController(initialItem: _initialAmpmIndex);
    _hourController.addListener(_onScroll);
    _minuteController.addListener(_onScroll);
    _ampmController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _hourController.removeListener(_onScroll);
    _minuteController.removeListener(_onScroll);
    _ampmController.removeListener(_onScroll);
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    const wheelHeight = _itemExtent * _visibleItems;

    final presets = [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 12, minute: 0),
      TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 18, minute: 0),
    ];
    final presetLabels = ['9 am', '12 pm', '4 pm', '6 pm'];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetDragHandle(),
          Text(
            'Time',
            style: theme.textTheme.titleLarge?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: wheelHeight,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: _itemExtent,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: wheelHeight,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: _itemExtent,
                        diameterRatio: 1.2,
                        perspective: 0.003,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (_) => setState(() {}),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 12,
                          builder: (context, index) {
                            final value = index + 1;
                            final selected = _hourIndex == index;
                            return Center(
                              child: Text(
                                '$value',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: selected ? onSurface : onSurfaceVariant.withValues(alpha: 0.5),
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ':',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: wheelHeight,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: _itemExtent,
                        diameterRatio: 1.2,
                        perspective: 0.003,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (_) => setState(() {}),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 60,
                          builder: (context, index) {
                            final selected = _minuteIndex == index;
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: selected ? onSurface : onSurfaceVariant.withValues(alpha: 0.5),
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      height: wheelHeight,
                      child: ListWheelScrollView.useDelegate(
                        controller: _ampmController,
                        itemExtent: _itemExtent,
                        diameterRatio: 1.2,
                        perspective: 0.003,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (_) => setState(() {}),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 2,
                          builder: (context, index) {
                            final value = index == 0 ? 'am' : 'pm';
                            final selected = _ampmIndex == index;
                            return Center(
                              child: Text(
                                value,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: selected ? onSurface : onSurfaceVariant.withValues(alpha: 0.5),
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Presets',
              style: theme.textTheme.labelMedium?.copyWith(
                color: onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final preset = presets[i];
              final label = presetLabels[i];
              final selected = _presetMatches(preset);
              return Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: OutlinedButton(
                  onPressed: () => _selectPreset(preset),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: selected ? primary : onSurfaceVariant,
                    side: BorderSide(color: selected ? primary : onSurfaceVariant.withValues(alpha: 0.5)),
                    backgroundColor: selected ? primary.withValues(alpha: 0.08) : Colors.transparent,
                  ),
                  child: Text(label),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_currentTime),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
