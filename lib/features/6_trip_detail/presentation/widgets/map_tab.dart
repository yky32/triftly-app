import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../bloc/trip_detail_bloc.dart';
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

    return BlocBuilder<TripDetailBloc, TripDetailState>(
      builder: (context, state) {
        final dayIndex = _showAllDays ? null : state.selectedDayIndex;
        final visibleSpots = _visibleSpots(dayIndex);
        final mappedSpots = visibleSpots
            .where((s) => s.latitude != null && s.longitude != null)
            .toList();

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
                  if (mappedSpots.isNotEmpty) ...[
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
                    const SizedBox(height: AppSpacing.md),
                  ] else
                    AppCard(
                      color: AppColors.accentSurface,
                      child: Row(
                        children: [
                          Icon(Icons.map_outlined, size: 32, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'No mapped coordinates for this day yet.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.days.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: FilterChip(
                              label: const Text('All days'),
                              selected: _showAllDays,
                              onSelected: (_) => setState(() => _showAllDays = true),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: FilterChip(
                              label: const Text('Selected day'),
                              selected: !_showAllDays,
                              onSelected: (_) => setState(() => _showAllDays = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  SectionHeader(
                    title:
                        '${_showAllDays ? 'All spots' : "Today's route"} · ${mappedSpots.length} of ${visibleSpots.length} mapped',
                  ),
                  ...visibleSpots.asMap().entries.map((entry) {
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
                  }),
                ]),
              ),
            ),
          ],
        );
      },
    );
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

class _SpotListTile extends StatelessWidget {
  const _SpotListTile({
    required this.index,
    required this.spot,
    required this.day,
  });

  final int index;
  final Spot spot;
  final TripDay? day;

  @override
  Widget build(BuildContext context) {
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
          if (spot.visited)
            const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}
