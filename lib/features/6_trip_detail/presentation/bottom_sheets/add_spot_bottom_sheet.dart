import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
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
    return SheetScaffold(
      title: 'Add Spot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Spot Name'),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'e.g. Ichiran Ramen'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Address'),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'Search or enter address',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Category'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SpotCategory.values.map((cat) {
                final isSelected = cat.value == _category;
                final color = AppColors.categoryColor(cat);
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.12) : Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(color: isSelected ? color : AppColors.border),
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
                              color: isSelected ? color : AppColors.textSecondary,
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
          const SizedBox(height: AppSpacing.lg),
          _label('Opening Hours'),
          TextField(controller: _hoursController, decoration: const InputDecoration(hintText: 'e.g. 09:00 – 22:00')),
          const SizedBox(height: AppSpacing.lg),
          _label('Estimated Duration'),
          DropdownButtonFormField<String>(
            initialValue: _durationController.text.isEmpty ? null : _durationController.text,
            decoration: const InputDecoration(hintText: 'Select duration'),
            items: ['30m', '1h', '1.5h', '2h', '2.5h', '3h', '4h', '5h+']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => _durationController.text = v ?? ''),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Notes (optional)'),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(hintText: 'Tips or reminders...'),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _nameController.text.trim().isEmpty ? null : _addSpot,
            child: const Text('Add Spot'),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary, fontSize: 13)),
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
