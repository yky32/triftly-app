import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/trip_detail_bloc.dart';
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  trip.destination,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                onPressed: () => _shareTrip(trip),
              ),
            ],
          ),
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    opacity: innerBoxIsScrolled ? 0.92 : 1,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      scale: innerBoxIsScrolled ? 0.98 : 1,
                      alignment: Alignment.topCenter,
                      child: TripDetailSummary(trip: trip),
                    ),
                  ),
                ),
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: TripDetailStickyTabDelegate(
                      isScrolled: innerBoxIsScrolled,
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
