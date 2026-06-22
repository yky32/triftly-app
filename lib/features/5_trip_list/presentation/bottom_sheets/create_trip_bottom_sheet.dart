import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
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

  final _currencies = ['HKD', 'JPY', 'KRW', 'USD', 'EUR', 'GBP', 'THB', 'SGD', 'TWD', 'CNY'];

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _buddyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'New Trip',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Trip Name'),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'e.g. Tokyo 2026'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Destination'),
          TextField(
            controller: _destinationController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Where to?',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Dates'),
          Row(
            children: [
              Expanded(child: _DateButton(label: _startDate != null ? _formatDate(_startDate!) : 'Start', onTap: () => _pickDate(context, true))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _DateButton(label: _endDate != null ? _formatDate(_endDate!) : 'End', onTap: () => _pickDate(context, false))),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Default Currency'),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(suffixIcon: Icon(Icons.arrow_drop_down_rounded)),
            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _currency = v!),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Buddies'),
          TextField(
            controller: _buddyNameController,
            decoration: InputDecoration(
              hintText: 'Add a name',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: _addBuddy,
              ),
            ),
            onSubmitted: (_) => _addBuddy(),
          ),
          if (_buddies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _buddies.map((b) => Chip(
                avatar: CircleAvatar(
                  backgroundColor: _colorFromHex(b.avatarColor ?? '007AFF'),
                  child: Text(b.name[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
                label: Text(b.name),
                onDeleted: () => setState(() => _buddies.remove(b)),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
              )).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _canCreate ? _createTrip : null,
            child: const Text('Create Trip'),
          ),
        ],
      ),
    );
  }

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && _startDate != null && _endDate != null;

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary, fontSize: 13)),
    );
  }

  void _addBuddy() {
    final name = _buddyNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _buddies.add(Buddy.create(name: name));
      _buddyNameController.clear();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
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

  void _createTrip() {
    if (!_canCreate) return;

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
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  Color _colorFromHex(String hex) => Color(int.parse('FF$hex', radix: 16));
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = label == 'Start' || label == 'End';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: isPlaceholder ? AppColors.textTertiary : AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isPlaceholder ? AppColors.textTertiary : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
