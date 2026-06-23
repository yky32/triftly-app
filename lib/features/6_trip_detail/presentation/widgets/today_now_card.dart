import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/triftly_motion.dart';

class TodayNowCard extends StatelessWidget {
  const TodayNowCard({
    required this.spot,
    required this.defaultCurrency,
    this.onOpenMaps,
    super.key,
  });

  final Spot spot;
  final String defaultCurrency;
  final VoidCallback? onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );

    return Pressable(
      onTap: onOpenMaps ?? () => MapsLauncher.openSpot(spot),
      child: AppCard(
        color: AppColors.primaryDark,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              alignment: Alignment.center,
              child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Up next',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spot.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (_meta(spot).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _meta(spot),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  String _meta(Spot spot) {
    return [
      if (spot.openingHours != null) spot.openingHours,
      if (spot.estimatedDuration != null) spot.estimatedDuration,
      if (spot.estimatedCost != null) '$defaultCurrency ${spot.estimatedCost}',
    ].join(' · ');
  }
}
