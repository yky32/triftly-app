import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/theme/segment_style.dart';
import '../../../../core/widgets/flight_leg_display.dart';

class TripDetailSummary extends StatelessWidget {
  const TripDetailSummary({required this.trip, super.key});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = SegmentStyle.of(trip.phase);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: DateFormatters.dateRange(trip.startDate, trip.endDate),
              ),
              if (trip.buddies.isNotEmpty)
                _InfoChip(
                  icon: Icons.people_outline_rounded,
                  label: '${trip.buddies.length} ${trip.buddies.length == 1 ? 'buddy' : 'buddies'}',
                ),
              _PhaseChip(trip: trip, style: style, isDark: isDark),
            ],
          ),
          if (trip.buddies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _BuddyRow(buddies: trip.buddies),
          ],
          if (_hasFlightInfo) ...[
            const SizedBox(height: AppSpacing.sm),
            ..._flightRows(),
          ],
        ],
      ),
    );
  }

  bool get _hasFlightInfo =>
      (trip.outboundFlight != null && !trip.outboundFlight!.isEmpty) ||
      (trip.returnFlight != null && !trip.returnFlight!.isEmpty);

  List<Widget> _flightRows() {
    final rows = <Widget>[];
    final outbound = trip.outboundFlight;
    if (outbound != null && !outbound.isEmpty) {
      rows.add(FlightLegSummaryRow(isOutbound: true, leg: outbound));
    }
    final returnLeg = trip.returnFlight;
    if (returnLeg != null && !returnLeg.isEmpty) {
      rows.add(FlightLegSummaryRow(isOutbound: false, leg: returnLeg));
    }
    return rows;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.trip, required this.style, required this.isDark});

  final Trip trip;
  final SegmentStyle style;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final label = switch (trip.phase) {
      TripPhase.inProgress => 'Day ${trip.currentDayNumber} of ${trip.numberOfDays}',
      TripPhase.upcoming => trip.daysUntilStart == 0 ? 'Starts today' : 'In ${trip.daysUntilStart} days',
      TripPhase.completed => 'Completed',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.badge(isDark),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.foreground(isDark),
        ),
      ),
    );
  }
}

class _BuddyRow extends StatelessWidget {
  const _BuddyRow({required this.buddies});

  final List<Buddy> buddies;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...buddies.take(6).map(
              (buddy) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: _colorFromHex(buddy.avatarColor ?? '0D9488'),
                  child: Text(
                    buddy.name.isNotEmpty ? buddy.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
        if (buddies.length > 6)
          Text('+${buddies.length - 6}', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Color _colorFromHex(String hex) => Color(int.parse('FF$hex', radix: 16));
}
