import '../models/trip_models.dart';
import '../models/user.dart';
import '../services/trip_store.dart';

/// Assigns local/guest-created trips to a signed-in cloud user before sync.
abstract final class LocalTripMigration {
  static bool needsMigration(Trip trip) {
    if (TripStore.isMockTripId(trip.id)) return false;
    final ownerId = trip.ownerId;
    return ownerId == null || ownerId.startsWith('local-');
  }

  static Trip assignOwner(Trip trip, User user) {
    var buddies = trip.buddies.map((buddy) {
      if (buddy.isMe) {
        return buddy.copyWith(
          userId: user.id,
          name: user.displayName,
        );
      }
      return buddy;
    }).toList();

    if (!buddies.any((b) => b.isMe)) {
      buddies = [
        ...buddies,
        Buddy.create(
          name: user.displayName,
          userId: user.id,
          isMe: true,
        ),
      ];
    }

    return trip.copyWith(
      ownerId: user.id,
      buddies: buddies,
      updatedAt: DateTime.now(),
    );
  }
}
