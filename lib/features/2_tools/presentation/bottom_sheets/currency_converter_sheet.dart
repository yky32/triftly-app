import 'package:flutter/material.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/theme/app_colors.dart';
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

  String _formatResult(double value) {
    if (value >= 1000) {
      final whole = value.round().toString();
      final buffer = StringBuffer();
      for (var i = 0; i < whole.length; i++) {
        if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
        buffer.write(whole[i]);
      }
      return buffer.toString();
    }
    return value >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final fromOption = CurrencyOptions.find(_from)!;
    final toOption = CurrencyOptions.find(_to)!;
    final result = _result;
    final rate = CurrencyRates.convert(amount: 1, from: _from, to: _to);
    final rateLabel = '1 ${fromOption.code} ≈ ${_formatResult(rate)} ${toOption.code}';

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Currency', caption: 'Offline demo rates'),
          const SizedBox(height: AppSpacing.md),
          SheetGradientHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetCurrencyChipPicker(
                  selected: _from,
                  onSelected: (code) => setState(() => _from = code),
                ),
                const SizedBox(height: AppSpacing.md),
                SheetNumericHeroField(
                  label: 'You pay',
                  leadingAffix: fromOption.symbol,
                  controller: _amountController,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SwapRow(onSwap: _swap, rateLabel: rateLabel),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'You get'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetCurrencyChipPicker(
                  selected: _to,
                  onSelected: (code) => setState(() => _to = code),
                ),
                const SizedBox(height: AppSpacing.md),
                SheetResultBanner(
                  caption: toOption.code,
                  text: result == null ? '—' : '${toOption.symbol}${_formatResult(result)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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

class _SwapRow extends StatelessWidget {
  const _SwapRow({required this.onSwap, required this.rateLabel});

  final VoidCallback onSwap;
  final String rateLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            children: [
              Pressable(
                onTap: onSwap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted.withValues(alpha: isDark ? 0.35 : 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                rateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ],
    );
  }
}
