import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triftly/core/extensions/localizations.dart';

/// Approximate height of the floating bottom nav bar so the map content (e.g. my-location dot)
/// stays fully visible above it.
const double _kBottomNavBarHeight = 88;

/// Map tab: full-screen Google Map. Requires a valid API key in Android/iOS config.
/// Map has bottom padding so the current-location marker is not blocked by the nav bar.
/// Map is interactive: pan, zoom, and tap on the map are enabled.
class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key});

  static const LatLng _defaultCenter = LatLng(35.6762, 139.6503); // Tokyo

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final mapBottomPadding = bottomSafe + _kBottomNavBarHeight;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultCenter,
              zoom: 12,
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            onTap: (LatLng position) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                context.l10n.page_map,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
