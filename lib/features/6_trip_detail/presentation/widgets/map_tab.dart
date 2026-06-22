import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';

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
      return const EmptyState(
        icon: Icons.map_outlined,
        title: 'No spots yet',
        subtitle: 'Add places in Plan to see them here',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
      children: [
        AppCard(
          color: AppColors.accentSurface,
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 32, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.destination, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${spots.length} spots · Maps integration coming soon',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Spots'),
        ...spots.map((spot) {
          final category = SpotCategory.values.firstWhere(
            (c) => c.value == spot.category,
            orElse: () => SpotCategory.other,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spot.name, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                        if (spot.area != null) Text(spot.area!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
