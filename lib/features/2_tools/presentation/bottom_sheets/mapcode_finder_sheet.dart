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
    final showMapcode = _mode == _MapcodeMode.addressToCode;

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
          SheetGradientHero(
            child: SheetIconFieldRow(
              icon: Icons.pin_drop_outlined,
              field: SheetInlineField(
                controller: _queryController,
                hint: showMapcode ? 'e.g. Tokyo Tower, Shibuya' : 'e.g. 349 246 831*52',
                textInputAction: TextInputAction.search,
                onChanged: () => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SheetPrimaryButton(label: 'Look up', onPressed: _search),
          if (_searched) ...[
            const SizedBox(height: AppSpacing.xl),
            SheetSectionHeader(
              title: _result == null ? 'No match' : _result!.label,
              caption: _result == null ? 'Try another query' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_result != null)
              _ResultBlock(result: _result!, showMapcode: showMapcode)
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
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Try a sample', caption: 'Optional'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Wrap(
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
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text(
                      entry.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({required this.result, required this.showMapcode});

  final MapcodeResult result;
  final bool showMapcode;

  @override
  Widget build(BuildContext context) {
    final highlight = showMapcode ? result.mapcode : result.address;
    final caption = showMapcode ? 'Mapcode' : 'Address';
    final secondary = showMapcode ? result.address : result.mapcode;

    return SheetSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SheetIconTile(icon: Icons.pin_drop_rounded),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  caption,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
          SheetResultBanner(text: highlight),
          const SizedBox(height: AppSpacing.sm),
          Text(secondary, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
