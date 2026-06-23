import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/mapcode_lookup.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/triftly_motion.dart';

enum _MapcodeMode { addressToCode, codeToAddress }

class MapcodeFinderSheet extends StatefulWidget {
  const MapcodeFinderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return TriftlyBottomSheet.show(context, child: const MapcodeFinderSheet());
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

  void _setMode(int index) {
    final mode = index == 0 ? _MapcodeMode.addressToCode : _MapcodeMode.codeToAddress;
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
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Mapcode finder', caption: 'Japan car-nav short codes'),
          const SizedBox(height: AppSpacing.md),
          SheetChoiceChipRow(
            options: const ['Address → Mapcode', 'Mapcode → Address'],
            selectedIndex: _mode == _MapcodeMode.addressToCode ? 0 : 1,
            onSelected: _setMode,
          ),
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
                SheetIconFieldRow(
                  icon: Icons.pin_drop_outlined,
                  field: SheetInlineField(
                    controller: _queryController,
                    hint: _mode == _MapcodeMode.addressToCode
                        ? 'e.g. Tokyo Tower, Shibuya'
                        : 'e.g. 349 246 831*52',
                    textInputAction: TextInputAction.search,
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SheetPrimaryButton(label: 'Look up', onPressed: _search),
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
