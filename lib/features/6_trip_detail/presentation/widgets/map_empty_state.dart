import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/spend_glass_shell.dart';

/// Empty Map tab — glass preview plus inline link to Plan.
class MapEmptyState extends StatelessWidget {
  const MapEmptyState({
    required this.trip,
    this.readOnly = false,
    this.onOpenPlan,
    super.key,
  });

  final Trip trip;
  final bool readOnly;
  final VoidCallback? onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpendGlassShell(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MapPreviewGraphic(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                readOnly ? 'No places mapped' : 'Your map is waiting',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                readOnly
                    ? 'Stops will appear here once added to the plan.'
                    : 'Add spots in Plan and they’ll show up as pins and routes.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: muted,
                ),
                textAlign: TextAlign.center,
              ),
              if (trip.destination.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  trip.destination,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: const [
                  Expanded(child: _FeatureChip(icon: Icons.route_outlined, label: 'Routes')),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: _FeatureChip(icon: Icons.location_on_outlined, label: 'Pins')),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: _FeatureChip(icon: Icons.layers_outlined, label: 'Areas')),
                ],
              ),
            ],
          ),
        ),
        if (!readOnly && onOpenPlan != null) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: EmptyStateActionButton(
              label: 'Open Plan',
              onPressed: onOpenPlan!,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shown when the current day filter has no planned stops.
class MapDayEmptyState extends StatelessWidget {
  const MapDayEmptyState({
    required this.dayLabel,
    this.onOpenPlan,
    super.key,
  });

  final String dayLabel;
  final VoidCallback? onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpendGlassShell(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Nothing on the map yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No stops planned for $dayLabel.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: muted,
                ),
                textAlign: TextAlign.center,
              ),
              if (onOpenPlan != null) ...[
                const SizedBox(height: AppSpacing.lg),
                EmptyStateActionButton(
                  label: 'Open Plan',
                  onPressed: onOpenPlan!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Spots exist but none have map coordinates for the current filter.
class MapUnmappedHero extends StatelessWidget {
  const MapUnmappedHero({
    required this.spotCount,
    required this.scopeLabel,
    super.key,
  });

  final int spotCount;
  final String scopeLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final stopsLabel = '$spotCount ${spotCount == 1 ? 'stop' : 'stops'}';

    return SpendGlassShell(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MapPreviewGraphic(compact: true),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scopeLabel.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.45,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add pins to see your route',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$stopsLabel planned — edit a spot to drop a location.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: 'No pins'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact glass status under the live map.
class MapRouteStatusHeader extends StatelessWidget {
  const MapRouteStatusHeader({
    required this.scopeLabel,
    required this.mappedCount,
    required this.totalCount,
    super.key,
  });

  final String scopeLabel;
  final int mappedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final needsPins = mappedCount < totalCount;

    return SpendGlassShell(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scopeLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        letterSpacing: 0.45,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$mappedCount on map',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (needsPins)
            _StatusBadge(label: '+${totalCount - mappedCount} need pins')
          else
            _StatusBadge(label: 'Route ready', positive: true),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.positive = false});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: positive
            ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1)
            : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: positive
              ? AppColors.primary.withValues(alpha: 0.35)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: positive
                  ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                  : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class MapPreviewGraphic extends StatelessWidget {
  const MapPreviewGraphic({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = compact ? 96.0 : 132.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _MapGridPainter(isDark: isDark),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 28,
                top: compact ? 24 : 36,
                child: _MapPin(tint: AppColors.categoryColor(SpotCategory.food), isDark: isDark),
              ),
              Positioned(
                right: 36,
                top: compact ? 18 : 28,
                child: _MapPin(
                  tint: AppColors.categoryColor(SpotCategory.attraction),
                  isDark: isDark,
                  elevated: true,
                ),
              ),
              Positioned(
                left: 52,
                bottom: compact ? 16 : 24,
                child: _MapPin(tint: AppColors.categoryColor(SpotCategory.shopping), isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.tint,
    required this.isDark,
    this.elevated = false,
  });

  final Color tint;
  final bool isDark;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: elevated ? 34 : 28,
      height: elevated ? 34 : 28,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCardDark : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: tint.withValues(alpha: 0.55), width: elevated ? 2 : 1.5),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: tint.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.location_on_rounded,
        size: elevated ? 18 : 15,
        color: tint,
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = isDark
        ? AppColors.surfaceElevatedDark.withValues(alpha: 0.65)
        : AppColors.primaryMuted.withValues(alpha: 0.22);
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary).withValues(alpha: isDark ? 0.06 : 0.08)
      ..strokeWidth = 1;

    const step = 22.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pathPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(42, 50)
      ..quadraticBezierTo(size.width * 0.5, 28, size.width - 52, 42)
      ..quadraticBezierTo(size.width * 0.42, size.height - 36, 66, size.height - 38);

    canvas.drawPath(
      _dashPath(path, dashArray: const [6, 5]),
      pathPaint,
    );
  }

  Path _dashPath(Path source, {required List<double> dashArray}) {
    final dashed = Path();
    final metrics = source.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = dashArray[draw ? 0 : 1];
        final next = distance + length;
        if (draw) {
          dashed.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => oldDelegate.isDark != isDark;
}
