import 'package:flutter/material.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_rates.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/triftly_motion.dart';

class CurrencyConverterSheet extends StatefulWidget {
  const CurrencyConverterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return TriftlyBottomSheet.show(context, child: const CurrencyConverterSheet());
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
    final toOption = CurrencyOptions.find(_to)!;
    final result = _result;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Currency', caption: 'Offline demo rates'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('From', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                SheetCurrencyChipPicker(
                  selected: _from,
                  onSelected: (code) => setState(() => _from = code),
                ),
                const SizedBox(height: AppSpacing.md),
                SheetInlineField(
                  controller: _amountController,
                  hint: 'Amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: () => setState(() {}),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Pressable(
                    onTap: _swap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.swap_vert_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('To', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                SheetCurrencyChipPicker(
                  selected: _to,
                  onSelected: (code) => setState(() => _to = code),
                ),
                const SizedBox(height: AppSpacing.md),
                SheetResultBanner(
                  text: result == null
                      ? 'Enter an amount'
                      : '${toOption.symbol} ${result.toStringAsFixed(result >= 100 ? 0 : 2)}',
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
