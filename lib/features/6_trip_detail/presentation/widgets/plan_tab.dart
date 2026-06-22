import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
        List<Spot> daySpots = [];
        if (selectedDay != null) {
          daySpots = spots.where((s) => s.dayId == selectedDay.id).toList();
          daySpots.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }

        return Column(
          children: [
            if (days.isNotEmpty)
              Container(
                color: AppColors.cardBackground(context),
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final isSelected = index == state.selectedDayIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Pressable(
                          onTap: () => context.read<TripDetailBloc>().add(TripDetailDaySelected(index: index)),
                          scale: 0.95,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.pageBackground(context),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              day.displayTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

            if (selectedDay != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDay.title?.isNotEmpty == true
                            ? '${selectedDay.displayTitle} — ${selectedDay.title}'
                            : selectedDay.displayTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      Text(selectedDay.displayDate, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: daySpots.isEmpty
                  ? EmptyState(
                      icon: Icons.add_location_alt_outlined,
                      title: 'No spots planned yet',
                      subtitle: 'Add restaurants, sights, and stays for this day',
                      action: () => _showAddSpot(context),
                      actionLabel: 'Add Spot',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
                      itemCount: daySpots.length + 1,
                      itemBuilder: (context, index) {
                        if (index == daySpots.length) {
                          return _AddSpotButton(onTap: () => _showAddSpot(context)).staggerIn(index);
                        }
                        return _SpotCard(
                          spot: daySpots[index],
                          defaultCurrency: trip.defaultCurrency,
                          index: index,
                          isLast: index == daySpots.length - 1,
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
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: AppRadii.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Add a spot',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final Spot spot;
  final String defaultCurrency;
  final int index;
  final bool isLast;

  const _SpotCard({
    required this.spot,
    required this.defaultCurrency,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );
    final color = AppColors.categoryColor(category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 18),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Pressable(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: AppRadii.card,
                  boxShadow: AppShadows.soft(context),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.lg)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(category.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    spot.name,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textTertiary),
                              ],
                            ),
                            if (_metaLine(spot, defaultCurrency).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(_metaLine(spot, defaultCurrency), style: Theme.of(context).textTheme.bodySmall),
                            ],
                            if (spot.area != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.place_outlined, size: 14, color: AppColors.textTertiary),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      spot.area!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).staggerIn(index),
          ),
        ],
      ),
    );
  }

  String _metaLine(Spot spot, String currency) {
    return [
      if (spot.openingHours != null) spot.openingHours,
      if (spot.estimatedDuration != null) spot.estimatedDuration,
      if (spot.estimatedCost != null) '$currency ${spot.estimatedCost}',
    ].join(' · ');
  }
}
