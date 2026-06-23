import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'triftly_motion.dart';

/// Travel-themed time picker — bottom sheet with drum wheels and quick presets.
class TripTimePickerSheet extends StatefulWidget {
  const TripTimePickerSheet({
    required this.initialTime,
    this.accentColor,
    this.title = 'Departure time',
    super.key,
  });

  final TimeOfDay initialTime;
  final Color? accentColor;
  final String title;

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    Color? accentColor,
    String title = 'Departure time',
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => TripTimePickerSheet(
        initialTime: initialTime,
        accentColor: accentColor,
        title: title,
      ),
    );
  }

  @override
  State<TripTimePickerSheet> createState() => _TripTimePickerSheetState();
}

class _TripTimePickerSheetState extends State<TripTimePickerSheet> {
  static const _quickTimes = [
    (8, 0),
    (12, 0),
    (15, 0),
    (18, 0),
  ];

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  late int _hour12;
  late int _minute;
  late bool _isPm;

  Color get _accent => widget.accentColor ?? AppColors.primary;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime;
    _hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    _minute = t.minute;
    _isPm = t.period == DayPeriod.pm;
    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay get _selectedTime {
    var hour24 = _hour12 % 12;
    if (_isPm) hour24 += 12;
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(_selectedTime);
  }

  void _applyQuick(int hour24, int minute) {
    HapticFeedback.selectionClick();
    setState(() {
      _isPm = hour24 >= 12;
      final h12 = hour24 % 12;
      _hour12 = h12 == 0 ? 12 : h12;
      _minute = minute;
      _hourController.jumpToItem(_hour12 - 1);
      _minuteController.jumpToItem(_minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCardDark : AppColors.surface,
        borderRadius: AppRadii.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(Icons.schedule_rounded, size: 20, color: _accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Scroll or tap a preset',
                        style: TextStyle(fontSize: 13, color: tertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _TimePreview(
              hour12: _hour12,
              minute: _minute,
              isPm: _isPm,
              accent: _accent,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _PeriodPill(
                  label: 'AM',
                  selected: !_isPm,
                  accent: _accent,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isPm = false);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _PeriodPill(
                  label: 'PM',
                  selected: _isPm,
                  accent: _accent,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isPm = true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 148,
            child: Row(
              children: [
                Expanded(
                  child: _DrumColumn(
                    controller: _hourController,
                    selectedIndex: _hour12 - 1,
                    itemCount: 12,
                    label: (i) => '${i + 1}',
                    accent: _accent,
                    onSelected: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _hour12 = i + 1);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: tertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: _DrumColumn(
                    controller: _minuteController,
                    selectedIndex: _minute,
                    itemCount: 60,
                    label: (i) => i.toString().padLeft(2, '0'),
                    accent: _accent,
                    onSelected: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _minute = i);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: _quickTimes.map((t) {
                final hour24 = t.$1;
                final minute = t.$2;
                final label = _quickLabel(hour24);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: t == _quickTimes.last ? 0 : AppSpacing.sm),
                    child: Pressable(
                      onTap: () => _applyQuick(hour24, minute),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl + bottomInset),
            child: FilledButton(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Set time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  String _quickLabel(int hour24) {
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final h = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$h:00 $period';
  }
}

class _TimePreview extends StatelessWidget {
  const _TimePreview({
    required this.hour12,
    required this.minute,
    required this.isPm,
    required this.accent,
  });

  final int hour12;
  final int minute;
  final bool isPm;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [accent.withValues(alpha: 0.35), const Color(0xFF1E1E20)]
              : [accent.withValues(alpha: 0.12), const Color(0xFFF7F5F2)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$hour12:${minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              height: 1,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              isPm ? 'PM' : 'AM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected ? accent : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrumColumn extends StatelessWidget {
  const _DrumColumn({
    required this.controller,
    required this.selectedIndex,
    required this.itemCount,
    required this.label,
    required this.accent,
    required this.onSelected,
  });

  final FixedExtentScrollController controller;
  final int selectedIndex;
  final int itemCount;
  final String Function(int index) label;
  final Color accent;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      perspective: 0.004,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = index == selectedIndex;
          return Center(
            child: Text(
              label(index),
              style: TextStyle(
                fontSize: isSelected ? 24 : 18,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? accent
                    : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );
        },
      ),
    );
  }
}
