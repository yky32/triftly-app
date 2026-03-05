import 'package:flutter/material.dart';
import 'package:triftly/features/map_view/models/map_location.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet that shows detail information for a [MapLocation].
/// Supports data from our markers, Geocoding (address), and Places (rating, hours, photo).
/// Opened when the user taps a marker or any point on the map.
class LocationDetailBottomSheet extends StatelessWidget {
  const LocationDetailBottomSheet({
    super.key,
    required this.location,
    this.locationFuture,
  });

  final MapLocation? location;
  final Future<MapLocation>? locationFuture;

  static Future<void> show(BuildContext context, {required MapLocation location}) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationDetailBottomSheet(location: location),
    );
  }

  /// Opens the sheet immediately with a minimal loading state, then shows content when [locationFuture] completes.
  static Future<void> showWithFuture(BuildContext context, {required Future<MapLocation> locationFuture}) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationDetailBottomSheet(location: null, locationFuture: locationFuture),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (locationFuture != null) {
      return _LocationDetailSheetWithFuture(locationFuture: locationFuture!);
    }
    return _sheetContainer(context, _buildContent(context, location!));
  }

  static Widget _sheetContainer(BuildContext context, Widget child) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: child,
    );
  }

  static Widget _buildContent(BuildContext context, MapLocation loc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TapToUnfocus(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BottomSheetDragHandle(),
              if (loc.photoUrl != null && loc.photoUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    loc.photoUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                loc.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (loc.locality != null && loc.locality != loc.title) ...[
                const SizedBox(height: 4),
                Text(
                  loc.locality!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (loc.address != null && loc.address!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.address!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (loc.rating != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.rating!.toStringAsFixed(1),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (loc.types != null && loc.types!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: loc.types!
                              .take(5)
                              .map((t) => _chip(context, t))
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (loc.types != null && loc.types!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: loc.types!.take(8).map((t) => _chip(context, t)).toList(),
                ),
              ],
              if (loc.openingHoursText != null &&
                  loc.openingHoursText!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.openingHoursText!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (loc.description != null && loc.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  loc.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
              if (loc.website != null && loc.website!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.link, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.website!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (loc.phoneNumber != null && loc.phoneNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      loc.phoneNumber!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${loc.position.latitude.toStringAsFixed(5)}, '
                '${loc.position.longitude.toStringAsFixed(5)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static Widget _chip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Sheet that opens immediately with a minimal loading state, then shows location content.
class _LocationDetailSheetWithFuture extends StatefulWidget {
  const _LocationDetailSheetWithFuture({required this.locationFuture});

  final Future<MapLocation> locationFuture;

  @override
  State<_LocationDetailSheetWithFuture> createState() => _LocationDetailSheetWithFutureState();
}

class _LocationDetailSheetWithFutureState extends State<_LocationDetailSheetWithFuture> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LocationDetailBottomSheet._sheetContainer(
      context,
      FutureBuilder<MapLocation>(
        future: widget.locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return LocationDetailBottomSheet._buildContent(context, snapshot.data!);
          }
          return TapToUnfocus(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BottomSheetDragHandle(),
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.primary.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Loading place details',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                            letterSpacing: 0.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
