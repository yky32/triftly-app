import 'package:decimal/decimal.dart';

import '../models/settlement_record.dart';
import '../models/trip_models.dart';

/// Pure Postgres ↔ domain mapping for Supabase trip sync.
class SupabaseTripMapper {
  const SupabaseTripMapper._();

  static String dateOnly(DateTime value) {
    final y = value.year;
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static List<TripDay> daysForTrip(Trip trip) {
    final total = trip.numberOfDays;
    return List.generate(total, (i) {
      final dayNumber = i + 1;
      return TripDay(
        id: '${trip.id}-d$dayNumber',
        tripId: trip.id,
        dayNumber: dayNumber,
        title: TripDay.defaultTitle(dayNumber, total),
        date: trip.startDate.add(Duration(days: i)),
      );
    });
  }

  static Map<String, dynamic> tripToRow(Trip trip) => {
        'id': trip.id,
        'owner_id': trip.ownerId,
        'name': trip.name,
        'destination': trip.destination,
        'start_date': dateOnly(trip.startDate),
        'end_date': dateOnly(trip.endDate),
        'default_currency': trip.defaultCurrency,
        'share_token': trip.shareToken,
        'is_active': trip.isActive,
        'created_at': trip.createdAt.toIso8601String(),
        'updated_at': (trip.updatedAt ?? DateTime.now()).toIso8601String(),
        if (trip.outboundFlight != null && !trip.outboundFlight!.isEmpty)
          'outbound_flight': trip.outboundFlight!.toMap(),
        if (trip.returnFlight != null && !trip.returnFlight!.isEmpty)
          'return_flight': trip.returnFlight!.toMap(),
      };

  static Map<String, dynamic> buddyToRow(Buddy buddy, String tripId) => {
        'id': buddy.id,
        'trip_id': tripId,
        'name': buddy.name,
        'avatar_color': buddy.avatarColor,
        'user_id': buddy.userId,
        'is_me': buddy.isMe,
      };

  static Map<String, dynamic> memberToRow(String tripId, String userId) => {
        'trip_id': tripId,
        'user_id': userId,
        'role': 'owner',
      };

  static Map<String, dynamic> dayToRow(TripDay day) => {
        'id': day.id,
        'trip_id': day.tripId,
        'day_number': day.dayNumber,
        'title': day.title,
        'date': dateOnly(day.date),
      };

  static Map<String, dynamic> spotToRow(Spot spot) => {
        'id': spot.id,
        'trip_id': spot.tripId,
        'day_id': spot.dayId,
        'name': spot.name,
        'address': spot.address,
        'area': spot.area,
        'category': spot.category,
        'opening_hours': spot.openingHours,
        'estimated_duration': spot.estimatedDuration,
        'estimated_cost': spot.estimatedCost?.toDouble(),
        'cost_currency': spot.costCurrency,
        'latitude': spot.latitude,
        'longitude': spot.longitude,
        'notes': spot.notes,
        'order_index': spot.orderIndex,
        'visited': spot.visited,
        'is_active': spot.isActive,
        'updated_at': spot.updatedAt?.toIso8601String(),
      };

  static Map<String, dynamic> expenseToRow(Expense expense) => {
        'id': expense.id,
        'trip_id': expense.tripId,
        'day_id': expense.dayId,
        'title': expense.title,
        'amount': expense.amount.toDouble(),
        'currency': expense.currency,
        'paid_by_id': expense.paidById,
        'category': expense.category,
        'created_at': expense.createdAt.toIso8601String(),
        'is_active': expense.isActive,
        'updated_at': expense.updatedAt?.toIso8601String(),
      };

  static Map<String, dynamic> splitToRow(ExpenseSplit split) => {
        'id': split.id,
        'expense_id': split.expenseId,
        'buddy_id': split.buddyId,
        'share_amount': split.shareAmount.toDouble(),
        'split_type': split.splitType.name,
        'split_config_value': split.splitConfigValue?.toDouble(),
      };

  static Map<String, dynamic> settlementToRow(SettlementRecord record) => {
        'id': record.id,
        'trip_id': record.tripId,
        'from_buddy_id': record.fromBuddyId,
        'to_buddy_id': record.toBuddyId,
        'amount': record.amount.toDouble(),
        'currency': record.currency,
        'paid_at': record.paidAt.toIso8601String(),
        'is_active': record.isActive,
      };

  static Trip tripFromRow(
    Map<String, dynamic> row,
    List<Buddy> buddies,
  ) {
    FlightLeg? legFromJson(dynamic raw) {
      if (raw == null) return null;
      return FlightLeg.fromMap(Map<String, dynamic>.from(raw as Map));
    }

    return Trip(
      id: row['id'] as String,
      name: row['name'] as String,
      destination: row['destination'] as String,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      defaultCurrency: row['default_currency'] as String,
      outboundFlight: legFromJson(row['outbound_flight']),
      returnFlight: legFromJson(row['return_flight']),
      buddies: buddies,
      shareToken: row['share_token'] as String?,
      ownerId: row['owner_id'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
      isActive: row['is_active'] as bool? ?? true,
    );
  }

  static Buddy buddyFromRow(Map<String, dynamic> row) => Buddy(
        id: row['id'] as String,
        name: row['name'] as String,
        avatarColor: row['avatar_color'] as String?,
        userId: row['user_id'] as String?,
        isMe: row['is_me'] as bool? ?? false,
      );

  static TripDay dayFromRow(Map<String, dynamic> row) => TripDay(
        id: row['id'] as String,
        tripId: row['trip_id'] as String,
        dayNumber: row['day_number'] as int,
        title: row['title'] as String?,
        date: DateTime.parse(row['date'] as String),
      );

  static Spot spotFromRow(Map<String, dynamic> row) => Spot(
        id: row['id'] as String,
        dayId: row['day_id'] as String,
        tripId: row['trip_id'] as String,
        name: row['name'] as String,
        address: row['address'] as String?,
        area: row['area'] as String?,
        category: row['category'] as String? ?? 'other',
        openingHours: row['opening_hours'] as String?,
        estimatedDuration: row['estimated_duration'] as String?,
        estimatedCost: row['estimated_cost'] != null
            ? Decimal.parse(row['estimated_cost'].toString())
            : null,
        costCurrency: row['cost_currency'] as String?,
        latitude: (row['latitude'] as num?)?.toDouble(),
        longitude: (row['longitude'] as num?)?.toDouble(),
        notes: row['notes'] as String?,
        orderIndex: row['order_index'] as int? ?? 0,
        visited: row['visited'] as bool? ?? false,
        isActive: row['is_active'] as bool? ?? true,
        updatedAt: row['updated_at'] != null
            ? DateTime.parse(row['updated_at'] as String)
            : null,
      );

  static Expense expenseFromRow(
    Map<String, dynamic> row,
    List<ExpenseSplit> splits,
  ) =>
      Expense(
        id: row['id'] as String,
        tripId: row['trip_id'] as String,
        dayId: row['day_id'] as String?,
        title: row['title'] as String,
        amount: Decimal.parse(row['amount'].toString()),
        currency: row['currency'] as String,
        paidById: row['paid_by_id'] as String,
        category: row['category'] as String? ?? 'other',
        splits: splits,
        createdAt: DateTime.parse(row['created_at'] as String),
        isActive: row['is_active'] as bool? ?? true,
        updatedAt: row['updated_at'] != null
            ? DateTime.parse(row['updated_at'] as String)
            : null,
      );

  static ExpenseSplit splitFromRow(Map<String, dynamic> row) => ExpenseSplit(
        id: row['id'] as String,
        expenseId: row['expense_id'] as String,
        buddyId: row['buddy_id'] as String,
        splitType: SplitType.values.firstWhere(
          (e) => e.name == row['split_type'],
          orElse: () => SplitType.equal,
        ),
        shareAmount: Decimal.parse(row['share_amount'].toString()),
        splitConfigValue: row['split_config_value'] != null
            ? Decimal.parse(row['split_config_value'].toString())
            : null,
      );

  static SettlementRecord settlementFromRow(Map<String, dynamic> row) =>
      SettlementRecord(
        id: row['id'] as String,
        tripId: row['trip_id'] as String,
        fromBuddyId: row['from_buddy_id'] as String,
        toBuddyId: row['to_buddy_id'] as String,
        amount: Decimal.parse(row['amount'].toString()),
        currency: row['currency'] as String,
        paidAt: DateTime.parse(row['paid_at'] as String),
        isActive: row['is_active'] as bool? ?? true,
      );
}
