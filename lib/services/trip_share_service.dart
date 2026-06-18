import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';

/// Placeholder for trip sharing via deep links (requires auth + backend).
///
/// Future: generate signed links, invite travel buddies, sync itinerary.
class TripShareService {
  TripShareService._();

  /// Placeholder deep link until backend + login-gated sharing ships.
  static String placeholderInviteLink(SavedTripSummary trip) {
    final slug = trip.name.trim().isEmpty
        ? 'trip'
        : trip.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return 'https://triftly.app/join/$slug?from=placeholder';
  }

  static String shareMessage(SavedTripSummary trip) {
    final link = placeholderInviteLink(trip);
    final name = trip.name.trim().isEmpty ? 'our trip' : trip.name;
    return 'Join $name on Triftly — plan days and spots together.\n$link';
  }
}
