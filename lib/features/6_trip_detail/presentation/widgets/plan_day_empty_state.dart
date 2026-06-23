import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/triftly_motion.dart';

/// Inline empty state for a plan day with no spots yet.
class PlanDayEmptyState extends StatelessWidget {
  const PlanDayEmptyState({
    required this.day,
    this.readOnly = false,
    this.onAddSpot,
    this.onAddSuggestion,
    super.key,
  });

  final TripDay day;
  final bool readOnly;
  final VoidCallback? onAddSpot;
  final ValueChanged<String>? onAddSuggestion;

  static const _suggestions = [
    (SpotCategory.food, 'Breakfast'),
    (SpotCategory.attraction, 'Sightseeing'),
    (SpotCategory.shopping, 'Shopping'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return SheetGradientHero(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _EmojiCluster(isDark: isDark)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            readOnly ? 'No stops scheduled' : 'Start planning this day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            readOnly
                ? '${day.displayTitleLine} · ${DateFormatters.weekdayDate(day.date)}'
                : 'Build ${day.displayTitleLine} — ${DateFormatters.weekdayDate(day.date)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
          if (!readOnly) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Quick ideas',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (var i = 0; i < _suggestions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SuggestionChip(
                      emoji: _suggestions[i].$1.emoji,
                      label: _suggestions[i].$2,
                      isDark: isDark,
                      onTap: onAddSuggestion != null
                          ? () => onAddSuggestion!(_suggestions[i].$1.value)
                          : onAddSpot,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (onAddSpot != null)
              Center(
                child: Pressable(
                  onTap: onAddSpot,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          'Add spot',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Check back later for updates.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmojiCluster extends StatelessWidget {
  const _EmojiCluster({required this.isDark});

  final bool isDark;

  static const _sideSize = 44.0;
  static const _centerSize = 52.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _Bubble(emoji: '🍜', size: _sideSize, isDark: isDark),
          ),
          Transform.translate(
            offset: const Offset(-_overlap, 0),
            child: _Bubble(emoji: '🏯', size: _centerSize, isDark: isDark, elevated: true),
          ),
          Transform.translate(
            offset: const Offset(-_overlap * 2, 4),
            child: _Bubble(emoji: '📍', size: _sideSize, isDark: isDark),
          ),
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$emoji $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.emoji,
    required this.size,
    required this.isDark,
    this.elevated = false,
  });

  final String emoji;
  final double size;
  final bool isDark;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: elevated
            ? (isDark ? AppColors.surfaceCardDark : Colors.white)
            : AppColors.primaryMuted.withValues(alpha: isDark ? 0.18 : 0.45),
        shape: BoxShape.circle,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.46)),
    );
  }
}
