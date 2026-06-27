import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/spend_glass_shell.dart';
import '../../../../core/widgets/swipe_to_confirm.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

/// Confirms joining a shared trip after the buddy is signed in.
abstract final class JoinTripBottomSheet {
  static Future<bool> show(
    BuildContext context, {
    required String tripName,
  }) async {
    final result = await TriftlyBottomSheet.show<bool>(
      context,
      child: _JoinTripBottomSheetBody(tripName: tripName),
    );
    return result ?? false;
  }
}

class _JoinTripBottomSheetBody extends StatelessWidget {
  const _JoinTripBottomSheetBody({required this.tripName});

  final String tripName;

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
              Center(child: EmptyStateIconWell(icon: Icons.flight_rounded)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Join “$tripName”?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You’ll join as a viewer — plan, spend, and map sync to your Trips. '
                'The owner can promote you to editor later.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SwipeToConfirm(
                label: 'Slide to join trip',
                style: SwipeToConfirmStyle.primary,
                onConfirmed: () => _popConfirmed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _popConfirmed(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(true);
  });
}
