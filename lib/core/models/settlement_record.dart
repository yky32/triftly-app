import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Recorded payment between buddies (reduces outstanding balance).
class SettlementRecord extends Equatable {
  const SettlementRecord({
    required this.id,
    required this.tripId,
    required this.fromBuddyId,
    required this.toBuddyId,
    required this.amount,
    required this.currency,
    required this.paidAt,
    this.isActive = true,
  });

  final String id;
  final String tripId;
  final String fromBuddyId;
  final String toBuddyId;
  final Decimal amount;
  final String currency;
  final DateTime paidAt;
  final bool isActive;

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'from_buddy_id': fromBuddyId,
        'to_buddy_id': toBuddyId,
        'amount': amount.toString(),
        'currency': currency,
        'paid_at': paidAt.toIso8601String(),
        'is_active': isActive,
      };

  factory SettlementRecord.fromMap(Map<String, dynamic> map) => SettlementRecord(
        id: map['id'] as String,
        tripId: map['trip_id'] as String,
        fromBuddyId: map['from_buddy_id'] as String,
        toBuddyId: map['to_buddy_id'] as String,
        amount: Decimal.parse(map['amount'] as String),
        currency: map['currency'] as String,
        paidAt: DateTime.parse(map['paid_at'] as String),
        isActive: map['is_active'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, tripId, fromBuddyId, toBuddyId, amount];
}
