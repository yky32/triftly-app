import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/utils/date_formatters.dart';
import 'trip_inline_empty_card.dart';

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
    TripEmptySuggestion(emoji: '🍜', label: 'Breakfast', value: 'food'),
    TripEmptySuggestion(emoji: '🏯', label: 'Sightseeing', value: 'attraction'),
    TripEmptySuggestion(emoji: '🛍️', label: 'Shopping', value: 'shopping'),
    TripEmptySuggestion(emoji: '☕', label: 'Cafe', value: 'food'),
  ];

  @override
  Widget build(BuildContext context) {
    return TripInlineEmptyCard(
      leadingEmoji: '📍',
      title: readOnly ? 'No stops scheduled' : 'No spots yet',
      subtitle: readOnly
          ? '${day.displayTitleLine} · ${DateFormatters.weekdayDate(day.date)}'
          : '${day.displayTitleLine} · ${DateFormatters.weekdayDate(day.date)}',
      readOnly: readOnly,
      suggestions: _suggestions,
      onSuggestionTap: readOnly
          ? null
          : (value) {
              if (value != null && onAddSuggestion != null) {
                onAddSuggestion!(value);
              } else {
                onAddSpot?.call();
              }
            },
      actionLabel: readOnly ? null : 'Add spot',
      onAction: readOnly ? null : onAddSpot,
    );
  }
}
