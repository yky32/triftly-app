import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/models/trip_models.dart';
import 'package:triftly/core/models/user.dart';
import 'package:triftly/core/services/local_trip_migration.dart';

void main() {
  group('LocalTripMigration', () {
    final guestTrip = Trip(
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Tokyo',
      destination: 'Japan',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 3, 3),
      defaultCurrency: 'JPY',
      ownerId: 'local-abc',
      buddies: const [
        Buddy(id: 'b1', name: 'Guest', isMe: true),
      ],
      createdAt: DateTime(2026, 1, 1),
    );

  final user = User(
      id: '22222222-2222-4222-8222-222222222222',
      displayName: 'Wayne',
      email: 'wayne@example.com',
      updatedAt: DateTime(2026, 1, 2),
    );

    test('needsMigration for local owner', () {
      expect(LocalTripMigration.needsMigration(guestTrip), isTrue);
    });

    test('needsMigration is false for cloud-owned trip', () {
      final owned = guestTrip.copyWith(ownerId: user.id);
      expect(LocalTripMigration.needsMigration(owned), isFalse);
    });

    test('assignOwner sets cloud owner and me buddy', () {
      final migrated = LocalTripMigration.assignOwner(guestTrip, user);
      expect(migrated.ownerId, user.id);
      expect(migrated.buddies.single.isMe, isTrue);
      expect(migrated.buddies.single.userId, user.id);
      expect(migrated.buddies.single.name, 'Wayne');
    });
  });
}
