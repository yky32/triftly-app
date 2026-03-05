import 'package:flutter/material.dart';
import 'package:triftly/features/map_view/models/map_location.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet that shows detail information for a [MapLocation].
/// Opened when the user taps a marker on the map.
class LocationDetailBottomSheet extends StatelessWidget {
  const LocationDetailBottomSheet({
    super.key,
    required this.location,
  });

  final MapLocation location;

  static Future<void> show(BuildContext context, {required MapLocation location}) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationDetailBottomSheet(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      child: TapToUnfocus(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BottomSheetDragHandle(),
              Text(
                location.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (location.address != null && location.address!.isNotEmpty) ...[
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
                        location.address!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (location.description != null &&
                  location.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  location.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${location.position.latitude.toStringAsFixed(5)}, '
                '${location.position.longitude.toStringAsFixed(5)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
