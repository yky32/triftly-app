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
import '../../../../core/utils/currency_conversion.dart';
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
    this.initialDayId,
    super.key,
  });

  final Trip trip;
  final Expense? editExpense;
  final String? prefillTitle;
  final String? prefillCategory;
  final String? initialDayId;

  static Future<void> show(
    BuildContext context, {
    required Trip trip,
    required TripDetailBloc bloc,
    Expense? editExpense,
    String? prefillTitle,
    String? prefillCategory,
    String? initialDayId,
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
          initialDayId: initialDayId,
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
  final _configControllers = <String, TextEditingController>{};
  String? _paidById;
  final Set<String> _splitBuddyIds = {};
  String _category = 'food';
  String? _selectedDayId;
  String _expenseCurrency = 'USD';
  SplitType _splitType = SplitType.equal;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editExpense != null;

  String get _currency => _expenseCurrency;

  String get _tripCurrency => widget.trip.defaultCurrency;

  String get _currencySymbol =>
      CurrencyOptions.find(_currency)?.symbol ?? _currency;

  @override
  void initState() {
    super.initState();
    _expenseCurrency = widget.trip.defaultCurrency;
    final expense = widget.editExpense;
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = CurrencyUtils.formatDecimal(expense.amount);
      _expenseCurrency = expense.currency;
      _paidById = expense.paidById;
      _splitBuddyIds.addAll(expense.splits.map((s) => s.buddyId));
      _category = expense.category;
      _selectedDayId = expense.dayId;
      if (expense.splits.isNotEmpty) {
        _splitType = expense.splits.first.splitType;
        for (final split in expense.splits) {
          final controller = TextEditingController(
            text: split.splitConfigValue != null
                ? CurrencyUtils.formatDecimal(split.splitConfigValue!)
                : (_splitType == SplitType.equal
                    ? ''
                    : CurrencyUtils.formatDecimal(split.shareAmount)),
          );
          _configControllers[split.buddyId] = controller;
        }
      }
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
        _selectedDayId = widget.initialDayId ??
            bloc.state.days[bloc.state.selectedDayIndex].id;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final controller in _configControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _configControllerFor(String buddyId) {
    return _configControllers.putIfAbsent(
      buddyId,
      () => TextEditingController(
        text: _defaultConfigValue(buddyId),
      ),
    );
  }

  String _defaultConfigValue(String buddyId) {
    if (!_splitBuddyIds.contains(buddyId)) return '';
    switch (_splitType) {
      case SplitType.equal:
        return '';
      case SplitType.percent:
        if (_splitBuddyIds.isEmpty) return '';
        final even = (Decimal.fromInt(100) / Decimal.fromInt(_splitBuddyIds.length))
            .toDecimal(scaleOnInfinitePrecision: 2);
        return CurrencyUtils.formatDecimal(even);
      case SplitType.amount:
        return '';
      case SplitType.share:
        return '1';
    }
  }

  void _ensureConfigControllers() {
    for (final buddy in widget.trip.buddies) {
      _configControllerFor(buddy.id);
    }
    final stale = _configControllers.keys
        .where((id) => !_splitBuddyIds.contains(id))
        .toList();
    for (final id in stale) {
      _configControllers.remove(id)?.dispose();
    }
  }

  List<SplitBuddyInput> _splitInputs() {
    return _splitBuddyIds.map((buddyId) {
      final configText = _configControllers[buddyId]?.text.trim() ?? '';
      Decimal? configValue;
      if (_splitType != SplitType.equal && configText.isNotEmpty) {
        configValue = Decimal.tryParse(configText);
      }
      return SplitBuddyInput(
        buddyId: buddyId,
        splitType: _splitType,
        configValue: configValue,
      );
    }).toList();
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      _paidById != null &&
      _splitBuddyIds.isNotEmpty;

  String get _splitTypeHelper => switch (_splitType) {
        SplitType.equal => 'Everyone pays the same share',
        SplitType.percent => 'Percents must add up to 100%',
        SplitType.amount => 'Fixed amounts must not exceed total',
        SplitType.share => 'Split by ratio (e.g. 2 shares vs 1)',
      };

  bool _splitPreviewIsError(String preview) =>
      preview.startsWith('Fixed amounts') ||
      preview.startsWith('Percents') ||
      preview == 'Select at least one person';

  String? get _splitPreview {
    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null || amount <= Decimal.zero || _splitBuddyIds.isEmpty) {
      return null;
    }

    final validation = SplitCalculator.validateInputs(
      totalAmount: amount,
      entries: _splitInputs(),
    );
    if (validation != null) return validation;

    final shares = SplitCalculator.calculateShares(
      totalAmount: amount,
      entries: _splitInputs(),
    );
    if (shares.isEmpty) return null;

    final uniqueShares = shares.values.toSet();
    if (uniqueShares.length == 1) {
      return '$_currencySymbol${CurrencyUtils.formatDecimal(uniqueShares.first)} each · ${_splitBuddyIds.length} people';
    }
    return 'Split across ${_splitBuddyIds.length} people';
  }

  String? get _conversionPreview {
    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null || amount <= Decimal.zero) return null;
    return CurrencyConversion.tripEquivalentLabel(
      amount: amount,
      currency: _expenseCurrency,
      tripCurrency: _tripCurrency,
    );
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
          const SheetSectionHeader(title: 'Amount'),
          const SizedBox(height: AppSpacing.md),
          SheetGradientHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetCurrencyChipPicker(
                  selected: _expenseCurrency,
                  onSelected: (code) {
                    HapticFeedback.selectionClick();
                    setState(() => _expenseCurrency = code);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SheetNumericHeroField(
                  leadingAffix: _currencySymbol,
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: () => setState(() {}),
                ),
                if (_conversionPreview case final preview?) ...[
                  const SizedBox(height: AppSpacing.md),
                  SheetResultBanner(caption: 'Trip currency', text: preview),
                ],
              ],
            ),
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
            SheetSectionHeader(title: 'Split', caption: _splitTypeHelper),
            const SizedBox(height: AppSpacing.md),
            _SplitTypePicker(
              selected: _splitType,
              onSelected: (type) {
                HapticFeedback.selectionClick();
                setState(() {
                  _splitType = type;
                  _ensureConfigControllers();
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SheetSoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SplitFieldLabel(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Paid by',
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
                  Row(
                    children: [
                      Expanded(
                        child: _SplitFieldLabel(
                          icon: Icons.group_outlined,
                          label: 'Split between',
                        ),
                      ),
                      if (_splitBuddyIds.length < widget.trip.buddies.length)
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _splitBuddyIds
                                ..clear()
                                ..addAll(widget.trip.buddies.map((b) => b.id));
                              _ensureConfigControllers();
                            });
                          },
                          icon: const Icon(Icons.select_all_rounded, size: 16),
                          label: const Text('Everyone'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
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
                        _ensureConfigControllers();
                      });
                    },
                  ),
                  if (_splitType != SplitType.equal && _splitBuddyIds.isNotEmpty) ...[
                    const SheetSoftDivider(),
                    ..._splitBuddyIds.map((buddyId) {
                      final buddy =
                          widget.trip.buddies.firstWhere((b) => b.id == buddyId);
                      final controller = _configControllerFor(buddyId);
                      return _SplitConfigRow(
                        buddy: buddy,
                        splitType: _splitType,
                        currencySymbol: _currencySymbol,
                        controller: controller,
                        onChanged: () => setState(() {}),
                      );
                    }),
                  ],
                  if (_splitPreview case final preview?) ...[
                    const SizedBox(height: AppSpacing.md),
                    _SplitPreviewBanner(
                      text: preview,
                      isError: _splitPreviewIsError(preview),
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

    final validation = SplitCalculator.validateInputs(
      totalAmount: amount,
      entries: _splitInputs(),
    );
    if (validation != null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final bloc = context.read<TripDetailBloc>();
    final expenseId = widget.editExpense?.id ?? const Uuid().v4();
    final shares = SplitCalculator.calculateShares(
      totalAmount: amount,
      entries: _splitInputs(),
    );

    final expense = Expense(
      id: expenseId,
      tripId: widget.trip.id,
      dayId: _selectedDayId,
      title: _titleController.text.trim(),
      amount: amount,
      currency: _expenseCurrency,
      paidById: _paidById!,
      category: _category,
      splits: _splitBuddyIds.map((id) {
        final configText = _configControllers[id]?.text.trim() ?? '';
        final configValue =
            _splitType == SplitType.equal ? null : Decimal.tryParse(configText);
        return ExpenseSplit(
          id: const Uuid().v4(),
          expenseId: expenseId,
          buddyId: id,
          splitType: _splitType,
          shareAmount: shares[id] ?? Decimal.zero,
          splitConfigValue: configValue,
        );
      }).toList(),
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

class _SplitTypePicker extends StatelessWidget {
  const _SplitTypePicker({
    required this.selected,
    required this.onSelected,
  });

  final SplitType selected;
  final ValueChanged<SplitType> onSelected;

  static const _options = [
    (SplitType.equal, Icons.horizontal_split_rounded, 'Equal'),
    (SplitType.percent, Icons.percent_rounded, 'Percent'),
    (SplitType.amount, Icons.payments_outlined, 'Amount'),
    (SplitType.share, Icons.pie_chart_outline_rounded, 'Shares'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (type, icon, label) = _options[index];
          return _IconTextChip(
            icon: icon,
            label: label,
            isSelected: selected == type,
            onTap: () => onSelected(type),
          );
        },
      ),
    );
  }
}

class _SplitFieldLabel extends StatelessWidget {
  const _SplitFieldLabel({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}

class _SplitConfigRow extends StatelessWidget {
  const _SplitConfigRow({
    required this.buddy,
    required this.splitType,
    required this.currencySymbol,
    required this.controller,
    required this.onChanged,
  });

  final Buddy buddy;
  final SplitType splitType;
  final String currencySymbol;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final suffix = switch (splitType) {
      SplitType.percent => '%',
      SplitType.amount => currencySymbol,
      SplitType.share => 'shares',
      SplitType.equal => '',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          _BuddyAvatar(name: buddy.name, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              buddy.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 104,
            child: SheetInlineField(
              controller: controller,
              hint: suffix,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitPreviewBanner extends StatelessWidget {
  const _SplitPreviewBanner({
    required this.text,
    required this.isError,
  });

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isError ? AppColors.error : AppColors.primaryDark;
    final bg = isError
        ? AppColors.error.withValues(alpha: isDark ? 0.18 : 0.08)
        : AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.receipt_long_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyAvatar extends StatelessWidget {
  const _BuddyAvatar({
    required this.name,
    this.size = 24,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
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
          return _BuddyChip(
            name: buddy.name,
            isSelected: selectedIds.contains(buddy.id),
            onTap: () => onSelected(buddy.id),
          );
        },
      ),
    );
  }
}

class _BuddyChip extends StatelessWidget {
  const _BuddyChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
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
        padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.md, 0),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BuddyAvatar(name: name, size: 22),
            const SizedBox(width: AppSpacing.xs),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.primaryDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconTextChip extends StatelessWidget {
  const _IconTextChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
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
