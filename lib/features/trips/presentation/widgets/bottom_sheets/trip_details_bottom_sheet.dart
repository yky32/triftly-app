  import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/data/routine_repository.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet shown when the user taps a saved trip card.
///
/// Displays trip details and gives the user two choices:
///   • **Open in Routine Builder** – navigates to the routine tab and loads
///     the selected trip (replacing any current routine).
///   • **Dismiss** – closes the sheet, staying on the Trips page.
class TripDetailsBottomSheet extends StatelessWidget {
  const TripDetailsBottomSheet({super.key, required this.trip});

  final SavedTripSummary trip;

  static Future<void> show(BuildContext context, SavedTripSummary trip) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripDetailsBottomSheet(trip: trip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final localizations = MaterialLocalizations.of(context);
    final startLabel = localizations.formatShortDate(trip.startDate);
    final endLabel = localizations.formatShortDate(trip.endDate);
    final dateLabel = trip.startDate == trip.endDate
        ? startLabel
        : '$startLabel – $endLabel';
    final daysCount = trip.endDate.difference(trip.startDate).inDays + 1;
    final dayLabel = daysCount == 1 ? '1 day' : '$daysCount days';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BottomSheetDragHandle(),

          // ── Banner ────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.deepTeal, AppColors.driftTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // decorative circles
                  Positioned(
                    right: -28,
                    top: -28,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -18,
                    bottom: -28,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.terrain_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  // days pill
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        dayLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Trip name ─────────────────────────────────────────────────
          Text(
            trip.name.trim().isEmpty ? 'Untitled trip' : trip.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // ── Meta rows ─────────────────────────────────────────────────
          _DetailRow(
            icon: Icons.place_rounded,
            iconColor: AppColors.driftTeal,
            label: trip.countries.isEmpty
                ? 'No country'
                : trip.countries.join(', '),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.date_range_rounded,
            iconColor: AppColors.softAmber,
            label: dateLabel,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.calmGreen,
            label: dayLabel,
          ),

          const SizedBox(height: 28),

          // ── Primary CTA: open in routine builder ──────────────────────
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepTeal, AppColors.driftTeal],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton.icon(
                onPressed: () => _openInRoutineBuilder(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_calendar_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Open in Routine Builder',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Secondary CTA: dismiss ────────────────────────────────────
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: Text(
              'Close',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dismisses the sheet, navigates to the Routine tab, and fires [TripSelected]
  /// on the existing [RoutineBuilderBloc] so the trip is loaded immediately.
  void _openInRoutineBuilder(BuildContext context) {
    Navigator.of(context).pop();
    // Navigate to the Routine tab via go_router named route.
    context.goNamed(AppPage.routine.name);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
