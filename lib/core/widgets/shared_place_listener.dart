import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_page.dart';
import '../models/shared_place.dart';
import '../models/trip_models.dart';
import '../navigation/shared_place_flow.dart';
import '../services/shared_place_bridge.dart';
import '../services/trip_store.dart';
import '../share/inbound_debug_log.dart';
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
    inboundDebugLog('SharedPlaceListener installed', kind: InboundLogKind.flow);
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
      inboundDebugLog('App resumed — polling inbound share', kind: InboundLogKind.flow);
      _pollInboundShare();
    }
  }

  Future<void> _pollInboundShare() async {
    var source = 'flow-pending';
    var place = SharedPlaceFlow.consumePending();
    if (place == null) {
      final raw = await SharedPlaceBridge.consumePending();
      if (raw == null) return;
      source = 'native-bridge';
      place = SharedMapParser.parse(raw) ?? SharedPlace(raw: raw, address: raw);
      inboundDebugLog(
        'Parsed ($source) → ${inboundPlaceSummary(place)}',
        kind: InboundLogKind.parse,
      );
    } else {
      inboundDebugLog(
        'Consumed ($source) → ${inboundPlaceSummary(place)}',
        kind: InboundLogKind.flow,
      );
    }

    if (SharedPlaceFlow.shouldSuppress(place.raw)) {
      inboundDebugLog(
        'Poll ignored (duplicate) · ${inboundPlaceSummary(place)}',
        kind: InboundLogKind.suppress,
      );
      return;
    }

    if (_handling) {
      SharedPlaceFlow.stage(place);
      inboundDebugLog(
        'Queued while handling · ${inboundPlaceSummary(place)}',
        kind: InboundLogKind.flow,
      );
      return;
    }

    await _presentTripPicker(place);
  }

  /// Waits until splash / deep-link routing settles so sheets can present.
  Future<BuildContext?> _awaitNavigatorContext() async {
    for (var attempt = 0; attempt < 40; attempt++) {
      final context = widget.router.routerDelegate.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        final path = widget.router.routerDelegate.currentConfiguration.fullPath;
        if (path != '/splash' && !path.startsWith('triftly:')) {
          return context;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return widget.router.routerDelegate.navigatorKey.currentContext;
  }

  Future<void> _presentTripPicker(SharedPlace place) async {
    if (_handling) return;
    _handling = true;
    SharedPlaceFlow.beginHandling(place.raw);
    var handled = false;

    try {
      inboundDebugLog(
        'Present flow → ${inboundPlaceSummary(place)}',
        kind: InboundLogKind.flow,
      );

      final context = await _awaitNavigatorContext();
      if (context == null || !context.mounted) {
        SharedPlaceFlow.stage(place);
        inboundDebugLog(
          'Navigator not ready — re-staged · ${inboundPlaceSummary(place)}',
          kind: InboundLogKind.route,
        );
        return;
      }

      final trips = _editableTrips();
      if (trips.isEmpty) {
        SharedPlaceFlow.clear();
        await SharedPlaceBridge.consumePending();
        if (!context.mounted) return;
        inboundDebugLog('No editable trips — showing snackbar', kind: InboundLogKind.flow);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create a trip first, then share places from Maps'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // One editable trip — skip picker, open Add Spot directly.
      if (trips.length == 1) {
        inboundDebugLog(
          'Single trip auto-select → ${trips.first.name} (${trips.first.id})',
          kind: InboundLogKind.flow,
        );
        _openAddSpotForTrip(trips.first.id, place);
        handled = true;
        return;
      }

      // Multiple trips — bottom sheet to pick destination trip first.
      if (!context.mounted) {
        SharedPlaceFlow.stage(place);
        inboundDebugLog('Context lost before picker — re-staged', kind: InboundLogKind.route);
        return;
      }
      inboundDebugLog(
        'Showing trip picker (${trips.length} editable trips)',
        kind: InboundLogKind.flow,
      );
      final pickedId = await SharedPlaceTripPickerSheet.show(
        context,
        place: place,
        trips: trips,
      );
      if (pickedId == null || !context.mounted) {
        SharedPlaceFlow.consumePending();
        inboundDebugLog('Trip picker dismissed', kind: InboundLogKind.flow);
        return;
      }

      final picked = trips.firstWhere((t) => t.id == pickedId);
      inboundDebugLog(
        'Trip picked → ${picked.name} ($pickedId)',
        kind: InboundLogKind.flow,
      );
      _openAddSpotForTrip(pickedId, place);
      handled = true;
    } finally {
      _handling = false;
      if (handled) {
        SharedPlaceFlow.markHandled(place.raw);
      } else {
        SharedPlaceFlow.clearActive();
      }
      if (SharedPlaceFlow.pendingPlace != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _pollInboundShare());
      }
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
    inboundDebugLog(
      'Navigate + arm Add Spot → tripId=$tripId · ${inboundPlaceSummary(place)}',
      kind: InboundLogKind.success,
    );
    // Shell routes require go — push breaks StatefulShellRoute matching.
    widget.router.go('${AppPage.plan.path}/$tripId');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
