import '../models/in_app_notification.dart';
import '../models/trip_models.dart';
import '../repositories/supabase_trip_sync.dart';
import '../services/in_app_notification_store.dart';
import '../services/trip_store.dart';

/// After cloud sync, detect new trip members and notify trip owners.
class TripMemberJoinNotifier {
  const TripMemberJoinNotifier({
    required this.notifications,
    required this.sync,
    required this.store,
  });

  final InAppNotificationStore notifications;
  final SupabaseTripSync? sync;
  final TripStore store;

  Future<void> scanAfterPull(String ownerUserId) async {
    final supabase = sync;
    if (supabase == null || ownerUserId.startsWith('local-')) return;

    for (final trip in store.allTrips()) {
      if (trip.ownerId != ownerUserId || trip.isJoinedMember) continue;
      await _scanTrip(trip, supabase);
    }
  }

  Future<void> _scanTrip(Trip trip, SupabaseTripSync supabase) async {
    final members = await supabase.fetchTripMembers(trip.id);
    final currentIds = members.map((m) => m.userId).toSet();
    final knownIds = notifications.knownMemberIds(trip.id);

    if (knownIds == null) {
      await notifications.saveKnownMemberIds(trip.id, currentIds);
      return;
    }

    final newIds = currentIds.difference(knownIds);
    for (final member in members) {
      if (!newIds.contains(member.userId)) continue;
      await notifications.add(
        InAppNotification.buddyJoined(
          tripId: trip.id,
          tripName: trip.name,
          memberName: member.displayLabel,
        ),
      );
    }

    await notifications.saveKnownMemberIds(trip.id, currentIds);
  }
}
