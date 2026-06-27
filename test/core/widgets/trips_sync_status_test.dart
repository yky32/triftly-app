import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/bloc/cloud_sync/cloud_sync_bloc.dart';
import 'package:triftly/core/bloc/session/session_bloc.dart';
import 'package:triftly/core/models/user.dart';
import 'package:triftly/core/widgets/trips_sync_status.dart';

void main() {
  const guest = SessionState(fallbackCurrency: 'HKD');

  final signedIn = SessionState(
    user: User(
      id: '2f48d84b-fc85-4abc-82da-b6c10194bed5',
      displayName: 'Wayne',
      email: 'wayne@example.com',
      updatedAt: DateTime(2026, 1, 1),
    ),
    fallbackCurrency: 'HKD',
  );

  group('TripsSyncStatus', () {
    test('logged out shows guest offline indicator', () {
      final status = TripsSyncStatus.resolve(
        session: guest,
        sync: CloudSyncState(isConfigured: true),
      );
      expect(status.isGuestMode, isTrue);
      expect(status.label, 'Guest mode — trips stay offline on this device');
      expect(status.centerLabel, 'Guest Mode = Offline');
      expect(status.isError, isFalse);
    });

    test('logged out without cloud config shows guest offline', () {
      final status = TripsSyncStatus.resolve(
        session: guest,
        sync: CloudSyncState(isConfigured: false),
      );
      expect(status.label, 'Guest mode — cloud sync unavailable');
      expect(status.centerLabel, 'Guest Mode = Offline');
    });

    test('logged in while syncing', () {
      final status = TripsSyncStatus.resolve(
        session: signedIn,
        sync: CloudSyncState(isConfigured: true, isSyncing: true),
      );
      expect(status.label, 'Syncing trips…');
      expect(status.isSyncing, isTrue);
    });

    test('logged in with error', () {
      final status = TripsSyncStatus.resolve(
        session: signedIn,
        sync: CloudSyncState(isConfigured: true, lastError: 'offline'),
      );
      expect(status.isError, isTrue);
      expect(status.errorDetail, 'offline');
    });

    test('logged in never synced', () {
      final status = TripsSyncStatus.resolve(
        session: signedIn,
        sync: CloudSyncState(isConfigured: true),
      );
      expect(status.label, 'Not synced yet · pull to refresh');
    });

    test('logged in after recent sync', () {
      final now = DateTime.now();
      final status = TripsSyncStatus.resolve(
        session: signedIn,
        sync: CloudSyncState(
          isConfigured: true,
          lastSuccessAt: now,
        ),
      );
      expect(status.label, 'Synced just now');
      expect(status.centerLabel, TripsSyncStatus.justSyncedCenterLabel(now));
    });

    test('just synced center label shows local clock time', () {
      final syncedAt = DateTime(2026, 1, 1, 14, 32, 8);
      expect(
        TripsSyncStatus.justSyncedCenterLabel(syncedAt),
        'Just synced ${syncedAt.toLocal().hour.toString().padLeft(2, '0')}:'
        '${syncedAt.toLocal().minute.toString().padLeft(2, '0')}',
      );
    });

    test('center labels are compact', () {
      expect(
        TripsSyncStatus.resolve(
          session: guest,
          sync: CloudSyncState(isConfigured: true),
        ).centerLabel,
        'Guest Mode = Offline',
      );
      expect(
        TripsSyncStatus.resolve(
          session: signedIn,
          sync: CloudSyncState(
            isConfigured: true,
            lastSuccessAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ).centerLabel,
        '5m',
      );
    });
  });
}
