import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum InAppNotificationKind {
  buddyJoined,
  youJoinedTrip,
}

enum InAppNotificationCategory {
  trip,
  activity,
}

/// Local in-app notification persisted on device (no push yet).
class InAppNotification extends Equatable {
  const InAppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.timestamp,
    this.tripId,
    this.unread = true,
  });

  final String id;
  final InAppNotificationKind kind;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? tripId;
  final bool unread;

  InAppNotificationCategory get category => switch (kind) {
        InAppNotificationKind.buddyJoined || InAppNotificationKind.youJoinedTrip =>
          InAppNotificationCategory.trip,
      };

  IconData get icon => switch (kind) {
        InAppNotificationKind.buddyJoined => Icons.group_add_outlined,
        InAppNotificationKind.youJoinedTrip => Icons.flight_outlined,
      };

  Color? get accent => switch (kind) {
        InAppNotificationKind.buddyJoined => null,
        InAppNotificationKind.youJoinedTrip => null,
      };

  factory InAppNotification.buddyJoined({
    required String tripId,
    required String tripName,
    required String memberName,
  }) =>
      InAppNotification(
        id: const Uuid().v4(),
        kind: InAppNotificationKind.buddyJoined,
        title: 'Buddy joined your trip',
        body: '$memberName joined $tripName.',
        timestamp: DateTime.now(),
        tripId: tripId,
      );

  factory InAppNotification.youJoinedTrip({
    required String tripId,
    required String tripName,
  }) =>
      InAppNotification(
        id: const Uuid().v4(),
        kind: InAppNotificationKind.youJoinedTrip,
        title: 'You joined a trip',
        body: '$tripName is now in your Trips list.',
        timestamp: DateTime.now(),
        tripId: tripId,
      );

  InAppNotification copyWith({bool? unread}) => InAppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        timestamp: timestamp,
        tripId: tripId,
        unread: unread ?? this.unread,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'trip_id': tripId,
        'unread': unread,
      };

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String;
    final kind = InAppNotificationKind.values.firstWhere(
      (k) => k.name == kindName,
      orElse: () => InAppNotificationKind.buddyJoined,
    );
    return InAppNotification(
      id: json['id'] as String,
      kind: kind,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      tripId: json['trip_id'] as String?,
      unread: json['unread'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, kind, title, body, timestamp, tripId, unread];
}
