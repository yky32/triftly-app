import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/in_app_notification.dart';

/// Device-local inbox for trip join and activity events.
class InAppNotificationStore extends ChangeNotifier {
  InAppNotificationStore(this._prefs);

  static InAppNotificationStore? _instance;

  static InAppNotificationStore get instance {
    assert(_instance != null, 'InAppNotificationStore.initialize() must be called first');
    return _instance!;
  }

  static const _itemsKey = 'in_app_notifications_v1';
  static const _knownMembersPrefix = 'known_trip_members_v1_';
  static const _maxItems = 100;

  final SharedPreferences _prefs;
  List<InAppNotification> _items = const [];

  List<InAppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => n.unread).length;

  static Future<InAppNotificationStore> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final store = InAppNotificationStore(prefs);
    await store._load();
    _instance = store;
    return store;
  }

  Future<void> _load() async {
    final raw = _prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) {
      _items = const [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _items = list
          .map((e) => InAppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      _items = const [];
    }
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_items.map((n) => n.toJson()).toList());
    await _prefs.setString(_itemsKey, encoded);
    notifyListeners();
  }

  Future<void> add(InAppNotification notification) async {
    _items = [notification, ..._items.where((n) => n.id != notification.id)];
    if (_items.length > _maxItems) {
      _items = _items.sublist(0, _maxItems);
    }
    await _persist();
  }

  Future<void> markAllRead() async {
    if (_items.every((n) => !n.unread)) return;
    _items = _items.map((n) => n.copyWith(unread: false)).toList();
    await _persist();
  }

  Set<String>? knownMemberIds(String tripId) {
    final raw = _prefs.getString('$_knownMembersPrefix$tripId');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveKnownMemberIds(String tripId, Set<String> userIds) async {
    await _prefs.setString(
      '$_knownMembersPrefix$tripId',
      jsonEncode(userIds.toList()),
    );
  }
}
