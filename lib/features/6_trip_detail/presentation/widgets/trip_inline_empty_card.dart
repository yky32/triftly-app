import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
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

/// Compact inline empty placeholder for Plan / Spend day slots.
class TripInlineEmptyCard extends StatelessWidget {
  const TripInlineEmptyCard({
    required this.leadingEmoji,
    required this.title,
    required this.subtitle,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.actionLabel,
    this.onAction,
    this.readOnly = false,
    super.key,
  });

  final String leadingEmoji;
  final String title;
  final String subtitle;
  final List<TripEmptySuggestion> suggestions;
  final ValueChanged<String?>? onSuggestionTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Text(leadingEmoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!readOnly && suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Quick ideas',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
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
            const SizedBox(height: AppSpacing.md),
            Pressable(
              onTap: onAction,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      actionLabel!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
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
          borderRadius: BorderRadius.circular(AppRadii.md),
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
