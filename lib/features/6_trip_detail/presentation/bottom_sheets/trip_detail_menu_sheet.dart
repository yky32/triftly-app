import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

enum TripDetailMenuAction { edit, delete }

class TripDetailMenuSheet extends StatelessWidget {
  const TripDetailMenuSheet({super.key});

  static Future<TripDetailMenuAction?> show(BuildContext context) {
    return TriftlyBottomSheet.show<TripDetailMenuAction>(
      context,
      child: const TripDetailMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Trip options', caption: 'Manage this trip'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SheetOptionRow(
                  icon: Icons.edit_outlined,
                  title: 'Edit trip',
                  subtitle: 'Name, destination, dates',
                  showCheck: false,
                  onTap: () => Navigator.pop(context, TripDetailMenuAction.edit),
                ),
                const SheetSoftListDivider(),
                SheetOptionRow(
                  icon: Icons.delete_outline,
                  title: 'Delete trip',
                  subtitle: 'Remove from your list',
                  showCheck: false,
                  destructive: true,
                  onTap: () => Navigator.pop(context, TripDetailMenuAction.delete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
