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
    return BlocBuilder<TripDetailBloc, TripDetailState>(
      builder: (context, state) {
        if (state.isLoading) return const _LoadingView();
        if (state.trip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Trip not found')),
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
              IconButton(icon: const Icon(Icons.ios_share_outlined), onPressed: () {}),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Plan'),
                Tab(text: 'Spend'),
                Tab(text: 'Map'),
              ],
            ),
          ),
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
    );
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
