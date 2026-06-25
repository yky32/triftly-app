import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nanoid/nanoid.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/me_identity_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/trip_date_picker_sheet.dart';
import '../../../../core/widgets/trip_time_picker_sheet.dart';
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
  final _outboundFlightNoController = TextEditingController();
  final _outboundFromController = TextEditingController();
  final _outboundToController = TextEditingController();
  final _returnFlightNoController = TextEditingController();
  final _returnFromController = TextEditingController();
  final _returnToController = TextEditingController();
  DateTime? _outboundDepartAt;
  DateTime? _returnDepartAt;
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
    _outboundFlightNoController.dispose();
    _outboundFromController.dispose();
    _outboundToController.dispose();
    _returnFlightNoController.dispose();
    _returnFromController.dispose();
    _returnToController.dispose();
    _buddyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripLength = _tripLengthDays;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeroField(
            label: 'New Trip Name',
            hint: 'Tokyo 2026',
            controller: _nameController,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Where & when'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              children: [
                SheetIconFieldRow(
                  icon: Icons.location_on_outlined,
                  field: SheetInlineField(
                    controller: _destinationController,
                    hint: 'Where are you going?',
                    onChanged: () => setState(() {}),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _TripLengthBadge(days: tripLength),
                      ),
                      Expanded(
                        child: _DateCell(
                          label: 'From',
                          value: _startDate,
                          centered: true,
                          onTap: () => _pickDate(context, true),
                        ),
                      ),
                      Expanded(
                        child: _DateRangeConnector(
                          hasRange: _startDate != null && _endDate != null,
                        ),
                      ),
                      Expanded(
                        child: _DateCell(
                          label: 'To',
                          value: _endDate,
                          centered: true,
                          onTap: () => _pickDate(context, false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SheetSoftDivider(),
                const _FlightColumnHeaders(),
                const SizedBox(height: AppSpacing.xs),
                _FlightLegRow(
                  isOutbound: true,
                  flightNoController: _outboundFlightNoController,
                  departAt: _outboundDepartAt,
                  fromController: _outboundFromController,
                  toController: _outboundToController,
                  onPickDepart: () => _pickFlightDepart(context, isOutbound: true),
                ),
                const SheetSoftDivider(),
                _FlightLegRow(
                  isOutbound: false,
                  flightNoController: _returnFlightNoController,
                  departAt: _returnDepartAt,
                  fromController: _returnFromController,
                  toController: _returnToController,
                  onPickDepart: () => _pickFlightDepart(context, isOutbound: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Currency'),
          const SizedBox(height: AppSpacing.md),
          SheetCurrencyChipPicker(
            selected: _currency,
            onSelected: (code) {
              HapticFeedback.selectionClick();
              setState(() => _currency = code);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(
            title: 'Travel buddies',
            caption: 'Optional',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
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
                    const SheetIconTile(icon: Icons.people_outline_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SheetInlineField(
                        controller: _buddyNameController,
                        hint: 'Add a name and press return',
                        textInputAction: TextInputAction.done,
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
          _syncFlightDepartDates();
        } else {
          _endDate = picked;
          _syncFlightDepartDates();
        }
      });
    }
  }

  void _syncFlightDepartDates() {
    if (_startDate != null) {
      _outboundDepartAt = _mergeDate(
        _outboundDepartAt ?? _startDate!,
        _startDate!,
      );
    }
    if (_endDate != null) {
      _returnDepartAt = _mergeDate(
        _returnDepartAt ?? _endDate!,
        _endDate!,
      );
    }
  }

  DateTime _mergeDate(DateTime current, DateTime dateOnly) {
    return DateTime(dateOnly.year, dateOnly.month, dateOnly.day, current.hour, current.minute);
  }

  Future<void> _pickFlightDepart(BuildContext context, {required bool isOutbound}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = isOutbound ? _startDate : _endDate;
    final current = isOutbound ? _outboundDepartAt : _returnDepartAt;

    final pickedDate = await TripDatePickerSheet.show(
      context,
      mode: isOutbound ? TripDatePickerMode.departure : TripDatePickerMode.returnDate,
      initialDate: current ?? tripDate ?? today,
      minDate: today,
      maxDate: DateTime(2030, 12, 31),
      rangeStart: isOutbound ? null : _startDate,
    );
    if (pickedDate == null) return;
    if (!context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _FlightDirectionBadge.accentFor(isOutbound, isDark);

    final pickedTime = await TripTimePickerSheet.show(
      context,
      initialTime: TimeOfDay.fromDateTime(current ?? pickedDate),
      accentColor: accent,
      title: isOutbound ? 'Outbound departure' : 'Return departure',
    );
    if (pickedTime == null) return;
    if (!context.mounted) return;

    final hour = pickedTime.hour;
    final minute = pickedTime.minute;

    setState(() {
      final departAt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, hour, minute);
      if (isOutbound) {
        _outboundDepartAt = departAt;
      } else {
        _returnDepartAt = departAt;
      }
    });
  }

  FlightLeg? _buildFlightLeg({
    required TextEditingController flightNo,
    required DateTime? departAt,
    required TextEditingController from,
    required TextEditingController to,
  }) {
    final leg = FlightLeg(
      flightNumber: flightNo.text.trim().isEmpty ? null : flightNo.text.trim().toUpperCase(),
      departAt: departAt,
      fromAirport: from.text.trim().isEmpty ? null : from.text.trim().toUpperCase(),
      toAirport: to.text.trim().isEmpty ? null : to.text.trim().toUpperCase(),
    );
    return leg.isEmpty ? null : leg;
  }

  Future<void> _createTrip() async {
    if (!_canCreate || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final session = AppBootstrap.userSession;
    final creator = MeIdentityService.creatorBuddy(
      user: session.currentUser,
      preferences: AppBootstrap.profilePreferences,
    );
    final buddies = [
      ..._buddies,
      if (!_buddies.any((b) => b.isMe || b.userId == creator.userId)) creator,
    ];

    final trip = Trip(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      defaultCurrency: _currency,
      outboundFlight: _buildFlightLeg(
        flightNo: _outboundFlightNoController,
        departAt: _outboundDepartAt,
        from: _outboundFromController,
        to: _outboundToController,
      ),
      returnFlight: _buildFlightLeg(
        flightNo: _returnFlightNoController,
        departAt: _returnDepartAt,
        from: _returnFromController,
        to: _returnToController,
      ),
      buddies: buddies,
      ownerId: session.currentUser?.id,
      shareToken: nanoid(12),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<TripListBloc>().add(TripListTripCreated(trip: trip));

    // Brief beat so the checkmark reads before the sheet dismisses.
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop(true);
  }
}

class _FlightColumnHeaders extends StatelessWidget {
  const _FlightColumnHeaders();

  static const _labels = ['Flight', 'Depart', 'From', 'To'];
  static const _leadingWidth = _FlightLegRow.leadingWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
    );

    return Row(
      children: [
        const SizedBox(width: _leadingWidth),
        ..._labels.map(
          (label) => Expanded(
            child: Text(label, style: style, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}

class _FlightDirectionBadge extends StatelessWidget {
  const _FlightDirectionBadge({required this.isOutbound});

  final bool isOutbound;

  static const outboundBlue = Color(0xFF0369A1);
  static const outboundBlueLight = Color(0xFFE0F2FE);
  static const outboundBlueDark = Color(0xFF7DD3FC);
  static const returnOrange = Color(0xFFC2410C);
  static const returnOrangeLight = Color(0xFFFFEDD5);
  static const returnOrangeDark = Color(0xFFFDBA74);

  static Color accentFor(bool isOutbound, bool isDark) =>
      isOutbound ? (isDark ? outboundBlueDark : outboundBlue) : (isDark ? returnOrangeDark : returnOrange);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentFor(isOutbound, isDark);
    final bg = isOutbound
        ? outboundBlueLight.withValues(alpha: isDark ? 0.22 : 0.85)
        : returnOrangeLight.withValues(alpha: isDark ? 0.22 : 0.85);

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(
        isOutbound ? Icons.flight_takeoff_rounded : Icons.flight_land_rounded,
        size: 16,
        color: color,
      ),
    );
  }
}

class _FlightLegRow extends StatelessWidget {
  const _FlightLegRow({
    required this.isOutbound,
    required this.flightNoController,
    required this.departAt,
    required this.fromController,
    required this.toController,
    required this.onPickDepart,
  });

  static const leadingWidth = 38.0;
  static const _fontSize = 14.0;
  static const _hintSize = 13.0;

  final bool isOutbound;
  final TextEditingController flightNoController;
  final DateTime? departAt;
  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback onPickDepart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final fieldStyle = TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, color: primary);
    final hintStyle = TextStyle(fontSize: _hintSize, fontWeight: FontWeight.w500, color: tertiary);
    final accent = _FlightDirectionBadge.accentFor(isOutbound, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accent.withValues(alpha: 0.55), width: 2.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _FlightDirectionBadge(isOutbound: isOutbound),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: flightNoController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: fieldStyle.copyWith(letterSpacing: 0.3),
                      decoration: InputDecoration(
                        hintText: 'CX5601',
                        hintStyle: hintStyle,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _FlightDepartCell(
                      departAt: departAt,
                      accent: accent,
                      onTap: onPickDepart,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: fromController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                      style: fieldStyle.copyWith(letterSpacing: 1),
                      decoration: InputDecoration(
                        hintText: 'FUK',
                        hintStyle: hintStyle,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: toController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                      style: fieldStyle.copyWith(letterSpacing: 1),
                      decoration: InputDecoration(
                        hintText: 'HKG',
                        hintStyle: hintStyle,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightDepartCell extends StatelessWidget {
  const _FlightDepartCell({
    required this.departAt,
    required this.accent,
    required this.onTap,
  });

  final DateTime? departAt;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Pressable(
      onTap: onTap,
      child: departAt == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 15, color: tertiary.withValues(alpha: 0.8)),
                const SizedBox(height: 3),
                Text(
                  'Set',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tertiary),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDateWeekday(departAt!),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: tertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                _ModernTimeLabel(date: departAt!, accent: accent),
              ],
            ),
    );
  }

  String _formatDateWeekday(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${months[date.month - 1]} ${date.day} ${weekdays[date.weekday - 1]}';
  }
}

class _ModernTimeLabel extends StatelessWidget {
  const _ModernTimeLabel({required this.date, required this.accent});

  final DateTime date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$hour12:$minute',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1,
            color: accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 3),
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              period,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                height: 1,
                color: accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TripLengthBadge extends StatelessWidget {
  const _TripLengthBadge({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final hasDays = days != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: tertiary)),
          const SizedBox(height: 4),
          if (hasDays) ...[
            Text(
              '$days',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1,
                color: primary,
              ),
            ),
            Text('days', style: TextStyle(fontSize: 11, color: tertiary)),
          ] else
            Text(
              '—',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: tertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.label,
    required this.value,
    required this.onTap,
    this.centered = false,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final hasValue = value != null;

    return Pressable(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: tertiary)),
          const SizedBox(height: 4),
          Text(
            hasValue ? _formatDate(value!) : 'Select',
            style: TextStyle(
              fontSize: hasValue ? 17 : 14,
              fontWeight: FontWeight.w700,
              letterSpacing: hasValue ? -0.3 : 0,
              color: hasValue
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                  : tertiary,
            ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
          if (hasValue)
            Text(
              _formatYear(value!),
              style: TextStyle(fontSize: 11, color: tertiary),
              textAlign: centered ? TextAlign.center : TextAlign.start,
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

class _DateRangeConnector extends StatelessWidget {
  const _DateRangeConnector({required this.hasRange});

  final bool hasRange;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: hasRange
              ? AppColors.primaryMuted.withValues(alpha: isDark ? 0.28 : 0.65)
              : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasRange
                ? AppColors.primary.withValues(alpha: 0.35)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Transform.rotate(
          angle: 1.5708,
          child: Icon(
            Icons.flight_rounded,
            size: 18,
            color: hasRange ? AppColors.primaryDark : AppColors.primary,
          ),
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
