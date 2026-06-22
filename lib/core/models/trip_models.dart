import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Buddy extends Equatable {
  final String id;
  final String name;
  final String? avatarColor;

  const Buddy({
    required this.id,
    required this.name,
    this.avatarColor,
  });

  factory Buddy.create({required String name}) {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4',
      'FFEAA7', 'DDA0DD', '74B9FF', 'A29BFE',
    ];
    return Buddy(
      id: const Uuid().v4(),
      name: name,
      avatarColor: colors[name.hashCode % colors.length],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatar_color': avatarColor,
      };

  factory Buddy.fromMap(Map<String, dynamic> map) => Buddy(
        id: map['id'] as String,
        name: map['name'] as String,
        avatarColor: map['avatar_color'] as String?,
      );

  @override
  List<Object?> get props => [id, name, avatarColor];
}

enum TripPhase { upcoming, inProgress, completed }

/// Outbound or return flight details.
class FlightLeg extends Equatable {
  const FlightLeg({
    this.flightNumber,
    this.departAt,
    this.fromAirport,
    this.toAirport,
  });

  final String? flightNumber;
  final DateTime? departAt;
  final String? fromAirport;
  final String? toAirport;

  bool get isEmpty =>
      (flightNumber == null || flightNumber!.isEmpty) &&
      departAt == null &&
      (fromAirport == null || fromAirport!.isEmpty) &&
      (toAirport == null || toAirport!.isEmpty);

  Map<String, dynamic> toMap() => {
        'flight_number': flightNumber,
        'depart_at': departAt?.toIso8601String(),
        'from_airport': fromAirport,
        'to_airport': toAirport,
      };

  factory FlightLeg.fromMap(Map<String, dynamic> map) => FlightLeg(
        flightNumber: map['flight_number'] as String?,
        departAt: map['depart_at'] != null ? DateTime.parse(map['depart_at'] as String) : null,
        fromAirport: map['from_airport'] as String?,
        toAirport: map['to_airport'] as String?,
      );

  @override
  List<Object?> get props => [flightNumber, departAt, fromAirport, toAirport];
}

class Trip extends Equatable {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String defaultCurrency;
  final FlightLeg? outboundFlight;
  final FlightLeg? returnFlight;
  final List<Buddy> buddies;
  final String? ownerToken;
  final String? shareToken;
  final DateTime createdAt;

  const Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.defaultCurrency,
    this.outboundFlight,
    this.returnFlight,
    this.buddies = const [],
    this.ownerToken,
    this.shareToken,
    required this.createdAt,
  });

  int get numberOfDays => endDate.difference(startDate).inDays + 1;

  DateTime get startDay => DateTime(startDate.year, startDate.month, startDate.day);

  DateTime get endDay => DateTime(endDate.year, endDate.month, endDate.day);

  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Trip hasn't started yet (by calendar day).
  bool get isUpcoming => startDay.isAfter(today);

  /// Trip is active today (inclusive of start and end dates).
  bool get isInProgress => !startDay.isAfter(today) && !endDay.isBefore(today);

  /// Trip has ended (by calendar day).
  bool get isCompleted => endDay.isBefore(today);

  /// @deprecated Use [isCompleted]
  bool get isPast => isCompleted;

  TripPhase get phase {
    if (isCompleted) return TripPhase.completed;
    if (isInProgress) return TripPhase.inProgress;
    return TripPhase.upcoming;
  }

  /// 1-based day index while in progress; `null` otherwise.
  int? get currentDayNumber {
    if (!isInProgress) return null;
    return today.difference(startDay).inDays + 1;
  }

  int? get daysUntilStart {
    if (!isUpcoming) return null;
    return startDay.difference(today).inDays;
  }

  int? get daysRemaining {
    if (!isInProgress) return null;
    return endDay.difference(today).inDays;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'destination': destination,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'default_currency': defaultCurrency,
        'outbound_flight': outboundFlight?.toMap(),
        'return_flight': returnFlight?.toMap(),
        'buddies': buddies.map((b) => b.toMap()).toList(),
        'owner_token': ownerToken,
        'share_token': shareToken,
        'created_at': createdAt.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        name: map['name'] as String,
        destination: map['destination'] as String,
        startDate: DateTime.parse(map['start_date'] as String),
        endDate: DateTime.parse(map['end_date'] as String),
        defaultCurrency: map['default_currency'] as String,
        outboundFlight: map['outbound_flight'] != null
            ? FlightLeg.fromMap(map['outbound_flight'] as Map<String, dynamic>)
            : (map['flight_number'] != null
                ? FlightLeg(flightNumber: map['flight_number'] as String?)
                : null),
        returnFlight: map['return_flight'] != null
            ? FlightLeg.fromMap(map['return_flight'] as Map<String, dynamic>)
            : null,
        buddies: (map['buddies'] as List<dynamic>)
            .map((b) => Buddy.fromMap(b as Map<String, dynamic>))
            .toList(),
        ownerToken: map['owner_token'] as String?,
        shareToken: map['share_token'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Trip copyWith({
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? defaultCurrency,
    FlightLeg? outboundFlight,
    FlightLeg? returnFlight,
    List<Buddy>? buddies,
    String? ownerToken,
    String? shareToken,
  }) =>
      Trip(
        id: id,
        name: name ?? this.name,
        destination: destination ?? this.destination,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
        outboundFlight: outboundFlight ?? this.outboundFlight,
        returnFlight: returnFlight ?? this.returnFlight,
        buddies: buddies ?? this.buddies,
        ownerToken: ownerToken ?? this.ownerToken,
        shareToken: shareToken ?? this.shareToken,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, name, destination, startDate, endDate];
}

class TripDay extends Equatable {
  final String id;
  final String tripId;
  final int dayNumber;
  final String? title;
  final DateTime date;

  const TripDay({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.title,
    required this.date,
  });

  String get displayTitle => title ?? 'Day $dayNumber';

  String get displayDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'day_number': dayNumber,
        'title': title,
        'date': date.toIso8601String(),
      };

  factory TripDay.fromMap(Map<String, dynamic> map) => TripDay(
        id: map['id'] as String,
        tripId: map['trip_id'] as String,
        dayNumber: map['day_number'] as int,
        title: map['title'] as String?,
        date: DateTime.parse(map['date'] as String),
      );

  @override
  List<Object?> get props => [id, tripId, dayNumber];
}

class Spot extends Equatable {
  final String id;
  final String dayId;
  final String tripId;
  final String name;
  final String? address;
  final String? area;
  final String category;
  final String? openingHours;
  final String? estimatedDuration;
  final Decimal? estimatedCost;
  final String? costCurrency;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final int orderIndex;

  const Spot({
    required this.id,
    required this.dayId,
    required this.tripId,
    required this.name,
    this.address,
    this.area,
    this.category = 'other',
    this.openingHours,
    this.estimatedDuration,
    this.estimatedCost,
    this.costCurrency,
    this.latitude,
    this.longitude,
    this.notes,
    required this.orderIndex,
  });

  Spot copyWith({
    String? name,
    String? address,
    String? area,
    String? category,
    String? openingHours,
    String? estimatedDuration,
    Decimal? estimatedCost,
    String? costCurrency,
    double? latitude,
    double? longitude,
    String? notes,
    int? orderIndex,
  }) =>
      Spot(
        id: id,
        dayId: dayId,
        tripId: tripId,
        name: name ?? this.name,
        address: address ?? this.address,
        area: area ?? this.area,
        category: category ?? this.category,
        openingHours: openingHours ?? this.openingHours,
        estimatedDuration: estimatedDuration ?? this.estimatedDuration,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        costCurrency: costCurrency ?? this.costCurrency,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        notes: notes ?? this.notes,
        orderIndex: orderIndex ?? this.orderIndex,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'day_id': dayId,
        'trip_id': tripId,
        'name': name,
        'address': address,
        'area': area,
        'category': category,
        'opening_hours': openingHours,
        'estimated_duration': estimatedDuration,
        'estimated_cost': estimatedCost?.toString(),
        'cost_currency': costCurrency,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
        'order_index': orderIndex,
      };

  factory Spot.fromMap(Map<String, dynamic> map) => Spot(
        id: map['id'] as String,
        dayId: map['day_id'] as String,
        tripId: map['trip_id'] as String,
        name: map['name'] as String,
        address: map['address'] as String?,
        area: map['area'] as String?,
        category: map['category'] as String? ?? 'other',
        openingHours: map['opening_hours'] as String?,
        estimatedDuration: map['estimated_duration'] as String?,
        estimatedCost: map['estimated_cost'] != null
            ? Decimal.parse(map['estimated_cost'] as String)
            : null,
        costCurrency: map['cost_currency'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        notes: map['notes'] as String?,
        orderIndex: map['order_index'] as int,
      );

  @override
  List<Object?> get props => [id, dayId, name, orderIndex];
}

class Expense extends Equatable {
  final String id;
  final String tripId;
  final String? dayId;
  final String title;
  final Decimal amount;
  final String currency;
  final String paidById;
  final String category;
  final List<ExpenseSplit> splits;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.tripId,
    this.dayId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paidById,
    this.category = 'other',
    this.splits = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, tripId, title, amount];

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'day_id': dayId,
        'title': title,
        'amount': amount.toString(),
        'currency': currency,
        'paid_by_id': paidById,
        'category': category,
        'splits': splits.map((s) => s.toMap()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        tripId: map['trip_id'] as String,
        dayId: map['day_id'] as String?,
        title: map['title'] as String,
        amount: Decimal.parse(map['amount'] as String),
        currency: map['currency'] as String,
        paidById: map['paid_by_id'] as String,
        category: map['category'] as String? ?? 'other',
        splits: (map['splits'] as List<dynamic>?)
                ?.map((s) => ExpenseSplit.fromMap(s as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class ExpenseSplit extends Equatable {
  final String id;
  final String expenseId;
  final String buddyId;
  final SplitType splitType;
  final Decimal shareAmount;

  const ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.buddyId,
    required this.splitType,
    required this.shareAmount,
  });

  @override
  List<Object?> get props => [id, expenseId, buddyId];

  Map<String, dynamic> toMap() => {
        'id': id,
        'expense_id': expenseId,
        'buddy_id': buddyId,
        'split_type': splitType.name,
        'share_amount': shareAmount.toString(),
      };

  factory ExpenseSplit.fromMap(Map<String, dynamic> map) => ExpenseSplit(
        id: map['id'] as String,
        expenseId: map['expense_id'] as String,
        buddyId: map['buddy_id'] as String,
        splitType: SplitType.values.firstWhere(
          (e) => e.name == map['split_type'],
          orElse: () => SplitType.equal,
        ),
        shareAmount: Decimal.parse(map['share_amount'] as String),
      );
}

enum SplitType { equal, percent, amount, share }
