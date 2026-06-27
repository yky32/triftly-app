import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triftly/core/models/in_app_notification.dart';
import 'package:triftly/core/services/in_app_notification_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('add and mark all read', () async {
    final store = await InAppNotificationStore.initialize();

    await store.add(
      InAppNotification.buddyJoined(
        tripId: 'trip-1',
        tripName: 'Tokyo 2026',
        memberName: 'Alex',
      ),
    );

    expect(store.items, hasLength(1));
    expect(store.unreadCount, 1);
    expect(store.items.first.title, 'Buddy joined your trip');

    await store.markAllRead();
    expect(store.unreadCount, 0);
  });

  test('known member baseline avoids duplicate join alerts', () async {
    final store = await InAppNotificationStore.initialize();

    expect(store.knownMemberIds('trip-1'), isNull);

    await store.saveKnownMemberIds('trip-1', {'user-a'});
    expect(store.knownMemberIds('trip-1'), {'user-a'});
  });
}
