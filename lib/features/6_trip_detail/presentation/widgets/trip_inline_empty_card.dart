import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
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

/// Inline empty placeholder for Plan day slots.
class TripInlineEmptyCard extends StatelessWidget {
  const TripInlineEmptyCard({
    required this.title,
    this.icon = Icons.place_outlined,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.onAction,
    this.readOnly = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final List<TripEmptySuggestion> suggestions;
  final ValueChanged<String?>? onSuggestionTap;
  final VoidCallback? onAction;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: EmptyStateIconWell(icon: icon, compact: true)),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
            height: 1.2,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (!readOnly && suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 36,
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
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
