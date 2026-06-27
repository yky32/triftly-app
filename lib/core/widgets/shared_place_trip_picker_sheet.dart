import 'package:flutter/material.dart';

import '../models/shared_place.dart';
import '../models/trip_models.dart';
import '../theme/app_spacing.dart';
import '../utils/date_formatters.dart';
import 'sheet_form_primitives.dart';
import 'sheet_scaffold.dart';
import 'triftly_bottom_sheet.dart';

/// Pick which trip receives an inbound shared place.
class SharedPlaceTripPickerSheet extends StatelessWidget {
  const SharedPlaceTripPickerSheet({
    required this.place,
    required this.trips,
    super.key,
  });

  final SharedPlace place;
  final List<Trip> trips;

  static Future<String?> show(
    BuildContext context, {
    required SharedPlace place,
    required List<Trip> trips,
  }) {
    return TriftlyBottomSheet.show<String>(
      context,
      child: SharedPlaceTripPickerSheet(place: place, trips: trips),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(
            title: 'Add to trip',
            caption: 'Choose where this place goes on your plan',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.nameLine != null)
                  Text(
                    place.nameLine!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                if (place.nameLine != null) const SizedBox(height: 4),
                Text(
                  place.addressLine,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SheetSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < trips.length; i++) ...[
                  if (i > 0) const SheetSoftListDivider(),
                  SheetOptionRow(
                    icon: Icons.flight_outlined,
                    title: trips[i].name,
                    subtitle:
                        '${trips[i].destination} · ${DateFormatters.dateRange(trips[i].startDate, trips[i].endDate)}',
                    onTap: () => Navigator.of(context).pop(trips[i].id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
