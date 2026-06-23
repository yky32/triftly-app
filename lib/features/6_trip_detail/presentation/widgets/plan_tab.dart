import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/flight_leg_display.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../bottom_sheets/add_spot_bottom_sheet.dart';
import 'trip_detail_tab_scroll.dart';

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
        final arrivalFlight = selectedDay != null ? _arrivalFlightForDay(selectedDay, trip) : null;
        final departureFlight =
            selectedDay != null ? _departureFlightForDay(selectedDay, trip, days) : null;
        final hasPlanContent = daySpots.isNotEmpty || arrivalFlight != null || departureFlight != null;
        final timelineCount =
            (arrivalFlight != null ? 1 : 0) + daySpots.length + (departureFlight != null ? 1 : 0) + 1;

        return TripDetailTabScroll(
          key: key,
          slivers: [
            if (selectedDay != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedDay.displayTitleLine,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormatters.weekdayDate(selectedDay.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddSpot(context),
                        icon: const Icon(Icons.add_rounded),
                        color: AppColors.primary,
                        tooltip: 'Add spot',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            if (!hasPlanContent)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.place_outlined,
                  title: 'Nothing planned',
                  subtitle: 'Add spots for this day',
                  action: () => _showAddSpot(context),
                  actionLabel: 'Add spot',
                ),
              )
            else
              TripDetailTabScroll.listBottomPadding(
                context,
                sliver: SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  sliver: SliverList.separated(
                    itemCount: timelineCount,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      var cursor = index;

                      if (arrivalFlight != null) {
                        if (cursor == 0) {
                          return FlightLegCard(
                            isOutbound: arrivalFlight.isOutbound,
                            leg: arrivalFlight.leg,
                          );
                        }
                        cursor--;
                      }

                      if (cursor < daySpots.length) {
                        return _SpotCard(
                          spot: daySpots[cursor],
                          defaultCurrency: trip.defaultCurrency,
                        );
                      }
                      cursor -= daySpots.length;

                      if (departureFlight != null) {
                        if (cursor == 0) {
                          return FlightLegCard(
                            isOutbound: departureFlight.isOutbound,
                            leg: departureFlight.leg,
                          );
                        }
                        cursor--;
                      }

                      return _AddSpotButton(onTap: () => _showAddSpot(context));
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  _DayFlight? _arrivalFlightForDay(TripDay day, Trip trip) {
    if (day.dayNumber != 1) return null;
    final leg = trip.outboundFlight;
    if (leg == null || leg.isEmpty) return null;
    return _DayFlight(isOutbound: true, leg: leg);
  }

  _DayFlight? _departureFlightForDay(TripDay day, Trip trip, List<TripDay> days) {
    final lastDayNumber = days.isNotEmpty ? days.last.dayNumber : trip.numberOfDays;
    if (day.dayNumber != lastDayNumber) return null;
    final leg = trip.returnFlight;
    if (leg == null || leg.isEmpty) return null;
    return _DayFlight(isOutbound: false, leg: leg);
  }

  void _showAddSpot(BuildContext context) {
    final tripDetailBloc = context.read<TripDetailBloc>();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: tripDetailBloc,
        child: const AddSpotBottomSheet(),
      ),
    );
  }
}

class _DayFlight {
  const _DayFlight({required this.isOutbound, required this.leg});

  final bool isOutbound;
  final FlightLeg leg;
}

class _AddSpotButton extends StatelessWidget {
  const _AddSpotButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
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
    final categoryColor = AppColors.categoryColor(category);

    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.md)),
              ),
            ),
            Expanded(
              child: Padding(
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
                            Text('📍 ${spot.area!}', style: Theme.of(context).textTheme.bodySmall),
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

  String _meta(Spot spot) {
    return [
      if (spot.openingHours != null) spot.openingHours,
      if (spot.estimatedDuration != null) spot.estimatedDuration,
      if (spot.estimatedCost != null) '$defaultCurrency ${spot.estimatedCost}',
    ].join(' · ');
  }
}
