import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/trip_detail_bloc.dart';

class AddSpotBottomSheet extends StatefulWidget {
  const AddSpotBottomSheet({super.key});

  @override
  State<AddSpotBottomSheet> createState() => _AddSpotBottomSheetState();
}

class _AddSpotBottomSheetState extends State<AddSpotBottomSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'food';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _durationController.dispose();
    _notesController.dispose();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Spot', style: Theme.of(context).textTheme.headlineMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _label('Spot Name'),
                TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'e.g. Ichiran Ramen')),
                const SizedBox(height: 16),
                _label('Address'),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(hintText: 'Search or enter address', prefixIcon: Icon(Icons.search, size: 20)),
                ),
                const SizedBox(height: 16),
                _label('Category'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SpotCategory.values.map((cat) {
                      final isSelected = cat.value == _category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _category = cat.value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.categoryColor(cat).withValues(alpha: 0.1) : AppColors.surfaceDim,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.categoryColor(cat) : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? AppColors.categoryColor(cat) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Opening Hours'),
                TextField(controller: _hoursController, decoration: const InputDecoration(hintText: 'e.g. 09:00 - 22:00')),
                const SizedBox(height: 16),
                _label('Estimated Duration'),
                DropdownButtonFormField<String>(
                  initialValue: _durationController.text.isEmpty ? null : _durationController.text,
                  decoration: const InputDecoration(hintText: 'Select duration'),
                  items: ['30m', '1h', '1.5h', '2h', '2.5h', '3h', '4h', '5h+'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _durationController.text = v ?? ''),
                ),
                const SizedBox(height: 16),
                _label('Notes (optional)'),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(hintText: 'Any tips or reminders...'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _addSpot,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add Spot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    );
  }

  void _addSpot() {
    if (_nameController.text.trim().isEmpty) return;
    context.read<TripDetailBloc>().add(TripDetailSpotAdded(
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      category: _category,
      openingHours: _hoursController.text.trim().isEmpty ? null : _hoursController.text.trim(),
      estimatedDuration: _durationController.text.isEmpty ? null : _durationController.text,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    ));
    Navigator.pop(context);
  }
}
