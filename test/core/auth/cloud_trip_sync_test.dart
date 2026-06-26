import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_redirect.dart';
import 'package:triftly/core/repositories/cloud_trip_sync.dart';

void main() {
  group('AuthRedirect', () {
    test('uses triftly scheme for OAuth callback', () {
      expect(AuthRedirect.url, 'triftly://login-callback');
    });

    test('isOAuthCallback recognizes login-callback deep links', () {
      expect(
        AuthRedirect.isOAuthCallback(
          Uri.parse('triftly://login-callback/?code=abc'),
        ),
        isTrue,
      );
      expect(AuthRedirect.isOAuthCallback(Uri.parse('/profile')), isFalse);
      expect(AuthRedirect.isOAuthCallback(Uri.parse('triftly://other')), isFalse);
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
