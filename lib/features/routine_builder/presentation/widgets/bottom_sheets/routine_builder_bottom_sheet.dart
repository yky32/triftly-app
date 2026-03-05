import 'package:flutter/material.dart';
import 'package:triftly/core/helpers/helpers.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Result of selecting a trip date range in the routine builder bottom sheet.
/// All values are derived from the calendar range selection.
class RoutineTripResult {
  const RoutineTripResult({
    required this.startDate,
    required this.endDate,
    this.name = '',
  });

  final DateTime startDate;
  final DateTime endDate;

  /// Name of the trip (user-editable in the bottom sheet).
  final String name;

  /// Days of trip (inclusive). Uses calendar-day count; correct for any year (365/366) and month lengths (e.g. Feb 28/29).
  int get daysOfTrip => DateHelpers.calendarDaysBetween(startDate, endDate);
}

/// Bottom sheet for trip planning: select a date range on a calendar.
/// Start date, end date, and days of trip are derived from the selection.
///
/// Use [RoutineBuilderBottomSheet.show] to present it and get the result.
class RoutineBuilderBottomSheet extends StatefulWidget {
  const RoutineBuilderBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialName,
    this.title = 'Select trip dates',
    this.confirmLabel = 'Confirm',
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialName;
  final String title;
  final String confirmLabel;

  /// Shows the bottom sheet and returns the selected range (and trip name), or `null` if dismissed.
  static Future<RoutineTripResult?> show(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    String? initialName,
    String? title,
    String? confirmLabel,
  }) {
    return showAppModalBottomSheet<RoutineTripResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutineBuilderBottomSheet(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        initialName: initialName,
        title: title ?? 'Select trip dates',
        confirmLabel: confirmLabel ?? 'Confirm',
      ),
    );
  }

  @override
  State<RoutineBuilderBottomSheet> createState() =>
      _RoutineBuilderBottomSheetState();
}

class _RoutineBuilderBottomSheetState extends State<RoutineBuilderBottomSheet> {
  late DateTime _viewMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  late TextEditingController _nameController;

  static const List<String> _weekdayLabels = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null) {
        _startDate = date;
        _endDate = null;
      } else if (_endDate == null) {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      } else {
        _startDate = date;
        _endDate = null;
      }
    });
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null) return false;
    final start = DateHelpers.dateOnly(_startDate!);
    final end =
        _endDate != null ? DateHelpers.dateOnly(_endDate!) : start;
    final d = DateHelpers.dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool _isStart(DateTime date) {
    if (_startDate == null) return false;
    return DateHelpers.isSameDay(date, _startDate!);
  }

  bool _isEnd(DateTime date) {
    if (_endDate == null) return _isStart(date);
    return DateHelpers.isSameDay(date, _endDate!);
  }

  void _onConfirm() {
    if (_startDate == null) return;
    final end = _endDate ?? _startDate!;
    final start = _startDate!;
    if (end.isBefore(start)) return;
    Navigator.of(context).pop(RoutineTripResult(
      startDate: DateHelpers.dateOnly(start),
      endDate: DateHelpers.dateOnly(end),
      name: _nameController.text.trim(),
    ));
  }

  int get _daysOfTrip {
    if (_startDate == null) return 0;
    final end = _endDate ?? _startDate!;
    final start = _startDate!;
    if (end.isBefore(start)) return 0;
    return DateHelpers.calendarDaysBetween(start, end);
  }

  /// True when both start and end are selected (button is active).
  bool get _canConfirm =>
      _startDate != null &&
      _endDate != null &&
      !_endDate!.isBefore(_startDate!);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final primaryContainer =
        isDark ? primary.withValues(alpha: 0.3) : AppColors.tealMist;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24 + padding.left,
        right: 24 + padding.right,
        top: 20,
        bottom: 24 + padding.bottom + viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: TapToUnfocus(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BottomSheetDragHandle(),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trip name',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Tokyo Shopping Trip...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              _MonthNavigation(
                leftMonth: _viewMonth,
                onPrev: () {
                  setState(() {
                    _viewMonth =
                        DateTime(_viewMonth.year, _viewMonth.month - 1);
                  });
                },
                onNext: () {
                  setState(() {
                    _viewMonth =
                        DateTime(_viewMonth.year, _viewMonth.month + 1);
                  });
                },
                textStyle:
                    theme.textTheme.titleSmall?.copyWith(color: onSurface),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MonthGrid(
                      month: _viewMonth,
                      startDate: _startDate,
                      endDate: _endDate,
                      primary: primary,
                      primaryContainer: primaryContainer,
                      onSurface: onSurface,
                      surfaceColor: surfaceColor,
                      isStart: _isStart,
                      isEnd: _isEnd,
                      isInRange: _isInRange,
                      onDateTap: _onDateTap,
                      weekdayLabels: _weekdayLabels,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MonthGrid(
                      month: DateTime(_viewMonth.year, _viewMonth.month + 1),
                      startDate: _startDate,
                      endDate: _endDate,
                      primary: primary,
                      primaryContainer: primaryContainer,
                      onSurface: onSurface,
                      surfaceColor: surfaceColor,
                      isStart: _isStart,
                      isEnd: _isEnd,
                      isInRange: _isInRange,
                      onDateTap: _onDateTap,
                      weekdayLabels: _weekdayLabels,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _canConfirm ? _onConfirm : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.fogGray.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.today_outlined, size: 20, color: onSurface),
                        const SizedBox(width: 8),
                        Text(
                          _daysOfTrip == 0
                              ? 'Select start and end date'
                              : '$_daysOfTrip day${_daysOfTrip == 1 ? '' : 's'} of trip',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNavigation extends StatelessWidget {
  const _MonthNavigation({
    required this.leftMonth,
    required this.onPrev,
    required this.onNext,
    required this.textStyle,
  });

  final DateTime leftMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final rightMonth = DateTime(leftMonth.year, leftMonth.month + 1);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Expanded(
          child: Text(
            DateHelpers.formatMonthYear(leftMonth),
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            DateHelpers.formatMonthYear(rightMonth),
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.primary,
    required this.primaryContainer,
    required this.onSurface,
    required this.surfaceColor,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.onDateTap,
    required this.weekdayLabels,
    required this.theme,
  });

  final DateTime month;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color primary;
  final Color primaryContainer;
  final Color onSurface;
  final Color surfaceColor;
  final bool Function(DateTime) isStart;
  final bool Function(DateTime) isEnd;
  final bool Function(DateTime) isInRange;
  final void Function(DateTime) onDateTap;
  final List<String> weekdayLabels;
  final ThemeData theme;

  /// Builds the grid of day slots for the month (leading empties + 1..lastDay).
  /// Handles Feb 28/29 (leap year) and all month lengths via [DateHelpers.lastDayOfMonth].
  List<DateTime?> _daysForMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final lastDay = DateHelpers.lastDayOfMonth(month.year, month.month);
    final weekday = first.weekday; // 1 = Monday, 7 = Sunday; column 0 = Sunday
    final leading = weekday % 7;
    final days = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      days.add(null);
    }
    for (var d = 1; d <= lastDay; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    return days;
  }

  Widget _buildDayCell(
    DateTime? date,
    double cellSize,
    Color primary,
    Color primaryContainer,
    Color onSurface,
  ) {
    if (date == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }
    final isToday = DateHelpers.isToday(date);
    return _DayCell(
      date: date,
      cellSize: cellSize,
      isStart: isStart(date),
      isEnd: isEnd(date),
      isInRange: isInRange(date),
      isBarStart: isInRange(date) &&
          !isStart(date) &&
          !isInRange(date.subtract(const Duration(days: 1))),
      isBarEnd: isInRange(date) &&
          !isEnd(date) &&
          !isInRange(date.add(const Duration(days: 1))),
      isToday: isToday,
      primary: primary,
      primaryContainer: primaryContainer,
      onSurface: onSurface,
      onTap: () => onDateTap(date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysForMonth(month);
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: onSurface);
    const spacing = 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        // 7 cells + 6 gaps: ensure 7*cellSize + 6*spacing <= maxWidth (use floor to avoid overflow)
        final cellSize = maxWidth.isFinite && maxWidth > 0
            ? ((maxWidth - 6 * spacing) / 7).floorToDouble().clamp(20.0, 32.0)
            : 28.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                for (var i = 0; i < weekdayLabels.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing),
                  SizedBox(
                    width: cellSize,
                    child: Center(
                      child: Text(
                        weekdayLabels[i],
                        style: textStyle?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: i == 0 ? Colors.red : AppColors.mistGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var row = 0; row < days.length; row += 7)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: row + 7 < days.length ? spacing : 0),
                    child: Row(
                      children: [
                        for (var col = 0; col < 7; col++) ...[
                          if (col > 0) SizedBox(width: spacing),
                          _buildDayCell(
                            row + col < days.length ? days[row + col] : null,
                            cellSize,
                            primary,
                            primaryContainer,
                            onSurface,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.cellSize,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.isBarStart,
    required this.isBarEnd,
    required this.isToday,
    required this.primary,
    required this.primaryContainer,
    required this.onSurface,
    required this.onTap,
  });

  final DateTime date;
  final double cellSize;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final bool isBarStart;
  final bool isBarEnd;
  final bool isToday;
  final Color primary;
  final Color primaryContainer;
  final Color onSurface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showCircle = isStart || isEnd;
    final showBar = isInRange && !showCircle;

    Widget content;
    if (showCircle) {
      content = Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      );
    } else {
      content = Text(
        '${date.day}',
        style: TextStyle(
          fontSize: 12,
          color: date.weekday == 7
              ? Colors.red
              : (isInRange ? primary : onSurface),
          fontWeight: isInRange ? FontWeight.w500 : FontWeight.normal,
        ),
      );
    }

    if (isToday) {
      content = Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        alignment: Alignment.center,
        child: content,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBar)
              Positioned(
                left: 0,
                right: 0,
                top: cellSize / 2 - 10,
                bottom: cellSize / 2 - 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryContainer,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(isBarStart ? 10 : 0),
                      right: Radius.circular(isBarEnd ? 10 : 0),
                    ),
                  ),
                ),
              ),
            content,
          ],
        ),
      ),
    );
  }
}
