import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Consistent modal bottom sheet chrome: drag handle, title, close, scroll body.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    required this.title,
    required this.child,
    this.onClose,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadii.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.sm, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose ?? () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl + bottomInset,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
