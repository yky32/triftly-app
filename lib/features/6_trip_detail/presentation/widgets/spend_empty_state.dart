import 'package:flutter/material.dart';
import 'trip_inline_empty_card.dart';

/// Inline empty state for Spend tab when no expenses exist yet.
class SpendEmptyState extends StatelessWidget {
  const SpendEmptyState({
    this.readOnly = false,
    this.onAddExpense,
    super.key,
  });

  final bool readOnly;
  final VoidCallback? onAddExpense;

  static const _suggestions = [
    TripEmptySuggestion(emoji: '🍜', label: 'Meal'),
    TripEmptySuggestion(emoji: '🚃', label: 'Transit'),
    TripEmptySuggestion(emoji: '🛍️', label: 'Shopping'),
    TripEmptySuggestion(emoji: '🏨', label: 'Stay'),
  ];

  @override
  Widget build(BuildContext context) {
    return TripInlineEmptyCard(
      leadingEmoji: '💰',
      title: readOnly ? 'No spending recorded' : 'No expenses yet',
      subtitle: readOnly
          ? 'Expenses will appear here when added.'
          : 'Log meals, transport, and more — split with your group.',
      readOnly: readOnly,
      suggestions: _suggestions,
      onSuggestionTap: readOnly ? null : (_) => onAddExpense?.call(),
      actionLabel: readOnly ? null : 'Add expense',
      onAction: readOnly ? null : onAddExpense,
    );
  }
}
