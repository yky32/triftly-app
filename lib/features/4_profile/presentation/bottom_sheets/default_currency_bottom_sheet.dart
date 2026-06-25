import 'package:flutter/material.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/constants/currency_options.dart';
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
          const SizedBox(height: 12),
          SheetSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < CurrencyOptions.all.length; i++) ...[
                  ListTile(
                    leading: Text(CurrencyOptions.all[i].flag, style: const TextStyle(fontSize: 22)),
                    title: Text(CurrencyOptions.all[i].code),
                    subtitle: Text(CurrencyOptions.all[i].label),
                    trailing: selected == CurrencyOptions.all[i].code
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () async {
                      await AppBootstrap.userSession
                          .setDefaultCurrency(CurrencyOptions.all[i].code);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  if (i < CurrencyOptions.all.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
