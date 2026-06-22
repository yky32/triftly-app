import 'package:flutter/material.dart';
import '../models/trip_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/date_formatters.dart';
import 'app_card.dart';

/// Outbound (blue) / return (orange) flight styling shared with create-trip sheet.
class FlightDirectionBadge extends StatelessWidget {
  const FlightDirectionBadge({required this.isOutbound, super.key});

  final bool isOutbound;

  static const outboundBlue = Color(0xFF0369A1);
  static const outboundBlueLight = Color(0xFFE0F2FE);
  static const outboundBlueDark = Color(0xFF7DD3FC);
  static const returnOrange = Color(0xFFC2410C);
  static const returnOrangeLight = Color(0xFFFFEDD5);
  static const returnOrangeDark = Color(0xFFFDBA74);

  static Color accentFor(bool isOutbound, bool isDark) =>
      isOutbound ? (isDark ? outboundBlueDark : outboundBlue) : (isDark ? returnOrangeDark : returnOrange);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentFor(isOutbound, isDark);
    final bg = isOutbound
        ? outboundBlueLight.withValues(alpha: isDark ? 0.22 : 0.85)
        : returnOrangeLight.withValues(alpha: isDark ? 0.22 : 0.85);

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(
        isOutbound ? Icons.flight_takeoff_rounded : Icons.flight_land_rounded,
        size: 16,
        color: color,
      ),
    );
  }
}

/// Read-only flight card for Plan tab arrival / departure days.
class FlightLegCard extends StatelessWidget {
  const FlightLegCard({
    required this.isOutbound,
    required this.leg,
    super.key,
  });

  final bool isOutbound;
  final FlightLeg leg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = FlightDirectionBadge.accentFor(isOutbound, isDark);
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final label = isOutbound ? 'Outbound flight' : 'Return flight';

    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.md)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlightDirectionBadge(isOutbound: isOutbound),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tertiary),
                          ),
                          if (leg.flightNumber != null && leg.flightNumber!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              leg.flightNumber!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: primary,
                                  ),
                            ),
                          ],
                          if (leg.fromAirport != null &&
                              leg.fromAirport!.isNotEmpty &&
                              leg.toAirport != null &&
                              leg.toAirport!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${leg.fromAirport} → ${leg.toAirport}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ],
                          if (leg.departAt != null) ...[
                            const SizedBox(height: 6),
                            _FlightDepartTime(date: leg.departAt!, accent: accent),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact flight row for Trip Detail summary.
class FlightLegSummaryRow extends StatelessWidget {
  const FlightLegSummaryRow({
    required this.isOutbound,
    required this.leg,
    super.key,
  });

  final bool isOutbound;
  final FlightLeg leg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = FlightDirectionBadge.accentFor(isOutbound, isDark);
    final label = isOutbound ? 'Outbound' : 'Return';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            FlightDirectionBadge(isOutbound: isOutbound),
            Text(
              '$label · ${flightLegCompactLabel(leg)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent.withValues(alpha: 0.95)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String flightLegCompactLabel(FlightLeg leg) {
  final parts = <String>[
    if (leg.flightNumber != null && leg.flightNumber!.isNotEmpty) leg.flightNumber!,
    if (leg.fromAirport != null && leg.toAirport != null) '${leg.fromAirport} → ${leg.toAirport}',
    if (leg.departAt != null) DateFormatters.shortDate(leg.departAt!),
  ];
  return parts.join(' · ');
}

class _FlightDepartTime extends StatelessWidget {
  const _FlightDepartTime({required this.date, required this.accent});

  final DateTime date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdayLine = '${months[date.month - 1]} ${date.day} ${weekdays[date.weekday - 1]}';

    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Depart $weekdayLine',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: tertiary),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$hour12:$minute',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                height: 1,
                color: accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  height: 1,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
