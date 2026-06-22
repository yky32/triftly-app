import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_models.dart';
import 'split_calculator.dart';

/// In-memory trip data until Supabase + Hive persistence ships.
class TripDetailData {
  const TripDetailData({
    required this.days,
    required this.spots,
    required this.expenses,
  });

  final List<TripDay> days;
  final List<Spot> spots;
  final List<Expense> expenses;

  TripDetailData copyWith({
    List<TripDay>? days,
    List<Spot>? spots,
    List<Expense>? expenses,
  }) =>
      TripDetailData(
        days: days ?? this.days,
        spots: spots ?? this.spots,
        expenses: expenses ?? this.expenses,
      );
}

class TripStore {
  TripStore._();

  static final TripStore instance = TripStore._();

  final List<Trip> _createdTrips = [];
  final Map<String, TripDetailData> _sessionDetails = {};

  List<Trip> allTrips() {
    final mock = _mockTrips();
    final mockIds = mock.map((t) => t.id).toSet();
    final created = _createdTrips.where((t) => !mockIds.contains(t.id)).toList();
    return [...created, ...mock];
  }

  Trip? tripById(String id) {
    for (final trip in allTrips()) {
      if (trip.id == id) return trip;
    }
    return null;
  }

  void upsertCreatedTrip(Trip trip) {
    _createdTrips.removeWhere((t) => t.id == trip.id);
    _createdTrips.insert(0, trip);
  }

  Future<TripDetailData?> loadDetail(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final trip = tripById(tripId);
    if (trip == null) return null;

    _sessionDetails.putIfAbsent(tripId, () => _seedDetail(trip));
    return _sessionDetails[tripId];
  }

  void addSpot(String tripId, Spot spot) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    _sessionDetails[tripId] = detail.copyWith(spots: [...detail.spots, spot]);
  }

  void addExpense(String tripId, Expense expense) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    _sessionDetails[tripId] = detail.copyWith(expenses: [...detail.expenses, expense]);
  }

  TripDetailData _seedDetail(Trip trip) {
    return switch (trip.id) {
      'trip-tokyo' => _tokyoDetail(trip),
      'trip-taipei' => _taipeiDetail(trip),
      'trip-bangkok' => _bangkokDetail(trip),
      'trip-osaka' => _osakaDetail(trip),
      _ => _emptyDetail(trip),
    };
  }

  TripDetailData _emptyDetail(Trip trip) {
    final days = _daysForTrip(trip);
    return TripDetailData(days: days, spots: const [], expenses: const []);
  }

  List<TripDay> _daysForTrip(Trip trip) {
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

  TripDetailData _tokyoDetail(Trip trip) {
    final days = _daysForTrip(trip);
    final d1 = days[0].id;

    final spots = [
      Spot(
        id: 's1',
        dayId: d1,
        tripId: trip.id,
        name: 'Ichiran Ramen',
        address: '1-22-7 Shibuya',
        area: 'Shibuya',
        category: 'food',
        openingHours: '09:00-22:00',
        estimatedDuration: '1h',
        estimatedCost: Decimal.parse('1290'),
        costCurrency: 'JPY',
        latitude: 35.6595,
        longitude: 139.7004,
        orderIndex: 0,
      ),
      Spot(
        id: 's2',
        dayId: d1,
        tripId: trip.id,
        name: 'Meiji Shrine',
        address: '1-1 Harajuku',
        area: 'Harajuku',
        category: 'attraction',
        openingHours: 'Sunrise-16:30',
        estimatedDuration: '2h',
        latitude: 35.6764,
        longitude: 139.6993,
        orderIndex: 1,
      ),
      Spot(
        id: 's3',
        dayId: d1,
        tripId: trip.id,
        name: 'Sushi Zanmai',
        address: '4-11-9 Ginza',
        area: 'Ginza',
        category: 'food',
        openingHours: '11:00-22:30',
        estimatedDuration: '1.5h',
        estimatedCost: Decimal.parse('4800'),
        costCurrency: 'JPY',
        latitude: 35.6717,
        longitude: 139.7649,
        orderIndex: 2,
      ),
    ];

    final buddyIds = trip.buddies.map((b) => b.id).toList();
    final expenses = [
      Expense(
        id: 'e1',
        tripId: trip.id,
        dayId: d1,
        title: 'Ichiran Ramen',
        amount: Decimal.parse('3870'),
        currency: trip.defaultCurrency,
        paidById: trip.buddies.first.id,
        category: 'food',
        splits: _equalSplits('e1', Decimal.parse('3870'), buddyIds.take(3).toList()),
        createdAt: DateTime.now(),
      ),
      Expense(
        id: 'e2',
        tripId: trip.id,
        dayId: d1,
        title: 'Narita Express',
        amount: Decimal.parse('3250'),
        currency: trip.defaultCurrency,
        paidById: trip.buddies.length > 1 ? trip.buddies[1].id : trip.buddies.first.id,
        category: 'transport',
        splits: _equalSplits('e2', Decimal.parse('3250'), buddyIds),
        createdAt: DateTime.now(),
      ),
      Expense(
        id: 'e3',
        tripId: trip.id,
        dayId: d1,
        title: 'Hotel check-in',
        amount: Decimal.parse('15000'),
        currency: trip.defaultCurrency,
        paidById: trip.buddies.first.id,
        category: 'hotel',
        splits: _equalSplits('e3', Decimal.parse('15000'), buddyIds.take(2).toList()),
        createdAt: DateTime.now(),
      ),
    ];

    return TripDetailData(days: days, spots: spots, expenses: expenses);
  }

  TripDetailData _taipeiDetail(Trip trip) {
    final days = _daysForTrip(trip);
    final d1 = days[0].id;
    final buddyIds = trip.buddies.map((b) => b.id).toList();

    return TripDetailData(
      days: days,
      spots: [
        Spot(
          id: 'tp-s1',
          dayId: d1,
          tripId: trip.id,
          name: 'Din Tai Fung',
          area: 'Xinyi',
          category: 'food',
          openingHours: '10:00-21:30',
          estimatedDuration: '1.5h',
          estimatedCost: Decimal.parse('800'),
          costCurrency: 'TWD',
          latitude: 25.033,
          longitude: 121.5654,
          orderIndex: 0,
        ),
        Spot(
          id: 'tp-s2',
          dayId: d1,
          tripId: trip.id,
          name: 'Taipei 101',
          area: 'Xinyi',
          category: 'attraction',
          openingHours: '09:00-22:00',
          estimatedDuration: '2h',
          latitude: 25.0340,
          longitude: 121.5645,
          orderIndex: 1,
        ),
      ],
      expenses: [
        Expense(
          id: 'tp-e1',
          tripId: trip.id,
          dayId: d1,
          title: 'Lunch at Din Tai Fung',
          amount: Decimal.parse('1600'),
          currency: trip.defaultCurrency,
          paidById: buddyIds.first,
          category: 'food',
          splits: _equalSplits('tp-e1', Decimal.parse('1600'), buddyIds),
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  TripDetailData _bangkokDetail(Trip trip) {
    final days = _daysForTrip(trip);
    final d1 = days[0].id;
    final buddyIds = trip.buddies.map((b) => b.id).toList();

    return TripDetailData(
      days: days,
      spots: [
        Spot(
          id: 'bk-s1',
          dayId: d1,
          tripId: trip.id,
          name: 'Chatuchak Market',
          area: 'Chatuchak',
          category: 'shopping',
          openingHours: '09:00-18:00',
          estimatedDuration: '3h',
          latitude: 13.7999,
          longitude: 100.5497,
          orderIndex: 0,
        ),
      ],
      expenses: [
        Expense(
          id: 'bk-e1',
          tripId: trip.id,
          dayId: d1,
          title: 'Grab to hotel',
          amount: Decimal.parse('250'),
          currency: trip.defaultCurrency,
          paidById: buddyIds.first,
          category: 'transport',
          splits: _equalSplits('bk-e1', Decimal.parse('250'), buddyIds),
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  TripDetailData _osakaDetail(Trip trip) {
    final days = _daysForTrip(trip);
    final d1 = days[0].id;

    return TripDetailData(
      days: days,
      spots: [
        Spot(
          id: 'os-s1',
          dayId: d1,
          tripId: trip.id,
          name: 'Dotonbori',
          area: 'Namba',
          category: 'food',
          openingHours: '24h',
          estimatedDuration: '2h',
          latitude: 34.6687,
          longitude: 135.5031,
          orderIndex: 0,
        ),
      ],
      expenses: const [],
    );
  }

  List<ExpenseSplit> _equalSplits(String expenseId, Decimal amount, List<String> buddyIds) {
    final shares = SplitCalculator.equalSplit(totalAmount: amount, buddyIds: buddyIds);
    return buddyIds
        .map(
          (id) => ExpenseSplit(
            id: const Uuid().v4(),
            expenseId: expenseId,
            buddyId: id,
            splitType: SplitType.equal,
            shareAmount: shares[id] ?? Decimal.zero,
          ),
        )
        .toList();
  }

  List<Trip> _mockTrips() {
    final now = DateTime.now();
    final today = Trip.today;

    return [
      Trip(
        id: 'trip-taipei',
        name: 'Taipei Food Run',
        destination: 'Taipei, Taiwan',
        startDate: today.subtract(const Duration(days: 2)),
        endDate: today.add(const Duration(days: 3)),
        defaultCurrency: 'TWD',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Mia'),
        ],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Trip(
        id: 'trip-bangkok',
        name: 'Bangkok Sprint',
        destination: 'Bangkok, Thailand',
        startDate: today,
        endDate: today.add(const Duration(days: 4)),
        defaultCurrency: 'THB',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Ken'),
          Buddy.create(name: 'Priya'),
        ],
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Trip(
        id: 'trip-tokyo',
        name: 'Tokyo 2026',
        destination: 'Tokyo, Japan',
        startDate: today.add(const Duration(days: 12)),
        endDate: today.add(const Duration(days: 18)),
        defaultCurrency: 'JPY',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Alice'),
          Buddy.create(name: 'Bob'),
          Buddy.create(name: 'Dave'),
        ],
        shareToken: 'tokyo2026',
        createdAt: now,
      ),
      Trip(
        id: 'trip-seoul',
        name: 'Seoul Weekend',
        destination: 'Seoul, Korea',
        startDate: today.add(const Duration(days: 28)),
        endDate: today.add(const Duration(days: 31)),
        defaultCurrency: 'KRW',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Alice'),
        ],
        createdAt: now,
      ),
      Trip(
        id: 'trip-bali',
        name: 'Bali Reset',
        destination: 'Bali, Indonesia',
        startDate: today.add(const Duration(days: 45)),
        endDate: today.add(const Duration(days: 52)),
        defaultCurrency: 'IDR',
        buddies: [Buddy.create(name: 'Wayne')],
        createdAt: now,
      ),
      Trip(
        id: 'trip-paris',
        name: 'Paris in Autumn',
        destination: 'Paris, France',
        startDate: today.add(const Duration(days: 90)),
        endDate: today.add(const Duration(days: 97)),
        defaultCurrency: 'EUR',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Sophie'),
        ],
        createdAt: now,
      ),
      Trip(
        id: 'trip-osaka',
        name: 'Osaka Ramen Tour',
        destination: 'Osaka, Japan',
        startDate: today.subtract(const Duration(days: 21)),
        endDate: today.subtract(const Duration(days: 16)),
        defaultCurrency: 'JPY',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Yuki'),
        ],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Trip(
        id: 'trip-london',
        name: 'London Workation',
        destination: 'London, UK',
        startDate: today.subtract(const Duration(days: 75)),
        endDate: today.subtract(const Duration(days: 68)),
        defaultCurrency: 'GBP',
        buddies: [Buddy.create(name: 'Wayne')],
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      Trip(
        id: 'trip-hk',
        name: 'Hong Kong Home',
        destination: 'Hong Kong',
        startDate: today.subtract(const Duration(days: 200)),
        endDate: today.subtract(const Duration(days: 195)),
        defaultCurrency: 'HKD',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Chris'),
          Buddy.create(name: 'Jen'),
        ],
        createdAt: now.subtract(const Duration(days: 220)),
      ),
    ];
  }
}
