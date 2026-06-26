import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import 'trip_inline_empty_card.dart';

/// Inline empty state for a plan day with no spots yet.
class PlanDayEmptyState extends StatelessWidget {
  const PlanDayEmptyState({
    required this.day,
    this.readOnly = false,
    this.onAddSuggestion,
    super.key,
  });

  final TripDay day;
  final bool readOnly;
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
      icon: Icons.place_outlined,
      title: readOnly ? 'No stops' : 'No spots',
      readOnly: readOnly,
      suggestions: _suggestions,
      onSuggestionTap: readOnly || onAddSuggestion == null
          ? null
          : (value) {
              if (value != null) onAddSuggestion!(value);
            },
    );
  }
}
