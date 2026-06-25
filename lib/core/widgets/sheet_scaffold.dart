import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'swipe_to_confirm.dart';

/// Consistent modal bottom sheet chrome: drag handle, title, scroll body, optional pinned footer.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    this.title,
    required this.child,
    this.footer,
    this.subtitle,
    this.onClose,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.compactBody = false,
    super.key,
  });

  /// Form sheet with [SwipeToConfirm] pinned below the scrollable body.
  ///
  /// Set [compact] for short forms (e.g. sign-in) so the sheet hugs content.
  factory SheetScaffold.swipeForm({
    required Widget child,
    required String swipeLabel,
    required bool swipeEnabled,
    required VoidCallback onSwipeConfirmed,
    Key? swipeKey,
    bool showCloseButton = false,
    bool compact = false,
  }) =>
      SheetScaffold(
        showCloseButton: showCloseButton,
        compactBody: compact,
        footer: SwipeToConfirm(
          key: swipeKey,
          label: swipeLabel,
          enabled: swipeEnabled,
          onConfirmed: onSwipeConfirmed,
        ),
        child: child,
      );

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool showDragHandle;
  final bool compactBody;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9 - viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFooter = footer != null;
    final hugContent = hasFooter && compactBody;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadii.sheet,
        ),
        child: Column(
          mainAxisSize: hugContent ? MainAxisSize.min : (hasFooter ? MainAxisSize.max : MainAxisSize.min),
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
              ),
            if (title != null && title!.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  showDragHandle ? AppSpacing.xs : AppSpacing.sm,
                  showCloseButton ? AppSpacing.sm : AppSpacing.lg,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!, style: Theme.of(context).textTheme.headlineMedium),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: onClose ?? () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
            if (hugContent)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  title != null && title!.isNotEmpty ? AppSpacing.sm : AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: child,
              )
            else if (hasFooter)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    title != null && title!.isNotEmpty ? AppSpacing.sm : AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: child,
                ),
              )
            else
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    title != null && title!.isNotEmpty ? AppSpacing.sm : AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: child,
                ),
              ),
            if (hasFooter)
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
