import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../core/utils/today_plan_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/flight_leg_display.dart';
import '../../../../core/widgets/glass_context_menu.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../bottom_sheets/add_expense_bottom_sheet.dart';
import '../bottom_sheets/add_spot_bottom_sheet.dart';
import 'plan_add_spot_action.dart';
import 'plan_day_empty_state.dart';
import 'today_plan_card.dart';
import 'trip_detail_tab_scroll.dart';

class PlanTab extends StatelessWidget {
  final Trip trip;
  final List<TripDay> days;
  final List<Spot> spots;
  final bool readOnly;
  final VoidCallback? onOpenSpendTab;

  const PlanTab({
    required this.trip,
    required this.days,
    required this.spots,
    this.readOnly = false,
    this.onOpenSpendTab,
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
        final isToday = TodayPlanUtils.isSelectedDayToday(trip, days, state.selectedDayIndex);
        final nextSpot = isToday ? TodayPlanUtils.nextSpotNow(daySpots) : null;

        final dayItems = <Widget>[];

        if (isToday && selectedDay != null) {
          dayItems.add(
            TodayPlanCard(
              trip: trip,
              todayDay: selectedDay,
              nextSpot: nextSpot,
              todayTotal: TodayPlanUtils.todaySpendingTotal(
                trip: trip,
                days: days,
                expenses: state.expenses,
              ),
              expenseCount: TodayPlanUtils.todayExpenseCount(
                trip,
                days,
                state.expenses,
              ),
              onAddExpense: readOnly
                  ? null
                  : () => _showTodayExpense(context, dayId: selectedDay.id),
              onOpenSpend: onOpenSpendTab,
            ),
          );
          dayItems.add(const SizedBox(height: AppSpacing.md));
        }

        if (selectedDay != null) {
          dayItems.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedDay.displayTitleLine,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatters.weekdayDate(selectedDay.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
          dayItems.add(const SizedBox(height: AppSpacing.md));

          if (!hasPlanContent) {
            dayItems.add(
              PlanDayEmptyState(
                day: selectedDay,
                readOnly: readOnly,
                onAddSuggestion: readOnly
                    ? null
                    : (category) => _showAddSpot(context, initialCategory: category),
              ),
            );
          } else {
            if (arrivalFlight != null) {
              dayItems.add(
                FlightLegCard(
                  isOutbound: arrivalFlight.isOutbound,
                  leg: arrivalFlight.leg,
                ),
              );
              dayItems.add(const SizedBox(height: AppSpacing.sm));
            }
            if (daySpots.isNotEmpty) {
              dayItems.add(
                _SpotList(
                  trip: trip,
                  dayId: selectedDay.id,
                  spots: daySpots,
                  defaultCurrency: trip.defaultCurrency,
                  readOnly: readOnly,
                ),
              );
            }
            if (departureFlight != null) {
              if (daySpots.isNotEmpty) {
                dayItems.add(const SizedBox(height: AppSpacing.sm));
              }
              dayItems.add(
                FlightLegCard(
                  isOutbound: departureFlight.isOutbound,
                  leg: departureFlight.leg,
                ),
              );
            }
          }

          if (!readOnly) {
            dayItems.add(const SizedBox(height: AppSpacing.sm));
            dayItems.add(PlanAddSpotAction(onTap: () => _showAddSpot(context)));
          }
        }

        return TripDetailTabScroll(
          key: key,
          slivers: [
            if (dayItems.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox.shrink(),
              )
            else
              TripDetailTabScroll.listBottomPadding(
                context,
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(dayItems),
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

  void _showAddSpot(BuildContext context, {Spot? editSpot, String? initialCategory}) {
    if (readOnly) return;
    final tripDetailBloc = context.read<TripDetailBloc>();

    TriftlyBottomSheet.show(
      context,
      child: BlocProvider.value(
        value: tripDetailBloc,
        child: AddSpotBottomSheet(editSpot: editSpot, initialCategory: initialCategory),
      ),
    );
  }

  void _showTodayExpense(
    BuildContext context, {
    required String dayId,
    String? prefillTitle,
    String? prefillCategory,
  }) {
    if (readOnly) return;
    HapticFeedback.mediumImpact();
    AddExpenseBottomSheet.show(
      context,
      trip: trip,
      bloc: context.read<TripDetailBloc>(),
      prefillTitle: prefillTitle,
      prefillCategory: prefillCategory,
      initialDayId: dayId,
    );
  }
}

class _SpotList extends StatelessWidget {
  const _SpotList({
    required this.trip,
    required this.dayId,
    required this.spots,
    required this.defaultCurrency,
    required this.readOnly,
  });

  final Trip trip;
  final String dayId;
  final List<Spot> spots;
  final String defaultCurrency;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return Column(
        children: [
          for (final spot in spots) ...[
            _SpotCard(
              spot: spot,
              defaultCurrency: defaultCurrency,
              trip: trip,
              readOnly: true,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: spots.length,
      onReorder: (oldIndex, newIndex) {
        HapticFeedback.lightImpact();
        context.read<TripDetailBloc>().add(
              TripDetailSpotsReordered(dayId: dayId, oldIndex: oldIndex, newIndex: newIndex),
            );
      },
      itemBuilder: (context, index) {
        final spot = spots[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(spot.id),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SpotCard(
              spot: spot,
              defaultCurrency: defaultCurrency,
              trip: trip,
              readOnly: false,
            ),
          ),
        );
      },
    );
  }
}

class _DayFlight {
  const _DayFlight({required this.isOutbound, required this.leg});

  final bool isOutbound;
  final FlightLeg leg;
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({
    required this.spot,
    required this.defaultCurrency,
    required this.trip,
    required this.readOnly,
  });

  final Spot spot;
  final String defaultCurrency;
  final Trip trip;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );
    final categoryColor = AppColors.categoryColor(category);

    final card = AppCard(
      padding: EdgeInsets.zero,
      child: Opacity(
        opacity: spot.visited ? 0.55 : 1,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: spot.visited ? AppColors.textTertiary : categoryColor,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    spot.name,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: spot.visited ? TextDecoration.lineThrough : null,
                                        ),
                                  ),
                                ),
                                if (spot.visited)
                                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                              ],
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
                      if (!readOnly) _SpotActionsMenu(spot: spot, trip: trip),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (readOnly) return card;

    return GestureDetector(
      onLongPress: () => _showQuickExpense(context),
      child: card,
    );
  }

  String _meta(Spot spot) {
    return [
      if (spot.openingHours != null) spot.openingHours,
      if (spot.estimatedDuration != null) spot.estimatedDuration,
      if (spot.estimatedCost != null) '$defaultCurrency ${spot.estimatedCost}',
    ].join(' · ');
  }

  void _showQuickExpense(BuildContext context) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<TripDetailBloc>();
    final dayId = bloc.state.days.isEmpty
        ? null
        : bloc.state.days[bloc.state.selectedDayIndex].id;
    AddExpenseBottomSheet.show(
      context,
      trip: trip,
      bloc: bloc,
      prefillTitle: spot.name,
      prefillCategory: spot.category,
      initialDayId: dayId,
    );
  }
}

class _SpotActionsMenu extends StatelessWidget {
  const _SpotActionsMenu({required this.spot, required this.trip});

  final Spot spot;
  final Trip trip;

  Future<void> _openMenu(BuildContext context) async {
    final action = await GlassContextMenu.show<_SpotAction>(
      context: context,
      width: 196,
      entries: [
        const GlassMenuEntry(
          value: _SpotAction.maps,
          label: 'Open in Maps',
          icon: Icons.map_outlined,
        ),
        GlassMenuEntry(
          value: _SpotAction.visited,
          label: spot.visited ? 'Mark not visited' : 'Mark visited',
          icon: spot.visited ? Icons.radio_button_unchecked : Icons.check_circle_outline,
        ),
        const GlassMenuEntry(
          value: _SpotAction.expense,
          label: 'Add expense',
          icon: Icons.payments_outlined,
        ),
        const GlassMenuEntry(
          value: _SpotAction.edit,
          label: 'Edit spot',
          icon: Icons.edit_outlined,
        ),
        const GlassMenuEntry(
          value: _SpotAction.delete,
          label: 'Delete spot',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (action != null && context.mounted) {
      _handleAction(context, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMenu(context),
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary, size: 20),
      ),
    );
  }

  void _handleAction(BuildContext context, _SpotAction action) {
    final bloc = context.read<TripDetailBloc>();
    switch (action) {
      case _SpotAction.maps:
        HapticFeedback.lightImpact();
        MapsLauncher.openSpot(spot);
      case _SpotAction.visited:
        HapticFeedback.selectionClick();
        bloc.add(TripDetailSpotVisitedToggled(spotId: spot.id));
      case _SpotAction.expense:
        AddExpenseBottomSheet.show(
          context,
          trip: trip,
          bloc: bloc,
          prefillTitle: spot.name,
          prefillCategory: spot.category,
          initialDayId: bloc.state.days.isEmpty
              ? null
              : bloc.state.days[bloc.state.selectedDayIndex].id,
        );
      case _SpotAction.edit:
        TriftlyBottomSheet.show(
          context,
          child: BlocProvider.value(
            value: bloc,
            child: AddSpotBottomSheet(editSpot: spot),
          ),
        );
      case _SpotAction.delete:
        HapticFeedback.mediumImpact();
        bloc.add(TripDetailSpotRemoved(spotId: spot.id));
    }
  }
}

enum _SpotAction { maps, visited, expense, edit, delete }
