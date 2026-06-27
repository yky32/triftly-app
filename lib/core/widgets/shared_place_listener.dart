import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_page.dart';
import '../models/shared_place.dart';
import '../models/trip_models.dart';
import '../navigation/shared_place_flow.dart';
import '../services/shared_place_bridge.dart';
import '../services/trip_store.dart';
import '../utils/shared_map_parser.dart';
import 'shared_place_trip_picker_sheet.dart';

/// Polls native share payloads and routes into Add Spot flow.
class SharedPlaceListener extends StatefulWidget {
  const SharedPlaceListener({required this.child, required this.router, super.key});

  final Widget child;
  final GoRouter router;

  @override
  State<SharedPlaceListener> createState() => _SharedPlaceListenerState();
}

class _SharedPlaceListenerState extends State<SharedPlaceListener> with WidgetsBindingObserver {
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SharedPlaceBridge.install(onSharedUrlReady: _pollInboundShare);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pollInboundShare());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollInboundShare();
    }
  }

  Future<void> _pollInboundShare() async {
    if (_handling) return;

    final raw = await SharedPlaceBridge.consumePending();
    if (raw == null) return;

    final place = SharedMapParser.parse(raw) ?? SharedPlace(raw: raw, address: raw);
    SharedPlaceFlow.setPending(place);
    await _presentTripPicker(place);
  }

  Future<void> _presentTripPicker(SharedPlace place) async {
    if (_handling) return;
    _handling = true;

    try {
      final context = widget.router.routerDelegate.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      final trips = _editableTrips();
      if (trips.isEmpty) {
        SharedPlaceFlow.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create a trip first, then share places from Maps'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (trips.length == 1) {
        _openAddSpotForTrip(trips.first.id, place);
        return;
      }

      final pickedId = await SharedPlaceTripPickerSheet.show(
        context,
        place: place,
        trips: trips,
      );
      if (pickedId == null || !context.mounted) {
        SharedPlaceFlow.consumePending();
        return;
      }

      _openAddSpotForTrip(pickedId, place);
    } finally {
      _handling = false;
    }
  }

  List<Trip> _editableTrips() {
    return TripStore.instance
        .allTrips()
        .where((t) => t.canEditTripContent && !TripStore.isMockTripId(t.id))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  void _openAddSpotForTrip(String tripId, SharedPlace place) {
    SharedPlaceFlow.consumePending();
    SharedPlaceFlow.arm(tripId: tripId, place: place);
    // Shell routes require go — push breaks StatefulShellRoute matching.
    widget.router.go('${AppPage.plan.path}/$tripId');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
