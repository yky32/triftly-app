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

class Trip extends Equatable {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String defaultCurrency;
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
    this.buddies = const [],
    this.ownerToken,
    this.shareToken,
    required this.createdAt,
  });

  int get numberOfDays => endDate.difference(startDate).inDays + 1;

  bool get isUpcoming => startDate.isAfter(DateTime.now());

  bool get isPast => endDate.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'destination': destination,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'default_currency': defaultCurrency,
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
}

enum SplitType { equal, percent, amount, share }
