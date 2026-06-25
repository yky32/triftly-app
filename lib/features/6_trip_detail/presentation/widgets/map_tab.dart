import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../bloc/trip_detail_bloc.dart';
import 'map_empty_state.dart';
import 'trip_detail_tab_scroll.dart';

class MapTab extends StatefulWidget {
  final Trip trip;
  final List<TripDay> days;
  final List<Spot> spots;
  final bool readOnly;
  final VoidCallback? onOpenPlanTab;

  const MapTab({
    required this.trip,
    required this.days,
    required this.spots,
    this.readOnly = false,
    this.onOpenPlanTab,
    super.key,
  });

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  GoogleMapController? _mapController;
  bool _showAllDays = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spots.isEmpty) {
      return TripDetailTabScroll(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: MapEmptyState(
                trip: widget.trip,
                readOnly: widget.readOnly,
                onOpenPlan: widget.onOpenPlanTab,
              ),
            ),
          ),
        ],
      );
    }

    return BlocBuilder<TripDetailBloc, TripDetailState>(
      builder: (context, state) {
        final dayIndex = _showAllDays ? null : state.selectedDayIndex;
        final visibleSpots = _visibleSpots(dayIndex);
        final mappedSpots = visibleSpots
            .where((s) => s.latitude != null && s.longitude != null)
            .toList();
        final scopeLabel = _scopeLabel(dayIndex);

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
                delegate: SliverChildListDelegate(_buildContent(
                  dayIndex: dayIndex,
                  scopeLabel: scopeLabel,
                  visibleSpots: visibleSpots,
                  mappedSpots: mappedSpots,
                )),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildContent({
    required int? dayIndex,
    required String scopeLabel,
    required List<Spot> visibleSpots,
    required List<Spot> mappedSpots,
  }) {
    final items = <Widget>[];

    if (widget.days.isNotEmpty) {
      items.add(_MapDayScopeChips(
        showAllDays: _showAllDays,
        onAllDays: () => setState(() => _showAllDays = true),
        onSelectedDay: () => setState(() => _showAllDays = false),
      ));
      items.add(const SizedBox(height: AppSpacing.md));
    }

    if (visibleSpots.isEmpty) {
      items.add(MapDayEmptyState(
        dayLabel: scopeLabel,
        onOpenPlan: widget.onOpenPlanTab,
      ));
      return items;
    }

    if (mappedSpots.isNotEmpty) {
      items.add(
        ClipRRect(
          borderRadius: AppRadii.card,
          child: SizedBox(
            height: 280,
            child: GoogleMap(
              initialCameraPosition: _initialCamera(mappedSpots),
              markers: _buildMarkers(mappedSpots),
              polylines: _buildPolyline(mappedSpots),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBounds(mappedSpots);
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
      );
      items.add(const SizedBox(height: AppSpacing.sm));
      items.add(MapRouteStatusHeader(
        scopeLabel: scopeLabel,
        mappedCount: mappedSpots.length,
        totalCount: visibleSpots.length,
      ));
    } else {
      items.add(MapUnmappedHero(
        spotCount: visibleSpots.length,
        scopeLabel: scopeLabel,
      ));
    }

    if (visibleSpots.isNotEmpty) {
      items.add(const SizedBox(height: AppSpacing.lg));
      items.add(_StopsListLabel(count: visibleSpots.length));
      items.add(const SizedBox(height: AppSpacing.sm));
      items.addAll(visibleSpots.asMap().entries.map((entry) {
        final index = entry.key;
        final spot = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _SpotListTile(
            index: index,
            spot: spot,
            day: _dayForSpot(spot),
          ),
        );
      }));
    }

    return items;
  }

  String _scopeLabel(int? dayIndex) {
    if (_showAllDays || dayIndex == null) return 'All days';
    if (widget.days.length > dayIndex) return widget.days[dayIndex].displayTitleLine;
    return 'This day';
  }

  List<Spot> _visibleSpots(int? dayIndex) {
    Iterable<Spot> spots = widget.spots;
    if (dayIndex != null && widget.days.length > dayIndex) {
      final dayId = widget.days[dayIndex].id;
      spots = spots.where((s) => s.dayId == dayId);
    }
    return spots.toList()..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  CameraPosition _initialCamera(List<Spot> mappedSpots) {
    final first = mappedSpots.first;
    return CameraPosition(
      target: LatLng(first.latitude!, first.longitude!),
      zoom: 13,
    );
  }

  Set<Marker> _buildMarkers(List<Spot> mappedSpots) {
    return mappedSpots.asMap().entries.map((entry) {
      final index = entry.key;
      final spot = entry.value;
      final category = SpotCategory.values.firstWhere(
        (c) => c.value == spot.category,
        orElse: () => SpotCategory.other,
      );

      return Marker(
        markerId: MarkerId(spot.id),
        position: LatLng(spot.latitude!, spot.longitude!),
        infoWindow: InfoWindow(
          title: '${index + 1}. ${spot.name}',
          snippet: spot.area,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _markerHue(category),
        ),
        alpha: spot.visited ? 0.45 : 1,
      );
    }).toSet();
  }

  Set<Polyline> _buildPolyline(List<Spot> mappedSpots) {
    if (mappedSpots.length < 2) return const {};

    return {
      Polyline(
        polylineId: const PolylineId('day_route'),
        points: mappedSpots
            .map((spot) => LatLng(spot.latitude!, spot.longitude!))
            .toList(),
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
        jointType: JointType.round,
      ),
    };
  }

  double _markerHue(SpotCategory category) {
    return switch (category) {
      SpotCategory.food => BitmapDescriptor.hueOrange,
      SpotCategory.attraction => BitmapDescriptor.hueAzure,
      SpotCategory.shopping => BitmapDescriptor.hueRose,
      SpotCategory.hotel => BitmapDescriptor.hueBlue,
      SpotCategory.transport => BitmapDescriptor.hueCyan,
      SpotCategory.other => BitmapDescriptor.hueRed,
    };
  }

  Future<void> _fitBounds(List<Spot> mappedSpots) async {
    final controller = _mapController;
    if (controller == null || mappedSpots.isEmpty) return;

    if (mappedSpots.length == 1) {
      final spot = mappedSpots.first;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(spot.latitude!, spot.longitude!), 14),
      );
      return;
    }

    var minLat = mappedSpots.first.latitude!;
    var maxLat = minLat;
    var minLng = mappedSpots.first.longitude!;
    var maxLng = minLng;

    for (final spot in mappedSpots) {
      final lat = spot.latitude!;
      final lng = spot.longitude!;
      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  TripDay? _dayForSpot(Spot spot) {
    for (final day in widget.days) {
      if (day.id == spot.dayId) return day;
    }
    return null;
  }
}

class _MapDayScopeChips extends StatelessWidget {
  const _MapDayScopeChips({
    required this.showAllDays,
    required this.onAllDays,
    required this.onSelectedDay,
  });

  final bool showAllDays;
  final VoidCallback onAllDays;
  final VoidCallback onSelectedDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All days'),
            selected: showAllDays,
            onSelected: (_) => onAllDays(),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Selected day'),
            selected: !showAllDays,
            onSelected: (_) => onSelectedDay(),
          ),
        ],
      ),
    );
  }
}

class _StopsListLabel extends StatelessWidget {
  const _StopsListLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      'STOPS · $count',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.45,
          ),
    );
  }
}

class _SpotListTile extends StatelessWidget {
  const _SpotListTile({
    required this.index,
    required this.spot,
    required this.day,
  });

  final int index;
  final Spot spot;
  final TripDay? day;

  bool get _hasPin => spot.latitude != null && spot.longitude != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = SpotCategory.values.firstWhere(
      (c) => c.value == spot.category,
      orElse: () => SpotCategory.other,
    );

    return AppCard(
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
                  Text(day!.displayTitle, style: Theme.of(context).textTheme.bodySmall),
                if (spot.area != null)
                  Text('📍 ${spot.area!}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (!_hasPin)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.location_off_outlined,
                size: 18,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
              ),
            ),
          if (spot.visited)
            const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}
