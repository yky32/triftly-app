import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/trip_detail_bloc.dart';
import '../widgets/plan_tab.dart';
import '../widgets/spend_tab.dart';
import '../widgets/map_tab.dart';

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TripDetailBloc, TripDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _LoadingView();
          }
          if (state.trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          final trip = state.trip!;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.ios_share_rounded),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 52),
                  title: Hero(
                    tag: 'trip-${trip.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        trip.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
                        child: Text(
                          '${trip.destination} · ${trip.defaultCurrency}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Plan'),
                    Tab(text: 'Spend'),
                    Tab(text: 'Map'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                PlanTab(trip: trip, days: state.days, spots: state.spots),
                SpendTab(trip: trip, expenses: state.expenses),
                MapTab(trip: trip, days: state.days, spots: state.spots),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(title: Text('Loading trip...')),
          SliverPadding(
            padding: AppSpacing.page,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                  height: 72,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.card,
                  ),
                ),
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
