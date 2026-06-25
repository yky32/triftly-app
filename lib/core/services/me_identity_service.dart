import '../models/trip_models.dart';
import '../models/user.dart';
import 'profile_preferences.dart';

/// Resolves which buddy represents the signed-in traveler on a trip.
abstract final class MeIdentityService {
  static String displayName({
    User? user,
    ProfilePreferences? preferences,
  }) {
    if (user != null) return user.displayName;
    return preferences?.guestDisplayName ?? ProfilePreferences.instance.guestDisplayName;
  }

  static Buddy? buddyForTrip(
    Trip trip, {
    User? user,
    ProfilePreferences? preferences,
  }) {
    if (user != null) {
      for (final buddy in trip.buddies) {
        if (buddy.userId == user.id) return buddy;
      }
    }

    for (final buddy in trip.buddies) {
      if (buddy.isMe) return buddy;
    }

    final name = displayName(user: user, preferences: preferences);
    for (final buddy in trip.buddies) {
      if (buddy.name == name) return buddy;
    }

    return trip.buddies.isNotEmpty ? trip.buddies.first : null;
  }

  /// Buddy row for the current user when creating a trip.
  static Buddy creatorBuddy({
    required User? user,
    required ProfilePreferences preferences,
  }) {
    if (user != null) {
      return Buddy.create(
        name: user.displayName,
        userId: user.id,
        isMe: true,
      );
    }
    return Buddy.create(
      name: preferences.guestDisplayName,
      isMe: true,
    );
  }
}
