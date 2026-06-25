import '../models/trip_models.dart';
import '../services/trip_store.dart';
import '../data/trip_hive_cache.dart';

/// Optional Supabase sync — no-op until configured.
class SupabaseTripSync {
  Future<void> upsertTrip(Trip trip) async {}

  Future<void> upsertDetail(String tripId, TripDetailData detail) async {}

  Future<void> deactivateTrip(String tripId) async {}

  Future<void> pullTripsForUser(
    String userId,
    TripStore store,
    TripHiveCache cache,
  ) async {}
}
