import 'package:flutter/material.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

class DefaultCurrencyBottomSheet extends StatelessWidget {
  const DefaultCurrencyBottomSheet({required this.selected, super.key});

  final String selected;

  static Future<void> show(BuildContext context, {required String selected}) {
    return TriftlyBottomSheet.show(
      context,
      child: DefaultCurrencyBottomSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(
            title: 'Default currency',
            caption: 'Used for global Spend hints',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < CurrencyOptions.all.length; i++) ...[
                  _CurrencyRow(
                    option: CurrencyOptions.all[i],
                    selected: selected == CurrencyOptions.all[i].code,
                    onTap: () async {
                      await AppBootstrap.userSession
                          .setDefaultCurrency(CurrencyOptions.all[i].code);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  if (i < CurrencyOptions.all.length - 1) const SheetSoftListDivider(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CurrencyOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SheetOptionRow(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Center(child: Text(option.flag, style: const TextStyle(fontSize: 22, height: 1))),
      ),
      title: option.code,
      subtitle: '${option.symbol} · ${option.label}',
      selected: selected,
      onTap: onTap,
    );
  }
}
