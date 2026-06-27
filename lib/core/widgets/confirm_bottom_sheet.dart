import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'empty_state.dart';
import 'glass_surface.dart';
import 'spend_glass_shell.dart';
import 'swipe_to_confirm.dart';
import 'triftly_bottom_sheet.dart';

/// Liquid-glass confirmation sheet — replaces centered [AlertDialog]s.
abstract final class ConfirmBottomSheet {
  /// Returns `true` when the user swipes to confirm, `false` when dismissed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    bool destructive = false,
    IconData? icon,
    String? swipeLabel,
  }) async {
    final result = await TriftlyBottomSheet.show<bool>(
      context,
      child: _ConfirmBottomSheetBody(
        title: title,
        message: message,
        swipeLabel: swipeLabel ?? 'Slide to ${confirmLabel.toLowerCase()}',
        destructive: destructive,
        icon: icon ??
            (destructive ? Icons.delete_outline_rounded : Icons.info_outline_rounded),
      ),
    );
    return result ?? false;
  }
}

class _ConfirmBottomSheetBody extends StatelessWidget {
  const _ConfirmBottomSheetBody({
    required this.title,
    required this.message,
    required this.swipeLabel,
    required this.destructive,
    required this.icon,
  });

  final String title;
  final String? message;
  final String swipeLabel;
  final bool destructive;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          blur: 28,
          tint: SpendGlassShell.tint(isDark),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              Center(
                child: _ConfirmIconWell(
                  icon: icon,
                  destructive: destructive,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SwipeToConfirm(
                label: swipeLabel,
                style: destructive
                    ? SwipeToConfirmStyle.destructive
                    : SwipeToConfirmStyle.primary,
                onConfirmed: () => _popConfirmed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmIconWell extends StatelessWidget {
  const _ConfirmIconWell({
    required this.icon,
    required this.destructive,
  });

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    if (destructive) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Material(
        color: AppColors.error.withValues(alpha: isDark ? 0.18 : 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, size: 26, color: AppColors.error),
        ),
      );
    }
    return EmptyStateIconWell(icon: icon);
  }
}

/// Pop after the swipe track settles — popping mid-gesture drops the sheet result.
void _popConfirmed(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(true);
  });
}
