import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

Map<String, dynamic> _stringMap(dynamic value) => Map<String, dynamic>.from(value as Map);

class Buddy extends Equatable {
  final String id;
  final String name;
  final String? avatarColor;
  final String? userId;
  final bool isMe;

  const Buddy({
    required this.id,
    required this.name,
    this.avatarColor,
    this.userId,
    this.isMe = false,
  });

  factory Buddy.create({
    required String name,
    String? userId,
    bool isMe = false,
  }) {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4',
      'FFEAA7', 'DDA0DD', '74B9FF', 'A29BFE',
    ];
    return Buddy(
      id: const Uuid().v4(),
      name: name,
      avatarColor: colors[name.hashCode % colors.length],
      userId: userId,
      isMe: isMe,
    );
  }

  Buddy copyWith({
    String? name,
    String? avatarColor,
    String? userId,
    bool? isMe,
  }) =>
      Buddy(
        id: id,
        name: name ?? this.name,
        avatarColor: avatarColor ?? this.avatarColor,
        userId: userId ?? this.userId,
        isMe: isMe ?? this.isMe,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatar_color': avatarColor,
        'user_id': userId,
        'is_me': isMe,
      };

  factory Buddy.fromMap(Map<String, dynamic> map) => Buddy(
        id: map['id'] as String,
        name: map['name'] as String,
        avatarColor: map['avatar_color'] as String?,
        userId: map['user_id'] as String?,
        isMe: map['is_me'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, avatarColor, userId, isMe];
}

/// Cloud trip member row (excludes trip owner).
class TripMemberSummary extends Equatable {
  const TripMemberSummary({
    required this.userId,
    required this.role,
    this.displayName,
    this.email,
  });

  final String userId;
  final String role;
  final String? displayName;
  final String? email;

  bool get isEditor => role == 'editor';

  bool get isViewer => role == 'viewer';

  /// Best label for UI: name → email → short id.
  String get displayLabel {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) return mail;
    return userId.length > 8 ? '${userId.substring(0, 8)}…' : userId;
  }

  String? get subtitle {
    final mail = email?.trim();
    if (mail == null || mail.isEmpty) return null;
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty && name != mail) return mail;
    return null;
  }

  @override
  List<Object?> get props => [userId, role, displayName, email];
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
  final String? ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  /// Local-only: null/owner = yours; preview = link preview; viewer/editor = joined.
  final String? membershipRole;

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
    this.ownerId,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.membershipRole,
  });

  bool get isPreviewShare => membershipRole == 'preview';

  bool get isJoinedMember =>
      membershipRole == 'viewer' || membershipRole == 'editor';

  bool get isViewer => membershipRole == 'viewer';

  bool get isEditor => membershipRole == 'editor';

  bool get isReadOnlyForCurrentUser => isPreviewShare || membershipRole == 'viewer';

  /// Owner-only: rename trip, delete, share link, manage members.
  bool get canManageTripSettings => !isPreviewShare && !isJoinedMember;

  /// Plan / spend / map edits (editors + owners).
  bool get canEditTripContent => !isReadOnlyForCurrentUser && !isPreviewShare;

  String? get membershipBadgeLabel {
    return switch (membershipRole) {
      'viewer' => 'Shared · view only',
      'editor' => 'Shared · can edit',
      _ => null,
    };
  }

  bool get appearsInTripList => !isPreviewShare;

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
        'owner_id': ownerId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_active': isActive,
        'membership_role': membershipRole,
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        name: map['name'] as String,
        destination: map['destination'] as String,
        startDate: DateTime.parse(map['start_date'] as String),
        endDate: DateTime.parse(map['end_date'] as String),
        defaultCurrency: map['default_currency'] as String,
        outboundFlight: map['outbound_flight'] != null
            ? FlightLeg.fromMap(_stringMap(map['outbound_flight']))
            : (map['flight_number'] != null
                ? FlightLeg(flightNumber: map['flight_number'] as String?)
                : null),
        returnFlight: map['return_flight'] != null
            ? FlightLeg.fromMap(_stringMap(map['return_flight']))
            : null,
        buddies: (map['buddies'] as List<dynamic>)
            .map((b) => Buddy.fromMap(_stringMap(b)))
            .toList(),
        ownerToken: map['owner_token'] as String?,
        shareToken: map['share_token'] as String?,
        ownerId: map['owner_id'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
        isActive: map['is_active'] as bool? ?? true,
        membershipRole: map['membership_role'] as String?,
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
    String? ownerId,
    DateTime? updatedAt,
    bool? isActive,
    String? membershipRole,
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
        ownerId: ownerId ?? this.ownerId,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
        membershipRole: membershipRole ?? this.membershipRole,
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

  /// First day → Arrival; last day → Departure (when trip is 2+ days).
  static String? defaultTitle(int dayNumber, int totalDays) {
    if (dayNumber == 1) return 'Arrival';
    if (totalDays > 1 && dayNumber == totalDays) return 'Departure';
    return null;
  }

  String get displayTitleLine {
    final base = 'Day $dayNumber';
    if (title != null && title!.isNotEmpty) return '$base — $title';
    return base;
  }

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
  final bool visited;
  final bool isActive;
  final DateTime? updatedAt;

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
    this.visited = false,
    this.isActive = true,
    this.updatedAt,
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
    bool? visited,
    bool? isActive,
    DateTime? updatedAt,
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
        visited: visited ?? this.visited,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
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
        'visited': visited,
        'is_active': isActive,
        'updated_at': updatedAt?.toIso8601String(),
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
        visited: map['visited'] as bool? ?? false,
        isActive: map['is_active'] as bool? ?? true,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );

  @override
  List<Object?> get props => [id, dayId, name, orderIndex, visited];
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
  final bool isActive;
  final DateTime? updatedAt;

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
    this.isActive = true,
    this.updatedAt,
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
        'is_active': isActive,
        'updated_at': updatedAt?.toIso8601String(),
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
                ?.map((s) => ExpenseSplit.fromMap(_stringMap(s)))
                .toList() ??
            [],
        createdAt: DateTime.parse(map['created_at'] as String),
        isActive: map['is_active'] as bool? ?? true,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );

  Expense copyWith({
    String? dayId,
    String? title,
    Decimal? amount,
    String? currency,
    String? paidById,
    String? category,
    List<ExpenseSplit>? splits,
    DateTime? createdAt,
    bool? isActive,
    DateTime? updatedAt,
  }) =>
      Expense(
        id: id,
        tripId: tripId,
        dayId: dayId ?? this.dayId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        paidById: paidById ?? this.paidById,
        category: category ?? this.category,
        splits: splits ?? this.splits,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class ExpenseSplit extends Equatable {
  final String id;
  final String expenseId;
  final String buddyId;
  final SplitType splitType;
  final Decimal shareAmount;
  final Decimal? splitConfigValue;

  const ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.buddyId,
    required this.splitType,
    required this.shareAmount,
    this.splitConfigValue,
  });

  @override
  List<Object?> get props => [id, expenseId, buddyId];

  Map<String, dynamic> toMap() => {
        'id': id,
        'expense_id': expenseId,
        'buddy_id': buddyId,
        'split_type': splitType.name,
        'share_amount': shareAmount.toString(),
        if (splitConfigValue != null)
          'split_config_value': splitConfigValue.toString(),
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
        splitConfigValue: map['split_config_value'] != null
            ? Decimal.parse(map['split_config_value'] as String)
            : null,
      );
}

enum SplitType { equal, percent, amount, share }
