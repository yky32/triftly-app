import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_redirect.dart';
import 'package:triftly/core/repositories/cloud_trip_sync.dart';

void main() {
  group('AuthRedirect', () {
    test('uses triftly scheme for OAuth callback', () {
      expect(AuthRedirect.url, 'triftly://login-callback');
    });
  });

  group('CloudTripSync.isCloudUserId', () {
    test('returns false for null and local ids', () {
      expect(CloudTripSync.isCloudUserId(null), isFalse);
      expect(CloudTripSync.isCloudUserId('local-abc'), isFalse);
    });

    test('returns true for Supabase auth ids', () {
      expect(
        CloudTripSync.isCloudUserId('550e8400-e29b-41d4-a716-446655440000'),
        isTrue,
      );
    });
  });
}
