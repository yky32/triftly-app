import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/trip_date_picker_sheet.dart';
import '../../../6_trip_detail/bloc/trip_detail_bloc.dart';

class EditTripBottomSheet extends StatefulWidget {
  const EditTripBottomSheet({
    required this.trip,
    this.onSaved,
    super.key,
  });

  final Trip trip;
  final void Function(Trip trip)? onSaved;

  static Future<void> show(
    BuildContext context, {
    required Trip trip,
    void Function(Trip trip)? onSaved,
  }) {
    return TriftlyBottomSheet.show(
      context,
      child: EditTripBottomSheet(trip: trip, onSaved: onSaved),
    );
  }

  @override
  State<EditTripBottomSheet> createState() => _EditTripBottomSheetState();
}

class _EditTripBottomSheetState extends State<EditTripBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _destinationController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trip.name);
    _destinationController = TextEditingController(text: widget.trip.destination);
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _destinationController.text.trim().isNotEmpty &&
      !_endDate.isBefore(_startDate);

  Future<void> _pickDate(bool isStart) async {
    final picked = await TripDatePickerSheet.show(
      context,
      mode: isStart ? TripDatePickerMode.departure : TripDatePickerMode.returnDate,
      initialDate: isStart ? _startDate : _endDate,
      minDate: isStart ? null : _startDate,
      rangeStart: isStart ? null : _startDate,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_canSave || _submitting) return;
    setState(() => _submitting = true);

    final updated = widget.trip.copyWith(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
    );

    if (widget.onSaved != null) {
      widget.onSaved!(updated);
    } else {
      context.read<TripDetailBloc>().add(TripDetailTripUpdated(trip: updated));
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold.swipeForm(
      swipeLabel: 'Slide to save changes',
      swipeEnabled: _canSave && !_submitting,
      onSwipeConfirmed: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeroField(
            label: 'Trip name',
            hint: widget.trip.name,
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
                    hint: 'Destination',
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _DateChip(
                        label: 'From',
                        date: _startDate,
                        onTap: () => _pickDate(true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DateChip(
                        label: 'To',
                        date: _endDate,
                        onTap: () => _pickDate(false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
