import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import 'trip_detail_tab_scroll.dart';

class MapTab extends StatefulWidget {
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
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.spots.isEmpty) {
      return const TripDetailTabScroll(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.map_outlined,
              title: 'No spots yet',
              subtitle: 'Add places in Plan to see them here',
            ),
          ),
        ],
      );
    }

    final visibleSpots = _visibleSpots();
    final mappedCount = visibleSpots.where((s) => s.latitude != null && s.longitude != null).length;

    return TripDetailTabScroll(
      key: widget.key,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.listBottomInset(context),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
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
                          Text(widget.trip.destination, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            '$mappedCount of ${visibleSpots.length} spots mapped · Full map coming soon',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.days.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: const Text('All days'),
                          selected: _selectedDayIndex == null,
                          onSelected: (_) => setState(() => _selectedDayIndex = null),
                        ),
                      ),
                      ...widget.days.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: FilterChip(
                            label: Text(day.displayTitle),
                            selected: _selectedDayIndex == index,
                            onSelected: (_) => setState(() => _selectedDayIndex = index),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Spots'),
              ...visibleSpots.asMap().entries.map((entry) {
                final index = entry.key;
                final spot = entry.value;
                final category = SpotCategory.values.firstWhere(
                  (c) => c.value == spot.category,
                  orElse: () => SpotCategory.other,
                );
                final day = _dayForSpot(spot);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.categoryColor(category).withValues(alpha: 0.15),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 12, color: AppColors.categoryColor(category)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(category.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spot.name,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (day != null)
                                Text(day.displayTitle, style: Theme.of(context).textTheme.bodySmall),
                              if (spot.area != null)
                                Text('📍 ${spot.area!}', style: Theme.of(context).textTheme.bodySmall),
                              if (spot.openingHours != null)
                                Text(spot.openingHours!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }

  List<Spot> _visibleSpots() {
    Iterable<Spot> spots = widget.spots;
    if (_selectedDayIndex != null && widget.days.length > _selectedDayIndex!) {
      final dayId = widget.days[_selectedDayIndex!].id;
      spots = spots.where((s) => s.dayId == dayId);
    }
    return spots.toList()..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  TripDay? _dayForSpot(Spot spot) {
    for (final day in widget.days) {
      if (day.id == spot.dayId) return day;
    }
    return null;
  }
}
