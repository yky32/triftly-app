import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_motion.dart';

class MapTab extends StatelessWidget {
  final Trip trip;
  final List<TripDay> days;
  final List<Spot> spots;

  const MapTab({
    required this.trip,
    required this.days,
    required this.spots,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return EmptyState(
        icon: Icons.map_outlined,
        title: 'No spots to map',
        subtitle: 'Add spots in Plan to see them here',
      );
    }

    return ListView(
      padding: AppSpacing.page,
      children: [
        _MapPlaceholder(spotCount: spots.length, destination: trip.destination).fadeSlideIn(),
        const SizedBox(height: AppSpacing.lg),
        Text('All spots', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppSpacing.sm),
        ...spots.asMap().entries.map((entry) {
          final spot = entry.value;
          final category = SpotCategory.values.firstWhere(
            (c) => c.value == spot.category,
            orElse: () => SpotCategory.other,
          );
          return AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.categoryColor(category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.name,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (spot.area != null)
                        Text(spot.area!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.north_east_rounded, size: 18, color: AppColors.textTertiary),
              ],
            ),
          ).staggerIn(entry.key);
        }),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.spotCount,
    required this.destination,
  });

  final int spotCount;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryMuted,
            AppColors.surfaceDim,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 16,
            child: Icon(Icons.map_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'Map preview',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  destination,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
                Text(
                  '$spotCount spot${spotCount == 1 ? '' : 's'} · Google Maps coming soon',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
