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
                const SizedBox(height: AppSpacing.lg),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
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

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? pickedDate),
    );
    if (!context.mounted) return;

    final hour = pickedTime?.hour ?? (current?.hour ?? 12);
    final minute = pickedTime?.minute ?? (current?.minute ?? 0);

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isOutbound ? AppColors.primary : const Color(0xFF64748B);
    final bg = isOutbound
        ? AppColors.primaryMuted.withValues(alpha: isDark ? 0.28 : 0.6)
        : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9));

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
    final accent = isOutbound ? AppColors.primary : const Color(0xFF64748B);

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
                    child: Pressable(
                      onTap: onPickDepart,
                      child: departAt != null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(departAt!),
                                  style: fieldStyle,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  _formatDateWeekday(departAt!),
                                  style: TextStyle(fontSize: 11, color: tertiary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Text('Select', style: hintStyle, textAlign: TextAlign.center),
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

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:$minute $period';
  }

  String _formatDateWeekday(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${months[date.month - 1]} ${date.day} ${weekdays[date.weekday - 1]}';
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
