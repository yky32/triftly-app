import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/mapcode_lookup.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_motion.dart';

enum _MapcodeMode { addressToCode, codeToAddress }

class MapcodeFinderSheet extends StatefulWidget {
  const MapcodeFinderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const MapcodeFinderSheet(),
    );
  }

  @override
  State<MapcodeFinderSheet> createState() => _MapcodeFinderSheetState();
}

class _MapcodeFinderSheetState extends State<MapcodeFinderSheet> {
  _MapcodeMode _mode = _MapcodeMode.addressToCode;
  final _queryController = TextEditingController();
  MapcodeResult? _result;
  bool _searched = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _queryController.text;
    final result = _mode == _MapcodeMode.addressToCode
        ? MapcodeLookup.byAddress(query)
        : MapcodeLookup.byMapcode(query);
    setState(() {
      _result = result;
      _searched = true;
    });
    FocusScope.of(context).unfocus();
  }

  void _setMode(_MapcodeMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _result = null;
      _searched = false;
      _queryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SheetScaffold(
      title: 'Mapcode finder',
      subtitle: 'Japan car-nav short codes',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModePicker(mode: _mode, onChanged: _setMode),
          const SizedBox(height: AppSpacing.lg),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _mode == _MapcodeMode.addressToCode ? 'Place or address' : 'Mapcode',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _queryController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: _mode == _MapcodeMode.addressToCode
                        ? 'e.g. Tokyo Tower, Shibuya'
                        : 'e.g. 349 246 831*52',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _search,
                  child: const Text('Look up'),
                ),
              ],
            ),
          ),
          if (_searched) ...[
            const SizedBox(height: AppSpacing.md),
            if (_result != null)
              _ResultCard(result: _result!, showMapcode: _mode == _MapcodeMode.addressToCode)
            else
              SheetSoftCard(
                child: Text(
                  'No match yet. Try a sample like Tokyo Tower or 349 246 831*52.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const SheetSectionHeader(title: 'Try a sample'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: MapcodeLookup.entries.map((entry) {
              return Pressable(
                onTap: () {
                  setState(() {
                    _mode = _MapcodeMode.addressToCode;
                    _queryController.text = entry.label;
                    _result = entry;
                    _searched = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(entry.label, style: Theme.of(context).textTheme.bodySmall),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.mode, required this.onChanged});

  final _MapcodeMode mode;
  final ValueChanged<_MapcodeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'Address → Mapcode',
            selected: mode == _MapcodeMode.addressToCode,
            onTap: () => onChanged(_MapcodeMode.addressToCode),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ModeChip(
            label: 'Mapcode → Address',
            selected: mode == _MapcodeMode.codeToAddress,
            onTap: () => onChanged(_MapcodeMode.codeToAddress),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
              : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.showMapcode});

  final MapcodeResult result;
  final bool showMapcode;

  @override
  Widget build(BuildContext context) {
    final highlight = showMapcode ? result.mapcode : result.address;
    final caption = showMapcode ? 'Mapcode' : 'Address';

    return SheetSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pin_drop_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: highlight));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$caption copied'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          SelectableText(
            highlight,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: showMapcode ? 0.6 : 0,
                ),
          ),
          if (showMapcode) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(result.address, style: Theme.of(context).textTheme.bodySmall),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Text(result.mapcode, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
