import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/split_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../bloc/trip_detail_bloc.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({
    required this.trip,
    this.prefillTitle,
    this.prefillCategory,
    super.key,
  });

  final Trip trip;
  final String? prefillTitle;
  final String? prefillCategory;

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _paidById;
  final Set<String> _splitBuddyIds = {};
  String _category = 'food';

  @override
  void initState() {
    super.initState();
    if (widget.prefillTitle != null) {
      _titleController.text = widget.prefillTitle!;
    }
    if (widget.prefillCategory != null) {
      _category = widget.prefillCategory!;
    }
    if (widget.trip.buddies.isNotEmpty) {
      _paidById = widget.trip.buddies.first.id;
      _splitBuddyIds.addAll(widget.trip.buddies.map((b) => b.id));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _titleController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty &&
        _paidById != null &&
        _splitBuddyIds.isNotEmpty;

    return SheetScaffold(
      title: 'Add Expense',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('What did you spend on?'),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'e.g. Lunch at Ichiran'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Amount'),
          TextField(
            controller: _amountController,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0',
              prefixText: '${widget.trip.defaultCurrency} ',
            ),
          ),
          if (widget.trip.buddies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _label('Paid by'),
            Wrap(
              spacing: AppSpacing.sm,
              children: widget.trip.buddies.map((buddy) {
                final selected = _paidById == buddy.id;
                return ChoiceChip(
                  label: Text(buddy.name),
                  selected: selected,
                  onSelected: (_) => setState(() => _paidById = buddy.id),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _label('Split between'),
            Wrap(
              spacing: AppSpacing.sm,
              children: widget.trip.buddies.map((buddy) {
                final selected = _splitBuddyIds.contains(buddy.id);
                return FilterChip(
                  label: Text(buddy.name),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _splitBuddyIds.add(buddy.id);
                      } else if (_splitBuddyIds.length > 1) {
                        _splitBuddyIds.remove(buddy.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _label('Category'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SpotCategory.values.map((cat) {
                final isSelected = cat.value == _category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text('${cat.emoji} ${cat.label}'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _category = cat.value),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: canSubmit ? _addExpense : null,
            child: const Text('Add Expense'),
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

  void _addExpense() {
    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null || _paidById == null || _splitBuddyIds.isEmpty) return;

    final expenseId = const Uuid().v4();
    final shares = SplitCalculator.equalSplit(
      totalAmount: amount,
      buddyIds: _splitBuddyIds.toList(),
    );

    final dayId = context.read<TripDetailBloc>().state.days.isNotEmpty
        ? context.read<TripDetailBloc>().state.days[context.read<TripDetailBloc>().state.selectedDayIndex].id
        : null;

    context.read<TripDetailBloc>().add(
          TripDetailExpenseAdded(
            expense: Expense(
              id: expenseId,
              tripId: widget.trip.id,
              dayId: dayId,
              title: _titleController.text.trim(),
              amount: amount,
              currency: widget.trip.defaultCurrency,
              paidById: _paidById!,
              category: _category,
              splits: _splitBuddyIds
                  .map(
                    (id) => ExpenseSplit(
                      id: const Uuid().v4(),
                      expenseId: expenseId,
                      buddyId: id,
                      splitType: SplitType.equal,
                      shareAmount: shares[id] ?? Decimal.zero,
                    ),
                  )
                  .toList(),
              createdAt: DateTime.now(),
            ),
          ),
        );
    Navigator.pop(context);
  }
}
