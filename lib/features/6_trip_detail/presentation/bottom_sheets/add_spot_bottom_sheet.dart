import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/spot_time_utils.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../../../core/widgets/trip_time_picker_sheet.dart';
import '../../bloc/trip_detail_bloc.dart';

class AddSpotBottomSheet extends StatefulWidget {
  const AddSpotBottomSheet({this.editSpot, this.initialCategory, super.key});

  final Spot? editSpot;
  final String? initialCategory;

  @override
  State<AddSpotBottomSheet> createState() => _AddSpotBottomSheetState();
}

class _AddSpotBottomSheetState extends State<AddSpotBottomSheet> {
  static const _durations = ['30m', '1h', '1.5h', '2h', '2.5h', '3h', '4h', '5h+'];

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'food';
  String? _duration;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editSpot != null;

  @override
  void initState() {
    super.initState();
    final spot = widget.editSpot;
    if (spot != null) {
      _nameController.text = spot.name;
      _addressController.text = spot.address ?? '';
      _notesController.text = spot.notes ?? '';
      _category = spot.category;
      _duration = spot.estimatedDuration;
      _startTime = SpotTimeUtils.parseStartTime(spot.openingHours);
      final endMatch = RegExp(r'-(\d{1,2}:\d{2})$').firstMatch(spot.openingHours ?? '');
      if (endMatch != null) {
        final parts = endMatch.group(1)!.split(':');
        _endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      return;
    }

    if (widget.initialCategory != null) {
      _category = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canAdd => _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SheetScaffold.swipeForm(
      swipeLabel: _isEditing ? 'Slide to save spot' : 'Slide to add spot',
      swipeEnabled: _canAdd && !_isSubmitting,
      onSwipeConfirmed: _submitSpot,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeroField(
            label: 'Spot name',
            hint: 'Ichiran Ramen',
            controller: _nameController,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Location'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: SheetIconFieldRow(
              icon: Icons.location_on_outlined,
              field: SheetInlineField(
                controller: _addressController,
                hint: 'Search or enter address',
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Category'),
          const SizedBox(height: AppSpacing.md),
          _CategoryPicker(
            selected: _category,
            onSelected: (value) {
              HapticFeedback.selectionClick();
              setState(() => _category = value);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Details', caption: 'Optional'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SpotTimeRangeRow(
                  startTime: _startTime,
                  endTime: _endTime,
                  onPickStart: _pickStartTime,
                  onPickEnd: _pickEndTime,
                ),
                const SheetSoftDivider(),
                _DurationPicker(
                  options: _durations,
                  selected: _duration,
                  onSelected: _onDurationSelected,
                ),
                if (_timeRangeHint case final hint?) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(hint, style: Theme.of(context).textTheme.bodySmall),
                ],
                const SheetSoftDivider(),
                SheetInlineField(
                  controller: _notesController,
                  hint: 'Tips or reminders...',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? get _timeRangeHint {
    if (_startTime != null && _endTime != null && _duration != null) {
      return '${SpotTimeUtils.formatDisplay(_startTime!)} → ${SpotTimeUtils.formatDisplay(_endTime!)} · $_duration';
    }
    if (_startTime != null && _endTime != null) {
      return '${SpotTimeUtils.formatDisplay(_startTime!)} → ${SpotTimeUtils.formatDisplay(_endTime!)}';
    }
    return null;
  }

  void _onDurationSelected(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      _duration = value;
      final minutes = SpotTimeUtils.durationToMinutes(value);
      if (minutes == null) return;

      if (_startTime != null) {
        _endTime = SpotTimeUtils.addMinutes(_startTime!, minutes);
      } else if (_endTime != null) {
        _startTime = SpotTimeUtils.subtractMinutes(_endTime!, minutes);
      }
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await TripTimePickerSheet.show(
      context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
      title: 'Start time',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _startTime = picked;
      _syncFromStart();
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await TripTimePickerSheet.show(
      context,
      initialTime: _endTime ?? _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      title: 'End time',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _endTime = picked;
      _syncFromEnd();
    });
  }

  void _syncFromStart() {
    if (_startTime == null) return;

    if (_duration != null) {
      final minutes = SpotTimeUtils.durationToMinutes(_duration!);
      if (minutes != null) {
        _endTime = SpotTimeUtils.addMinutes(_startTime!, minutes);
      }
      return;
    }

    if (_endTime != null) {
      _duration = SpotTimeUtils.minutesToDurationChip(
        SpotTimeUtils.minutesBetween(_startTime!, _endTime!),
        _durations,
      );
    }
  }

  void _syncFromEnd() {
    if (_endTime == null) return;

    if (_startTime != null) {
      _duration = SpotTimeUtils.minutesToDurationChip(
        SpotTimeUtils.minutesBetween(_startTime!, _endTime!),
        _durations,
      );
      return;
    }

    if (_duration != null) {
      final minutes = SpotTimeUtils.durationToMinutes(_duration!);
      if (minutes != null) {
        _startTime = SpotTimeUtils.subtractMinutes(_endTime!, minutes);
      }
    }
  }

  Future<void> _submitSpot() async {
    if (!_canAdd || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final payload = (
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      category: _category,
      openingHours: SpotTimeUtils.openingHoursLabel(_startTime, _endTime),
      estimatedDuration: _duration,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final bloc = context.read<TripDetailBloc>();
    if (_isEditing) {
      bloc.add(
        TripDetailSpotUpdated(
          spotId: widget.editSpot!.id,
          name: payload.name,
          address: payload.address,
          category: payload.category,
          openingHours: payload.openingHours,
          estimatedDuration: payload.estimatedDuration,
          notes: payload.notes,
        ),
      );
    } else {
      bloc.add(
        TripDetailSpotAdded(
          name: payload.name,
          address: payload.address,
          category: payload.category,
          openingHours: payload.openingHours,
          estimatedDuration: payload.estimatedDuration,
          notes: payload.notes,
        ),
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _SpotTimeRangeRow extends StatelessWidget {
  const _SpotTimeRangeRow({
    required this.startTime,
    required this.endTime,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SheetIconTile(icon: Icons.schedule_outlined),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _TimeCell(
                  label: 'Start',
                  time: startTime,
                  onTap: onPickStart,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
              Expanded(
                child: _TimeCell(
                  label: 'End',
                  time: endTime,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = time != null;

    return Pressable(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: hasValue ? AppColors.primary.withValues(alpha: 0.45) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hasValue ? SpotTimeUtils.formatDisplay(time!) : 'Set',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasValue
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: SpotCategory.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final category = SpotCategory.values[index];
            return _EmojiChip(
              emoji: category.emoji,
              isSelected: category.value == selected,
              onTap: () => onSelected(category.value),
            );
          },
        ),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final option = options[index];
            return _TextChip(
              label: option,
              isSelected: option == selected,
              onTap: () => onSelected(option),
            );
          },
        ),
      ),
    );
  }
}

class _EmojiChip extends StatelessWidget {
  const _EmojiChip({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
              : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _TextChip extends StatelessWidget {
  const _TextChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
              : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
