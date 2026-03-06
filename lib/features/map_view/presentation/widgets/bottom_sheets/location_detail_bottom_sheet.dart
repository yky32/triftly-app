import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:triftly/features/map_view/models/map_location.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet that shows detail information for a [MapLocation].
/// Layout and hierarchy inspired by Google Maps place detail: hero image, title, rating, action row, detail list.
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
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              loc.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            if (loc.title == 'Dropped pin' || (loc.placeId == null && loc.address != null && loc.title == loc.address)) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Pinned at this location on the map',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            if (loc.locality != null && loc.locality!.isNotEmpty && loc.locality != loc.title) ...[
              const SizedBox(height: 4),
              Text(
                loc.locality!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (loc.rating != null || (loc.types != null && loc.types!.isNotEmpty)) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (loc.rating != null) ...[
                    Text(
                      loc.rating!.toStringAsFixed(1),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...List.generate(5, (i) {
                      final filled = i < loc.rating!.round().clamp(0, 5);
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 18,
                        color: Colors.amber.shade700,
                      );
                    }),
                  ],
                  if (loc.types != null && loc.types!.isNotEmpty) ...[
                    if (loc.rating != null) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.types!.first.replaceAll('_', ' '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (loc.types != null && loc.types!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: loc.types!
                    .map((t) => _typeChip(
                          label: t.replaceAll('_', ' '),
                          colorScheme: colorScheme,
                          theme: theme,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            _ActionRow(location: loc),
            const SizedBox(height: 20),
            if (loc.address != null && loc.address!.isNotEmpty)
              _DetailRow(
                icon: Icons.location_on_outlined,
                text: loc.address!,
                colorScheme: colorScheme,
              ),
            if (loc.openingHoursText != null && loc.openingHoursText!.isNotEmpty)
              _DetailRow(
                icon: Icons.schedule_outlined,
                text: loc.openingHoursText!,
                colorScheme: colorScheme,
                accent: true,
              ),
            if (loc.website != null && loc.website!.isNotEmpty)
              _DetailRow(
                icon: Icons.language_outlined,
                text: _shortUrl(loc.website!),
                colorScheme: colorScheme,
                accent: true,
                onTap: () => _openUrl(loc.website!),
              ),
            if (loc.phoneNumber != null && loc.phoneNumber!.isNotEmpty)
              _DetailRow(
                icon: Icons.phone_outlined,
                text: loc.phoneNumber!,
                colorScheme: colorScheme,
                accent: true,
                onTap: () => _openUrl('tel:${loc.phoneNumber}'),
              ),
            if (loc.description != null && loc.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                loc.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '${loc.position.latitude.toStringAsFixed(5)}, ${loc.position.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.startsWith('www.')) return host.substring(4);
      return host.isNotEmpty ? host : url;
    } catch (_) {
      return url;
    }
  }

  static Widget _typeChip({
    required String label,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Converts [MapLocation] to [RoutineSpot] with default times and place icon.
  static RoutineSpot _routineSpotFromMapLocation(MapLocation loc) {
    return RoutineSpot(
      startTime: '9:00 AM',
      endTime: '10:00 AM',
      title: loc.title,
      description: loc.description ?? loc.address ?? '',
      location: loc.address ?? '',
      icon: Icons.place_outlined,
      color: const Color(0xFF0277BD),
    );
  }

  /// Close sheet and navigate to Routine tab with spot as route extra; routine page opens add-spot sheet.
  static void _onAddToRoutine(BuildContext context, MapLocation location) {
    final spot = _routineSpotFromMapLocation(location);
    Navigator.of(context).pop();
    if (context.mounted) context.go('/routine', extra: spot);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.location});

  final MapLocation location;

  @override
  Widget build(BuildContext context) {
    final hasCoords = location.position.latitude != 0 || location.position.longitude != 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: hasCoords
                ? () => LocationDetailBottomSheet._openUrl(
                      'https://www.google.com/maps/search/?api=1&query=${location.position.latitude},${location.position.longitude}',
                    )
                : null,
            icon: const Icon(Icons.directions_rounded, size: 20),
            label: const Text('Directions'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 10),
          if (location.phoneNumber != null && location.phoneNumber!.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => LocationDetailBottomSheet._openUrl('tel:${location.phoneNumber}'),
              icon: const Icon(Icons.phone_outlined, size: 20),
              label: const Text('Call'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          if (location.phoneNumber != null && location.phoneNumber!.isNotEmpty) const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => LocationDetailBottomSheet._onAddToRoutine(context, location),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add to routine'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
    required this.colorScheme,
    this.accent = false,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final ColorScheme colorScheme;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accent ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  decoration: accent && onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return child;
  }
}

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
