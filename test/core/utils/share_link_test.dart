import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/models/trip_models.dart';
import 'package:triftly/core/utils/share_link.dart';

Trip _trip({String? membershipRole}) => Trip(
      id: 'trip-1',
      name: 'Tokyo',
      destination: 'Japan',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 7),
      defaultCurrency: 'JPY',
      ownerId: 'owner',
      createdAt: DateTime(2026, 5, 1),
      membershipRole: membershipRole,
    );

void main() {
  group('ShareLink', () {
    test('forTrip uses shareToken when present', () {
      final trip = _trip().copyWith(shareToken: 'abc123');
      expect(ShareLink.forTrip(trip), 'https://triftly.app/s/abc123');
    });

    test('forTrip falls back to trip id', () {
      expect(ShareLink.forTrip(_trip()), 'https://triftly.app/s/trip-1');
    });

    test('tokenFromUri parses https universal link', () {
      expect(
        ShareLink.tokenFromUri(Uri.parse('https://triftly.app/s/my-token')),
        'my-token',
      );
    });

    test('tokenFromUri parses triftly custom scheme', () {
      expect(
        ShareLink.tokenFromUri(Uri.parse('triftly://s/my-token')),
        'my-token',
      );
    });

    test('tokenFromUri returns null for unrelated urls', () {
      expect(ShareLink.tokenFromUri(Uri.parse('https://example.com/foo')), isNull);
      expect(ShareLink.tokenFromUri(null), isNull);
    });
  });

  group('Trip membership', () {
    test('preview is read-only and hidden from trip list', () {
      final trip = _trip(membershipRole: 'preview');
      expect(trip.isPreviewShare, isTrue);
      expect(trip.isReadOnlyForCurrentUser, isTrue);
      expect(trip.appearsInTripList, isFalse);
    });

    test('viewer is joined read-only and appears in trip list', () {
      final trip = _trip(membershipRole: 'viewer');
      expect(trip.isJoinedMember, isTrue);
      expect(trip.isViewer, isTrue);
      expect(trip.isReadOnlyForCurrentUser, isTrue);
      expect(trip.canEditTripContent, isFalse);
      expect(trip.canManageTripSettings, isFalse);
      expect(trip.membershipBadgeLabel, 'Shared · view only');
      expect(trip.appearsInTripList, isTrue);
    });

    test('editor is joined and editable but cannot manage settings', () {
      final trip = _trip(membershipRole: 'editor');
      expect(trip.isJoinedMember, isTrue);
      expect(trip.isEditor, isTrue);
      expect(trip.isReadOnlyForCurrentUser, isFalse);
      expect(trip.canEditTripContent, isTrue);
      expect(trip.canManageTripSettings, isFalse);
      expect(trip.membershipBadgeLabel, 'Shared · can edit');
    });

    test('owner can manage settings and edit content', () {
      final trip = _trip();
      expect(trip.isJoinedMember, isFalse);
      expect(trip.canManageTripSettings, isTrue);
      expect(trip.canEditTripContent, isTrue);
      expect(trip.membershipBadgeLabel, isNull);
    });

    test('TripMemberSummary displayLabel prefers name then email', () {
      const withName = TripMemberSummary(
        userId: 'uuid-1',
        role: 'viewer',
        displayName: 'Alice',
        email: 'alice@example.com',
      );
      expect(withName.displayLabel, 'Alice');
      expect(withName.subtitle, 'alice@example.com');

      const emailOnly = TripMemberSummary(
        userId: 'uuid-2',
        role: 'editor',
        email: 'bob@example.com',
      );
      expect(emailOnly.displayLabel, 'bob@example.com');
      expect(emailOnly.subtitle, isNull);
    });
  });
}
