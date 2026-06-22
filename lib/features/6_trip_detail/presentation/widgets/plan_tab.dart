import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../bottom_sheets/add_spot_bottom_sheet.dart';

class PlanTab extends StatelessWidget {
  final Trip trip;
  final List<TripDay> days;
  final List<Spot> spots;

  const PlanTab({
    required this.trip,
    required this.days,
    required this.spots,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripDetailBloc, TripDetailState>(
      builder: (context, state) {
        final selectedDay = days.isNotEmpty ? days[state.selectedDayIndex] : null;
        List<Spot> daySpots = [];
        if (selectedDay != null) {
          daySpots = spots.where((s) => s.dayId == selectedDay.id).toList();
          daySpots.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }

        return Column(
          children: [
            // Day tabs
            if (days.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final isSelected = index == state.selectedDayIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => context
                              .read<TripDetailBloc>()
                              .add(TripDetailDaySelected(index: index)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceDim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              day.displayTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Day title
            if (selectedDay != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedDay.displayTitle} — ${selectedDay.title ?? ''}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        selectedDay.displayDate,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

            // Spots list
            Expanded(
              child: daySpots.isEmpty
                  ? _buildEmptyDay(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: daySpots.length + 1,
                      itemBuilder: (context, index) {
                        if (index == daySpots.length) {
                          return _buildAddSpotArea(context);
                        }
                        return _SpotCard(spot: daySpots[index], defaultCurrency: trip.defaultCurrency);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyDay(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_location_alt, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'No spots planned yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + button to add your first spot',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSpotArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddSpot(context),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: AppColors.textTertiary),
            SizedBox(width: 8),
            Text('Add a spot', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showAddSpot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSpotBottomSheet(),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final Spot spot;
  final String defaultCurrency;

  const _SpotCard({
    required this.spot,
    required this.defaultCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );
    final color = AppColors.categoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category color bar
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          spot.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (spot.openingHours != null) spot.openingHours,
                      if (spot.estimatedDuration != null) spot.estimatedDuration,
                      if (spot.estimatedCost != null) '$defaultCurrency ${spot.estimatedCost}',
                    ].join(' · '),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (spot.area != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Text(spot.area!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_horiz, size: 18, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
