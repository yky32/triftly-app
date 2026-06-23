import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/split_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/swipe_to_confirm.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../bloc/trip_detail_bloc.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({
    required this.trip,
    this.editExpense,
    this.prefillTitle,
    this.prefillCategory,
    super.key,
  });

  final Trip trip;
  final Expense? editExpense;
  final String? prefillTitle;
  final String? prefillCategory;

  static Future<void> show(
    BuildContext context, {
    required Trip trip,
    required TripDetailBloc bloc,
    Expense? editExpense,
    String? prefillTitle,
    String? prefillCategory,
  }) {
    return TriftlyBottomSheet.show(
      context,
      child: BlocProvider.value(
        value: bloc,
        child: AddExpenseBottomSheet(
          trip: trip,
          editExpense: editExpense,
          prefillTitle: prefillTitle,
          prefillCategory: prefillCategory,
        ),
      ),
    );
  }

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _paidById;
  final Set<String> _splitBuddyIds = {};
  String _category = 'food';
  String? _selectedDayId;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editExpense != null;

  String get _currency => widget.trip.defaultCurrency;

  String get _currencySymbol =>
      CurrencyOptions.find(_currency)?.symbol ?? _currency;

  @override
  void initState() {
    super.initState();
    final expense = widget.editExpense;
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = CurrencyUtils.formatDecimal(expense.amount);
      _paidById = expense.paidById;
      _splitBuddyIds.addAll(expense.splits.map((s) => s.buddyId));
      _category = expense.category;
      _selectedDayId = expense.dayId;
      return;
    }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<TripDetailBloc>();
      if (bloc.state.days.isEmpty) return;
      setState(() {
        _selectedDayId = bloc.state.days[bloc.state.selectedDayIndex].id;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      _paidById != null &&
      _splitBuddyIds.isNotEmpty;

  String? get _splitPreview {
    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null || amount <= Decimal.zero || _splitBuddyIds.isEmpty) {
      return null;
    }

    final shares = SplitCalculator.equalSplit(
      totalAmount: amount,
      buddyIds: _splitBuddyIds.toList(),
    );
    if (shares.isEmpty) return null;

    final uniqueShares = shares.values.toSet();
    if (uniqueShares.length == 1) {
      return '$_currencySymbol${CurrencyUtils.formatDecimal(uniqueShares.first)} each · ${_splitBuddyIds.length} people';
    }
    return 'Split across ${_splitBuddyIds.length} people';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<TripDetailBloc>();
    final days = bloc.state.days;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetSectionHeader(
            title: _isEditing ? 'Edit expense' : 'Add expense',
            caption: _isEditing ? 'Update amount or split' : 'Track group spending',
          ),
          const SizedBox(height: AppSpacing.lg),
          SheetHeroField(
            label: 'What for?',
            hint: 'Lunch at Ichiran',
            controller: _titleController,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          SheetNumericHeroField(
            label: 'Amount',
            leadingAffix: _currencySymbol,
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: () => setState(() {}),
          ),
          if (days.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const SheetSectionHeader(title: 'Day'),
            const SizedBox(height: AppSpacing.md),
            _DayPicker(
              days: days,
              selectedDayId: _selectedDayId,
              onSelected: (dayId) {
                HapticFeedback.selectionClick();
                setState(() => _selectedDayId = dayId);
              },
            ),
          ],
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
          if (widget.trip.buddies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const SheetSectionHeader(title: 'Split', caption: 'Equal split'),
            const SizedBox(height: AppSpacing.md),
            SheetSoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Paid by',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BuddyPicker(
                    buddies: widget.trip.buddies,
                    selectedIds: _paidById == null ? const {} : {_paidById!},
                    onSelected: (id) {
                      HapticFeedback.selectionClick();
                      setState(() => _paidById = id);
                    },
                  ),
                  const SheetSoftDivider(),
                  Text(
                    'Split between',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BuddyPicker(
                    buddies: widget.trip.buddies,
                    selectedIds: _splitBuddyIds,
                    onSelected: (id) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_splitBuddyIds.contains(id)) {
                          if (_splitBuddyIds.length > 1) {
                            _splitBuddyIds.remove(id);
                          }
                        } else {
                          _splitBuddyIds.add(id);
                        }
                      });
                    },
                  ),
                  if (_splitPreview case final preview?) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      preview,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          SwipeToConfirm(
            label: _isEditing ? 'Slide to save expense' : 'Slide to add expense',
            enabled: _canSubmit && !_isSubmitting,
            onConfirmed: _submitExpense,
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (!_canSubmit || _isSubmitting || _paidById == null) return;
    setState(() => _isSubmitting = true);

    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null || amount <= Decimal.zero || _splitBuddyIds.isEmpty) {
      setState(() => _isSubmitting = false);
      return;
    }

    final bloc = context.read<TripDetailBloc>();
    final expenseId = widget.editExpense?.id ?? const Uuid().v4();
    final shares = SplitCalculator.equalSplit(
      totalAmount: amount,
      buddyIds: _splitBuddyIds.toList(),
    );

    final expense = Expense(
      id: expenseId,
      tripId: widget.trip.id,
      dayId: _selectedDayId,
      title: _titleController.text.trim(),
      amount: amount,
      currency: _currency,
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
      createdAt: widget.editExpense?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      bloc.add(TripDetailExpenseUpdated(expense: expense));
    } else {
      bloc.add(TripDetailExpenseAdded(expense: expense));
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.days,
    required this.selectedDayId,
    required this.onSelected,
  });

  final List<TripDay> days;
  final String? selectedDayId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = day.id == selectedDayId;
          return _TextChip(
            label: 'Day ${day.dayNumber}',
            isSelected: selected,
            onTap: () => onSelected(day.id),
          );
        },
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

class _BuddyPicker extends StatelessWidget {
  const _BuddyPicker({
    required this.buddies,
    required this.selectedIds,
    required this.onSelected,
  });

  final List<Buddy> buddies;
  final Set<String> selectedIds;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: buddies.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final buddy = buddies[index];
          return _TextChip(
            label: buddy.name,
            isSelected: selectedIds.contains(buddy.id),
            onTap: () => onSelected(buddy.id),
          );
        },
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
          borderRadius: BorderRadius.circular(AppRadii.md),
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
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
