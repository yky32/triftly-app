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
    test('logged out shows sign-in prompt', () {
      final status = TripsSyncStatus.resolve(
        session: guest,
        sync: CloudSyncState(isConfigured: true),
      );
      expect(status.label, 'Sign in to sync trips across devices');
      expect(status.isError, isFalse);
    });

    test('logged out without cloud config shows local-only', () {
      final status = TripsSyncStatus.resolve(
        session: guest,
        sync: CloudSyncState(isConfigured: false),
      );
      expect(status.label, 'Local only — cloud sync unavailable');
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
      final status = TripsSyncStatus.resolve(
        session: signedIn,
        sync: CloudSyncState(
          isConfigured: true,
          lastSuccessAt: DateTime.now(),
        ),
      );
      expect(status.label, 'Synced just now');
      expect(status.centerLabel, 'Just synced');
    });

    test('center labels are compact', () {
      expect(
        TripsSyncStatus.resolve(
          session: guest,
          sync: CloudSyncState(isConfigured: true),
        ).centerLabel,
        'Sign in to sync',
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
