import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Trip',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _label('Trip Name'),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. Tokyo 2026'),
                ),
                const SizedBox(height: 16),
                _label('Destination'),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    hintText: 'Where to?',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Dates'),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: _startDate != null ? _formatDate(_startDate!) : 'Start',
                        onTap: () => _pickDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                        label: _endDate != null ? _formatDate(_endDate!) : 'End',
                        onTap: () => _pickDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label('Default Currency'),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  items: _currencies.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  )).toList(),
                  onChanged: (v) => setState(() => _currency = v!),
                ),
                const SizedBox(height: 16),
                _label('Buddies'),
                TextField(
                  controller: _buddyNameController,
                  decoration: InputDecoration(
                    hintText: '+ Add name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _addBuddy,
                    ),
                  ),
                  onSubmitted: (_) => _addBuddy(),
                ),
                if (_buddies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buddies.map((b) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: _colorFromHex(b.avatarColor ?? '007AFF'),
                        child: Text(
                          b.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                      label: Text(b.name),
                      onDeleted: () => setState(() => _buddies.remove(b)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _createTrip,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Create Trip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      ),
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
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _createTrip() {
    if (_nameController.text.trim().isEmpty) return;
    if (_startDate == null || _endDate == null) return;

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

  Color _colorFromHex(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: label == 'Start' || label == 'End'
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
