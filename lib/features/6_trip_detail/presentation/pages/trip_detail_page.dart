import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../widgets/plan_day_chips_bar.dart';
import '../widgets/trip_detail_sticky_tab_header.dart';
import '../widgets/trip_detail_tab_segment.dart';
import '../widgets/map_tab.dart';
import '../widgets/plan_tab.dart';
import '../widgets/spend_tab.dart';
import '../widgets/trip_detail_summary.dart';

class TripDetailPage extends StatelessWidget {
  final String tripId;

  const TripDetailPage({required this.tripId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripDetailBloc(tripId: tripId)..add(TripDetailLoadRequested()),
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _summaryExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripDetailBloc, TripDetailState>(
      builder: (context, state) {
        if (state.isLoading) return const _LoadingView();
        if (state.trip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.error ?? 'Trip not found')),
          );
        }

        final trip = state.trip!;

        return Scaffold(
          appBar: AppBar(
            title: TriftlyAppBarTitle(title: trip.name, subtitle: trip.destination),
            actions: [
              IconButton(
                icon: Icon(
                  _summaryExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                ),
                tooltip: _summaryExpanded ? 'Hide trip details' : 'View trip details',
                onPressed: () => setState(() => _summaryExpanded = !_summaryExpanded),
              ),
              IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                onPressed: () => _shareTrip(trip),
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
                ),
                SpendTab(
                  key: const PageStorageKey<String>('spend'),
                  trip: trip,
                  days: state.days,
                  expenses: state.expenses,
                ),
                MapTab(
                  key: const PageStorageKey<String>('map'),
                  trip: trip,
                  days: state.days,
                  spots: state.spots,
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  void _shareTrip(Trip trip) {
    final token = trip.shareToken ?? trip.id;
    Share.share('Join my trip "${trip.name}" on Triftly: https://triftly.app/s/$token');
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
