import 'package:flutter/material.dart';

import '../models/trip_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shown on trip detail when viewing as a joined buddy (viewer or editor).
class SharedTripRoleBanner extends StatelessWidget {
  const SharedTripRoleBanner({required this.trip, super.key});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    if (!trip.isJoinedMember) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isViewer = trip.isViewer;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Material(
        color: (isViewer ? AppColors.textTertiary : AppColors.primary)
            .withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isViewer ? Icons.visibility_outlined : Icons.edit_outlined,
                size: 18,
                color: isViewer ? AppColors.textSecondary : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isViewer
                      ? 'View only — you can see plan, spend, and map but can’t edit.'
                      : 'You can edit plan and spend. Trip settings stay with the owner.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
