import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'triftly_motion.dart';

enum TripDatePickerMode { departure, returnDate }

/// Travel-themed date picker — bottom sheet with range highlight and quick durations.
class TripDatePickerSheet extends StatefulWidget {
  const TripDatePickerSheet({
    required this.mode,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.rangeStart,
    super.key,
  });

  final TripDatePickerMode mode;
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? rangeStart;

  static Future<DateTime?> show(
    BuildContext context, {
    required TripDatePickerMode mode,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    DateTime? rangeStart,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => TripDatePickerSheet(
        mode: mode,
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
        rangeStart: rangeStart,
      ),
    );
  }

  @override
  State<TripDatePickerSheet> createState() => _TripDatePickerSheetState();
}

class _TripDatePickerSheetState extends State<TripDatePickerSheet> {
  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _focusedMonth;
  late DateTime _selected;
  late DateTime _min;
  late DateTime _max;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _min = _dateOnly(widget.minDate ?? today);
    _max = _dateOnly(widget.maxDate ?? DateTime(2030, 12, 31));
    _selected = _dateOnly(widget.initialDate ?? widget.rangeStart ?? today);
    if (_selected.isBefore(_min)) _selected = _min;
    if (_selected.isAfter(_max)) _selected = _max;
    _focusedMonth = DateTime(_selected.year, _selected.month);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _isReturn => widget.mode == TripDatePickerMode.returnDate;

  String get _title => _isReturn ? 'Return date' : 'Departure date';

  String get _subtitle {
    if (_isReturn && widget.rangeStart != null) {
      return 'Tap a day or pick a trip length';
    }
    return 'Choose when your trip starts';
  }

  void _select(DateTime day) {
    if (day.isBefore(_min) || day.isAfter(_max)) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = day);
    Navigator.of(context).pop(day);
  }

  void _selectDuration(int days) {
    if (widget.rangeStart == null) return;
    final end = widget.rangeStart!.add(Duration(days: days - 1));
    if (end.isAfter(_max)) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(end);
  }

  void _shiftMonth(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
                    color: AppColors.primaryMuted.withValues(alpha: isDark ? 0.2 : 0.55),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    _isReturn ? Icons.flight_land_rounded : Icons.flight_takeoff_rounded,
                    size: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SelectedPreview(
              date: _selected,
              rangeStart: widget.rangeStart,
              isReturn: _isReturn,
            ),
          ),
          if (_isReturn && widget.rangeStart != null) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _DurationShortcuts(onSelect: _selectDuration),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _MonthHeader(
              label: '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
              onPrevious: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: _weekdays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            child: _MonthGrid(
              month: _focusedMonth,
              selected: _selected,
              minDate: _min,
              maxDate: _max,
              rangeStart: widget.rangeStart,
              onSelect: _select,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  const _SelectedPreview({
    required this.date,
    required this.rangeStart,
    required this.isReturn,
  });

  final DateTime date;
  final DateTime? rangeStart;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[date.weekday - 1];
    final label = '$weekday, ${months[date.month - 1]} ${date.day}';

    int? tripDays;
    if (isReturn && rangeStart != null && !date.isBefore(rangeStart!)) {
      tripDays = date.difference(rangeStart!).inDays + 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF134E4A), const Color(0xFF1E1E20)]
              : [AppColors.primaryMuted, const Color(0xFFF7F5F2)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          if (tripDays != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.15),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                '$tripDays ${tripDays == 1 ? 'day' : 'days'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DurationShortcuts extends StatelessWidget {
  const _DurationShortcuts({required this.onSelect});

  final ValueChanged<int> onSelect;

  static const _options = [3, 5, 7, 10, 14];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((days) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: days == _options.last ? 0 : AppSpacing.sm),
            child: Pressable(
              onTap: () => onSelect(days),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${days}d',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(icon, size: 22, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.minDate,
    required this.maxDate,
    required this.rangeStart,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? rangeStart;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leading, null),
      ...List.generate(daysInMonth, (i) => DateTime(month.year, month.month, i + 1)),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: [
        for (var row = 0; row < cells.length ~/ 7; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: cells[row * 7 + col],
                      selected: selected,
                      minDate: minDate,
                      maxDate: maxDate,
                      rangeStart: rangeStart,
                      onSelect: onSelect,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.minDate,
    required this.maxDate,
    required this.rangeStart,
    required this.onSelect,
  });

  final DateTime? day;
  final DateTime selected;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? rangeStart;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox(height: 40);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = day!.isBefore(minDate) || day!.isAfter(maxDate);
    final isSelected = _sameDay(day!, selected);
    final isToday = _sameDay(day!, DateTime.now());
    final inRange = rangeStart != null &&
        !day!.isBefore(rangeStart!) &&
        !day!.isAfter(selected) &&
        !isSelected &&
        !rangeStart!.isAtSameMomentAs(selected);

    Color? bg;
    if (isSelected) {
      bg = AppColors.primary;
    } else if (inRange) {
      bg = AppColors.primaryMuted.withValues(alpha: isDark ? 0.25 : 0.45);
    }

    return Pressable(
      onTap: isDisabled ? null : () => onSelect(day!),
      child: SizedBox(
        height: 40,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day!.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                color: isDisabled
                    ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary).withValues(alpha: 0.45)
                    : isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
