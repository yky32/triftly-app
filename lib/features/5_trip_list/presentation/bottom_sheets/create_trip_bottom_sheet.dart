import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/trip_date_picker_sheet.dart';
import '../../../../core/widgets/swipe_to_confirm.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../bloc/trip_list_bloc.dart';

class CreateTripBottomSheet extends StatefulWidget {
  const CreateTripBottomSheet({super.key});

  @override
  State<CreateTripBottomSheet> createState() => _CreateTripBottomSheetState();
}

class _CreateTripBottomSheetState extends State<CreateTripBottomSheet> {
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = 'JPY';
  final _buddyNameController = TextEditingController();
  final List<Buddy> _buddies = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _buddyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final tripLength = _tripLengthDays;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroNameField(controller: _nameController, onChanged: () => setState(() {})),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(title: 'Where & when'),
          const SizedBox(height: AppSpacing.md),
          _SoftCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const _LocationIconTile(),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Where are you going?',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: tertiary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _DateCell(
                        label: 'From',
                        value: _startDate,
                        onTap: () => _pickDate(context, true),
                      ),
                    ),
                    _DateConnector(hasRange: _startDate != null && _endDate != null),
                    Expanded(
                      child: _DateCell(
                        label: 'To',
                        value: _endDate,
                        onTap: () => _pickDate(context, false),
                      ),
                    ),
                  ],
                ),
                if (tripLength != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted.withValues(alpha: isDark ? 0.2 : 0.55),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: AppColors.primaryDark),
                          const SizedBox(width: 5),
                          Text(
                            '$tripLength ${tripLength == 1 ? 'day' : 'days'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionHeader(title: 'Currency'),
          const SizedBox(height: AppSpacing.md),
          _CurrencyPicker(
            selected: _currency,
            onSelected: (code) {
              HapticFeedback.selectionClick();
              setState(() => _currency = code);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(
            title: 'Travel buddies',
            caption: 'Optional',
          ),
          const SizedBox(height: AppSpacing.md),
          _SoftCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_buddies.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _buddies
                        .map((b) => _BuddyChip(
                              buddy: b,
                              onRemove: () => setState(() => _buddies.remove(b)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 22, color: tertiary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _buddyNameController,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a name and press return',
                          hintStyle: TextStyle(fontSize: 14, color: tertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _addBuddy(),
                      ),
                    ),
                    Pressable(
                      onTap: _addBuddy,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SwipeToConfirm(
            label: 'Slide to create trip',
            enabled: _canCreate && !_isSubmitting,
            onConfirmed: _createTrip,
          ),
        ],
      ),
    );
  }

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && _startDate != null && _endDate != null;

  int? get _tripLengthDays {
    if (_startDate == null || _endDate == null) return null;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _addBuddy() {
    final name = _buddyNameController.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buddies.add(Buddy.create(name: name));
      _buddyNameController.clear();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await TripDatePickerSheet.show(
      context,
      mode: isStart ? TripDatePickerMode.departure : TripDatePickerMode.returnDate,
      initialDate: isStart ? (_startDate ?? today) : (_endDate ?? _startDate ?? today),
      minDate: isStart ? today : (_startDate ?? today),
      maxDate: DateTime(2030, 12, 31),
      rangeStart: isStart ? null : _startDate,
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_canCreate || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final trip = Trip(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      defaultCurrency: _currency,
      buddies: _buddies,
      createdAt: DateTime.now(),
    );

    context.read<TripListBloc>().add(TripListTripCreated(trip: trip));

    // Brief beat so the checkmark reads before the sheet dismisses.
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop(true);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.caption});

  final String title;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        if (caption != null)
          Text(
            caption!,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroNameField extends StatelessWidget {
  const _HeroNameField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Trip Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Tokyo 2026',
              hintStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.6,
                color: tertiary.withValues(alpha: 0.75),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationIconTile extends StatelessWidget {
  const _LocationIconTile();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.primaryMuted.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.location_on_outlined,
        size: 22,
        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final hasValue = value != null;

    return Pressable(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: tertiary)),
          const SizedBox(height: 6),
          Text(
            hasValue ? _formatDate(value!) : 'Select',
            style: TextStyle(
              fontSize: hasValue ? 20 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: hasValue ? -0.4 : 0,
              color: hasValue
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                  : tertiary,
            ),
          ),
          if (hasValue)
            Text(
              _formatYear(value!),
              style: TextStyle(fontSize: 12, color: tertiary),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatYear(DateTime date) => '${date.year}';
}

class _DateConnector extends StatelessWidget {
  const _DateConnector({required this.hasRange});

  final bool hasRange;

  @override
  Widget build(BuildContext context) {
    final color = hasRange ? AppColors.primary : AppColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: [
          const SizedBox(height: 22),
          Container(
            width: 28,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CurrencyOptions.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final option = CurrencyOptions.all[index];
          return _CurrencyChip(
            option: option,
            isSelected: option.code == selected,
            onTap: () => onSelected(option.code),
          );
        },
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CurrencyOption option;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.flag, style: const TextStyle(fontSize: 20, height: 1)),
            const SizedBox(height: 2),
            Text(
              option.symbol,
              style: TextStyle(
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuddyChip extends StatelessWidget {
  const _BuddyChip({required this.buddy, required this.onRemove});

  final Buddy buddy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _colorFromHex(buddy.avatarColor ?? '0D9488'),
            child: Text(
              buddy.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          Text(buddy.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 2),
          Pressable(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 15, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hex) => Color(int.parse('FF$hex', radix: 16));
}
