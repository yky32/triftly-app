import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/bootstrap/app_scope.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_store.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/today_plan_utils.dart';
import '../../../../core/widgets/glass_icon_button.dart';
import '../../../../core/widgets/glass_toggle.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../5_trip_list/presentation/bottom_sheets/edit_trip_bottom_sheet.dart';
import '../bottom_sheets/share_trip_bottom_sheet.dart';
import '../widgets/plan_day_chips_bar.dart';
import '../widgets/trip_detail_sticky_tab_header.dart';
import '../widgets/trip_detail_tab_segment.dart';
import '../widgets/map_tab.dart';
import '../widgets/plan_tab.dart';
import '../widgets/spend_tab.dart';
import '../widgets/trip_detail_summary.dart';

class TripDetailPage extends StatelessWidget {
  final String tripId;
  final bool readOnly;
  final int initialTabIndex;

  const TripDetailPage({
    required this.tripId,
    this.readOnly = false,
    this.initialTabIndex = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AppScopeBlocs.createTripDetailBloc(tripId)..add(TripDetailLoadRequested()),
      child: _View(readOnly: readOnly, initialTabIndex: initialTabIndex),
    );
  }
}

class _View extends StatefulWidget {
  const _View({this.readOnly = false, this.initialTabIndex = 0});

  final bool readOnly;
  final int initialTabIndex;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _summaryExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _collapseSummaryOnScroll(ScrollNotification notification) {
    if (!_summaryExpanded) return;
    if (notification.metrics.axis != Axis.vertical) return;
    if (notification is! ScrollUpdateNotification && notification is! OverscrollNotification) {
      return;
    }
    if (notification is ScrollUpdateNotification &&
        (notification.scrollDelta ?? 0).abs() < 0.5) {
      return;
    }
    setState(() => _summaryExpanded = false);
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/plan');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripDetailBloc, TripDetailState>(
      listenWhen: (prev, next) => next.deleted && !prev.deleted,
      listener: (context, state) => _handleBack(context),
      child: BlocBuilder<TripDetailBloc, TripDetailState>(
      builder: (context, state) {
        if (state.isLoading) return const _LoadingView();
        if (state.trip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.error ?? 'Trip not found')),
          );
        }

        final trip = state.trip!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isSpendTab = _tabController.index == 1;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 52,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: GlassToolbarCluster(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Back',
                      bare: true,
                      size: 30,
                      onPressed: () => _handleBack(context),
                    ),
                  ],
                ),
              ),
            ),
            title: TriftlyAppBarTitle(title: trip.name, subtitle: trip.destination),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: GlassToolbarCluster(
                    children: [
                      if (isSpendTab)
                        GlassIconButton(
                          icon: Icons.account_balance_wallet_outlined,
                          tooltip: 'All my spending',
                          bare: true,
                          size: 30,
                          onPressed: () => SpendNavigation.openGlobalSpend(context),
                        ),
                      Semantics(
                        label: _summaryExpanded ? 'Hide trip details' : 'Show trip details',
                        child: GlassToggle(
                          value: _summaryExpanded,
                          bare: true,
                          activeTrackColor:
                              AppColors.primary.withValues(alpha: isDark ? 0.32 : 0.2),
                          inactiveTrackColor: isDark
                              ? AppColors.textTertiaryDark.withValues(alpha: 0.45)
                              : AppColors.textTertiary.withValues(alpha: 0.35),
                          onChanged: (value) => setState(() => _summaryExpanded = value),
                        ),
                      ),
                      if (!widget.readOnly && !TripStore.isMockTripId(trip.id))
                        GlassIconButton(
                          icon: Icons.more_horiz_rounded,
                          tooltip: 'Trip options',
                          bare: true,
                          size: 30,
                          onPressed: () => _showTripMenu(context, trip),
                        ),
                      if (!widget.readOnly)
                        GlassIconButton(
                          icon: Icons.ios_share_rounded,
                          tooltip: 'Share trip',
                          bare: true,
                          size: 30,
                          onPressed: () => ShareTripBottomSheet.show(context, trip),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _collapseSummaryOnScroll(notification);
              return false;
            },
            child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final isPlanTab = _tabController.index == 0;
              final showDayChips = isPlanTab && state.days.isNotEmpty;
              final headerExtent = TripDetailStickyTabDelegate.tabExtent +
                  (showDayChips ? PlanDayChipsBar.chipsExtent : 0);

              return [
                SliverToBoxAdapter(
                  child: ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      heightFactor: _summaryExpanded ? 1 : 0,
                      alignment: Alignment.topCenter,
                      child: TripDetailSummary(trip: trip),
                    ),
                  ),
                ),
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: TripDetailStickyBarDelegate(
                      extent: headerExtent,
                      isScrolled: innerBoxIsScrolled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: TripDetailStickyTabDelegate.tabExtent,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.sm,
                                AppSpacing.lg,
                                AppSpacing.md,
                              ),
                              child: TripDetailTabSegment(
                                selectedIndex: _tabController.index,
                                onChanged: (index) => _tabController.animateTo(index),
                              ),
                            ),
                          ),
                          if (showDayChips)
                            SizedBox(
                              height: PlanDayChipsBar.chipsExtent,
                              child: PlanDayChipsBar(
                                days: state.days,
                                selectedIndex: state.selectedDayIndex,
                                todayIndex: TodayPlanUtils.todayDayIndex(trip, state.days),
                                onDaySelected: (index) => context
                                    .read<TripDetailBloc>()
                                    .add(TripDetailDaySelected(index: index)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                PlanTab(
                  key: const PageStorageKey<String>('plan'),
                  trip: trip,
                  days: state.days,
                  spots: state.spots,
                  readOnly: widget.readOnly,
                  onOpenSpendTab: widget.readOnly ? null : () => _tabController.animateTo(1),
                ),
                SpendTab(
                  key: const PageStorageKey<String>('spend'),
                  trip: trip,
                  days: state.days,
                  expenses: state.expenses,
                  settlements: state.settlements,
                  readOnly: widget.readOnly,
                ),
                MapTab(
                  key: const PageStorageKey<String>('map'),
                  trip: trip,
                  days: state.days,
                  spots: state.spots,
                  readOnly: widget.readOnly,
                  onOpenPlanTab: widget.readOnly ? null : () => _tabController.animateTo(0),
                ),
              ],
            ),
          ),
        ),
        );
      },
    ),
    );
  }

  Future<void> _showTripMenu(BuildContext context, Trip trip) async {
    final action = await showModalBottomSheet<_TripDetailMenuAction>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit trip'),
              onTap: () => Navigator.pop(ctx, _TripDetailMenuAction.edit),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete trip', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(ctx, _TripDetailMenuAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;

    final bloc = context.read<TripDetailBloc>();
    switch (action) {
      case _TripDetailMenuAction.edit:
        await EditTripBottomSheet.show(context, trip: trip);
      case _TripDetailMenuAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete trip?'),
            content: Text('“${trip.name}” will be removed from your list.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          bloc.add(const TripDetailTripDeleted());
        }
    }
  }
}

enum _TripDetailMenuAction { edit, delete }

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: ListView.separated(
          padding: AppSpacing.page,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, __) => Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadii.card,
            ),
          ),
        ),
      ),
    );
  }
}
