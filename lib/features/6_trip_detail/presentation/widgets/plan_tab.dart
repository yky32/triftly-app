import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/triftly_motion.dart';
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
        var daySpots = <Spot>[];
        if (selectedDay != null) {
          daySpots = spots.where((s) => s.dayId == selectedDay.id).toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (days.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: days.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    final isSelected = index == state.selectedDayIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(day.displayTitle),
                        selected: isSelected,
                        onSelected: (_) => context.read<TripDetailBloc>().add(TripDetailDaySelected(index: index)),
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (selectedDay != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                child: Text(selectedDay.displayDate, style: Theme.of(context).textTheme.bodySmall),
              ),
            Expanded(
              child: daySpots.isEmpty
                  ? EmptyState(
                      icon: Icons.place_outlined,
                      title: 'Nothing planned',
                      subtitle: 'Add spots for this day',
                      action: () => _showAddSpot(context),
                      actionLabel: 'Add spot',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                      itemCount: daySpots.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        if (index == daySpots.length) {
                          return _AddSpotButton(onTap: () => _showAddSpot(context));
                        }
                        return _SpotCard(
                          spot: daySpots[index],
                          defaultCurrency: trip.defaultCurrency,
                        );
                      },
                    ),
            ),
          ],
        );
      },
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

class _AddSpotButton extends StatelessWidget {
  const _AddSpotButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Add spot', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({required this.spot, required this.defaultCurrency});

  final Spot spot;
  final String defaultCurrency;

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (_meta(spot).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(_meta(spot), style: Theme.of(context).textTheme.bodySmall),
                ],
                if (spot.area != null) ...[
                  const SizedBox(height: 2),
                  Text(spot.area!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
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
