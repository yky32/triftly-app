import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/spend_glass_shell.dart';
import '../../../../core/widgets/triftly_motion.dart';

class TripEmptySuggestion {
  const TripEmptySuggestion({
    required this.emoji,
    required this.label,
    this.value,
  });

  final String emoji;
  final String label;
  final String? value;
}

/// Inline empty placeholder for Plan day slots — liquid glass shell.
class TripInlineEmptyCard extends StatelessWidget {
  const TripInlineEmptyCard({
    required this.title,
    required this.subtitle,
    this.icon = Icons.place_outlined,
    this.eyebrow,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.actionLabel,
    this.onAction,
    this.readOnly = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? eyebrow;
  final List<TripEmptySuggestion> suggestions;
  final ValueChanged<String?>? onSuggestionTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return SpendGlassShell(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.45,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Center(child: EmptyStateIconWell(icon: icon, compact: true)),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.15,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: muted,
                  fontSize: 13,
                  height: 1.45,
                ),
            textAlign: TextAlign.center,
          ),
          if (!readOnly && suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'QUICK IDEAS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tertiary,
                    fontSize: 11,
                    letterSpacing: 0.45,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return _SuggestionChip(
                    emoji: item.emoji,
                    label: item.label,
                    isDark: isDark,
                    onTap: onSuggestionTap == null
                        ? onAction
                        : () => onSuggestionTap!(item.value),
                  );
                },
              ),
            ),
          ],
          if (!readOnly && onAction != null && actionLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            EmptyStateActionButton(
              label: actionLabel!,
              onPressed: onAction!,
              leading: Icons.add_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.emoji,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          '$emoji $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
