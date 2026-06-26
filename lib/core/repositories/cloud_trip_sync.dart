import '../models/user.dart';
import '../sync/cloud_sync_reporter.dart';
import 'hive_trip_repository.dart';

/// Shared cloud sync entry points for bootstrap and Trips refresh.
abstract final class CloudTripSync {
  static bool isCloudUserId(String? userId) =>
      userId != null && !userId.startsWith('local-');

  static Future<void> syncForUser(
    User user,
    HiveTripRepository repository, {
    CloudSyncReporter? syncReporter,
    bool migrateLocalTrips = false,
  }) async {
    if (!isCloudUserId(user.id)) return;

    if (migrateLocalTrips) {
      await repository.migrateLocalTripsToCloud(user);
    }
    await repository.pullFromSupabase(user.id, syncReporter: syncReporter);
  }
}
