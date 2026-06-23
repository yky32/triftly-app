import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

enum _UnitKind { distance, temperature, weight }

class UnitsConverterSheet extends StatefulWidget {
  const UnitsConverterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return TriftlyBottomSheet.show(context, child: const UnitsConverterSheet());
  }

  @override
  State<UnitsConverterSheet> createState() => _UnitsConverterSheetState();
}

class _UnitsConverterSheetState extends State<UnitsConverterSheet> {
  _UnitKind _kind = _UnitKind.distance;
  final _inputController = TextEditingController(text: '10');

  static const _kindLabels = ['Distance', 'Temp', 'Weight'];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  int get _kindIndex => _UnitKind.values.indexOf(_kind);

  ({String from, String to, String? result}) get _conversion {
    final value = double.tryParse(_inputController.text.trim());
    if (value == null) return (from: '', to: '', result: null);

    return switch (_kind) {
      _UnitKind.distance => (
          from: 'km',
          to: 'mi',
          result: (value * 0.621371).toStringAsFixed(2),
        ),
      _UnitKind.temperature => (
          from: '°C',
          to: '°F',
          result: (value * 9 / 5 + 32).toStringAsFixed(1),
        ),
      _UnitKind.weight => (
          from: 'kg',
          to: 'lb',
          result: (value * 2.20462).toStringAsFixed(2),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final conversion = _conversion;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Units', caption: 'Common travel conversions'),
          const SizedBox(height: AppSpacing.md),
          SheetChoiceChipRow(
            options: _kindLabels,
            selectedIndex: _kindIndex,
            onSelected: (index) => setState(() => _kind = _UnitKind.values[index]),
          ),
          const SizedBox(height: AppSpacing.lg),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  switch (_kind) {
                    _UnitKind.distance => 'Kilometers → Miles',
                    _UnitKind.temperature => 'Celsius → Fahrenheit',
                    _UnitKind.weight => 'Kilograms → Pounds',
                  },
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SheetInlineField(
                        controller: _inputController,
                        hint: 'Value',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        onChanged: () => setState(() {}),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      conversion.from,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SheetResultBanner(
                  text: conversion.result == null
                      ? 'Enter a value'
                      : '${conversion.result} ${conversion.to}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
