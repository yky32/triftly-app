import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';

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
    // TODO: Integrate google_maps_flutter when API key is configured
    // For now, show a placeholder
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text(
                    'Map View',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Configure Google Maps API key to enable',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 16),
                  // Show spot list as fallback
                  if (spots.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: spots.length,
                        itemBuilder: (context, index) {
                          final spot = spots[index];
                          final category = SpotCategory.values.firstWhere(
                            (c) => c.value == spot.category,
                            orElse: () => SpotCategory.other,
                          );
                          return ListTile(
                            leading: Text(category.emoji, style: const TextStyle(fontSize: 20)),
                            title: Text(spot.name, style: const TextStyle(fontSize: 14)),
                            subtitle: spot.area != null ? Text(spot.area!, style: const TextStyle(fontSize: 12)) : null,
                            dense: true,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
