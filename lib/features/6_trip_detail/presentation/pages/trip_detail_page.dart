import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/bootstrap/app_scope.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_store.dart';
import '../../../../core/navigation/shared_place_flow.dart';
import '../../../../core/share/inbound_debug_log.dart';
import '../../../../core/navigation/sign_out_branch_reset.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/today_plan_utils.dart';
import '../../../../core/widgets/confirm_bottom_sheet.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_icon_button.dart';
import '../../../../core/widgets/glass_toggle.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../../core/widgets/shared_trip_role_banner.dart';
import '../../../5_trip_list/presentation/bottom_sheets/edit_trip_bottom_sheet.dart';
import '../bottom_sheets/add_spot_bottom_sheet.dart';
import '../bottom_sheets/trip_detail_menu_sheet.dart';
import '../bottom_sheets/share_trip_bottom_sheet.dart';
import '../bottom_sheets/trip_members_bottom_sheet.dart';
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
    final trip = TripStore.instance.tripById(tripId);
    final effectiveReadOnly = readOnly || !(trip?.canEditTripContent ?? true);

    return SignOutBranchReset(
      child: BlocProvider(
        create: (context) =>
            AppScopeBlocs.createTripDetailBloc(tripId)..add(TripDetailLoadRequested()),
        child: _View(
          tripId: tripId,
          readOnly: effectiveReadOnly,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }
}

class _View extends StatefulWidget {
  const _View({
    required this.tripId,
    this.readOnly = false,
    this.initialTabIndex = 0,
  });

  final String tripId;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _openInboundSharedPlace());
  }

  void _openInboundSharedPlace() {
    if (widget.readOnly) return;
    final place = SharedPlaceFlow.consumeArmedForTrip(widget.tripId);
    if (place == null || !mounted) return;

    inboundDebugLog(
      'Opening Add Spot sheet → tripId=${widget.tripId} · ${inboundPlaceSummary(place)}',
      kind: InboundLogKind.success,
    );
    AddSpotBottomSheet.show(
      context,
      bloc: context.read<TripDetailBloc>(),
      initialName: place.nameLine,
      initialAddress: place.addressLine,
    );
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
            body: EmptyState(
              expand: true,
              icon: Icons.travel_explore_outlined,
              title: 'Trip not found',
              action: () => _handleBack(context),
              actionLabel: 'Go back',
            ),
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
                      if (!trip.isPreviewShare && !TripStore.isMockTripId(trip.id))
                        GlassIconButton(
                          icon: Icons.people_outline_rounded,
                          tooltip: 'Travel buddies',
                          bare: true,
                          size: 30,
                          onPressed: () => TripMembersBottomSheet.show(context, trip),
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
                      if (trip.canManageTripSettings && !TripStore.isMockTripId(trip.id))
                        GlassIconButton(
                          icon: Icons.more_horiz_rounded,
                          tooltip: 'Trip options',
                          bare: true,
                          size: 30,
                          onPressed: () => _showTripMenu(context, trip),
                        ),
                      if (trip.canManageTripSettings)
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
                  child: SharedTripRoleBanner(trip: trip),
                ),
                SliverToBoxAdapter(
                  child: ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      heightFactor: _summaryExpanded ? 1 : 0,
                      alignment: Alignment.topCenter,
                      child: TripDetailSummary(
                        trip: trip,
                        onBuddiesTap: trip.isPreviewShare
                            ? null
                            : () => TripMembersBottomSheet.show(context, trip),
                      ),
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
    final action = await TripDetailMenuSheet.show(context);
    if (!context.mounted || action == null) return;

    final bloc = context.read<TripDetailBloc>();
    switch (action) {
      case TripDetailMenuAction.edit:
        await EditTripBottomSheet.show(context, trip: trip);
      case TripDetailMenuAction.delete:
        final confirmed = await ConfirmBottomSheet.show(
          context,
          title: 'Delete trip?',
          message: '“${trip.name}” will be removed from your list.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (confirmed && context.mounted) {
          bloc.add(const TripDetailTripDeleted());
        }
    }
  }
}

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
