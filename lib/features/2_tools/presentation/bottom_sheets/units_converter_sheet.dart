import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';

enum _UnitKind { distance, temperature, weight }

class UnitsConverterSheet extends StatefulWidget {
  const UnitsConverterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const UnitsConverterSheet(),
    );
  }

  @override
  State<UnitsConverterSheet> createState() => _UnitsConverterSheetState();
}

class _UnitsConverterSheetState extends State<UnitsConverterSheet> {
  _UnitKind _kind = _UnitKind.distance;
  final _inputController = TextEditingController(text: '10');

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

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
      title: 'Units',
      subtitle: 'Common travel conversions',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_UnitKind>(
            segments: const [
              ButtonSegment(value: _UnitKind.distance, label: Text('Distance'), icon: Icon(Icons.straighten_rounded)),
              ButtonSegment(value: _UnitKind.temperature, label: Text('Temp'), icon: Icon(Icons.thermostat_rounded)),
              ButtonSegment(value: _UnitKind.weight, label: Text('Weight'), icon: Icon(Icons.fitness_center_rounded)),
            ],
            selected: {_kind},
            onSelectionChanged: (set) => setState(() => _kind = set.first),
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
                TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    suffixText: conversion.from,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    isDense: true,
                  ),
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
                    conversion.result == null
                        ? 'Enter a value'
                        : '${conversion.result} ${conversion.to}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
