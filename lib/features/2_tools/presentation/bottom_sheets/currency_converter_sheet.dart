import 'package:flutter/material.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_rates.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';

class CurrencyConverterSheet extends StatefulWidget {
  const CurrencyConverterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const CurrencyConverterSheet(),
    );
  }

  @override
  State<CurrencyConverterSheet> createState() => _CurrencyConverterSheetState();
}

class _CurrencyConverterSheetState extends State<CurrencyConverterSheet> {
  String _from = 'HKD';
  String _to = 'JPY';
  final _amountController = TextEditingController(text: '100');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  double? get _result {
    final amount = _amount;
    if (amount == null) return null;
    return CurrencyRates.convert(amount: amount, from: _from, to: _to);
  }

  void _swap() => setState(() {
        final temp = _from;
        _from = _to;
        _to = temp;
      });

  @override
  Widget build(BuildContext context) {
    final fromOption = CurrencyOptions.find(_from)!;
    final toOption = CurrencyOptions.find(_to)!;
    final result = _result;

    return SheetScaffold(
      title: 'Currency',
      subtitle: 'Offline demo rates',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CurrencyRow(
                  label: 'From',
                  code: _from,
                  option: fromOption,
                  onSelected: (code) => setState(() => _from = code),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: IconButton.filledTonal(
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_vert_rounded),
                    tooltip: 'Swap currencies',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CurrencyRow(
                  label: 'To',
                  code: _to,
                  option: toOption,
                  onSelected: (code) => setState(() => _to = code),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Text(
                    result == null
                        ? 'Enter an amount'
                        : '${toOption.symbol} ${result.toStringAsFixed(result >= 100 ? 0 : 2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Rates are approximate for travel planning — not for trading.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.label,
    required this.code,
    required this.option,
    required this.onSelected,
  });

  final String label;
  final String code;
  final CurrencyOption option;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: code,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            isDense: true,
          ),
          items: CurrencyOptions.all
              .map(
                (c) => DropdownMenuItem(
                  value: c.code,
                  child: Text('${c.flag} ${c.code} (${c.symbol})'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onSelected(value);
          },
        ),
      ],
    );
  }
}
