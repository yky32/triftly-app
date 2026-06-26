import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/services/cloud_sync_status.dart';

void main() {
  group('CloudSyncStatus', () {
    test('begin sets syncing and succeed clears error', () {
      final status = CloudSyncStatus();
      status.fail(Exception('network'));
      expect(status.hasError, isTrue);

      status.begin();
      expect(status.isSyncing, isTrue);

      status.succeed();
      expect(status.isSyncing, isFalse);
      expect(status.hasError, isFalse);
      expect(status.lastSuccessAt, isNotNull);
    });

    test('recordPushFailure keeps last success time', () {
      final status = CloudSyncStatus();
      status.succeed();
      final before = status.lastSuccessAt;

      status.recordPushFailure(Exception('push failed'));
      expect(status.hasError, isTrue);
      expect(status.lastSuccessAt, before);
    });

    test('lastSuccessLabel formats recent sync', () {
      final status = CloudSyncStatus();
      status.succeed();
      expect(status.lastSuccessLabel, 'Synced just now');
    });

    test('fail strips Exception prefix from message', () {
      final status = CloudSyncStatus();
      status.fail(Exception('timeout'));
      expect(status.lastError, 'timeout');
    });
  });
}
