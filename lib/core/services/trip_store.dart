import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_models.dart';
import 'split_calculator.dart';

DateTime _flightAt(DateTime day, int hour, int minute) =>
    DateTime(day.year, day.month, day.day, hour, minute);

FlightLeg _flightLeg({
  required String number,
  required DateTime day,
  required int hour,
  required int minute,
  required String from,
  required String to,
}) =>
    FlightLeg(
      flightNumber: number,
      departAt: _flightAt(day, hour, minute),
      fromAirport: from,
      toAirport: to,
    );

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

class TripStore extends ChangeNotifier {
  TripStore._();

  static final TripStore instance = TripStore._();

  void _notifyLedgerChanged() => notifyListeners();

  final List<Trip> _createdTrips = [];
  final Map<String, TripDetailData> _sessionDetails = {};

  static const _mockTripIds = {
    'trip-tokyo',
    'trip-taipei',
    'trip-bangkok',
    'trip-osaka',
  };

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

  Trip? tripByShareToken(String token) {
    for (final trip in allTrips()) {
      if (trip.shareToken == token || trip.id == token) return trip;
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

    final seeded = _seedDetail(trip);
    if (_mockTripIds.contains(tripId)) {
      _sessionDetails[tripId] = seeded;
    } else {
      _sessionDetails.putIfAbsent(tripId, () => seeded);
    }
    return _sessionDetails[tripId];
  }

  TripDetailData? detailSync(String tripId) => _sessionDetails[tripId];

  void addSpot(String tripId, Spot spot) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    _sessionDetails[tripId] = detail.copyWith(spots: [...detail.spots, spot]);
  }

  void addExpense(String tripId, Expense expense) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    _sessionDetails[tripId] = detail.copyWith(expenses: [...detail.expenses, expense]);
    _notifyLedgerChanged();
  }

  void updateExpense(String tripId, Expense expense) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    final expenses = detail.expenses.map((e) => e.id == expense.id ? expense : e).toList();
    _sessionDetails[tripId] = detail.copyWith(expenses: expenses);
    _notifyLedgerChanged();
  }

  void removeExpense(String tripId, String expenseId) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    _sessionDetails[tripId] = detail.copyWith(
      expenses: detail.expenses.where((e) => e.id != expenseId).toList(),
    );
    _notifyLedgerChanged();
  }

  void updateSpot(String tripId, Spot spot) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;
    final spots = detail.spots.map((s) => s.id == spot.id ? spot : s).toList();
    _sessionDetails[tripId] = detail.copyWith(spots: spots);
  }

  void reorderSpotsInDay(String tripId, String dayId, int oldIndex, int newIndex) {
    final detail = _sessionDetails[tripId];
    if (detail == null) return;

    final daySpots = detail.spots.where((s) => s.dayId == dayId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (oldIndex < 0 || oldIndex >= daySpots.length) return;

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) targetIndex -= 1;
    if (targetIndex < 0 || targetIndex >= daySpots.length) return;

    final moved = daySpots.removeAt(oldIndex);
    daySpots.insert(targetIndex, moved);

    final reindexed = <String, int>{
      for (var i = 0; i < daySpots.length; i++) daySpots[i].id: i,
    };

    final spots = detail.spots.map((spot) {
      final nextIndex = reindexed[spot.id];
      if (nextIndex == null) return spot;
      return spot.copyWith(orderIndex: nextIndex);
    }).toList();

    _sessionDetails[tripId] = detail.copyWith(spots: spots);
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

  Spot _spot({
    required String id,
    required String dayId,
    required Trip trip,
    required String name,
    required String category,
    required int orderIndex,
    String? area,
    String? openingHours,
    String? duration,
    String? cost,
    double? lat,
    double? lng,
  }) =>
      Spot(
        id: id,
        dayId: dayId,
        tripId: trip.id,
        name: name,
        area: area,
        category: category,
        openingHours: openingHours,
        estimatedDuration: duration,
        estimatedCost: cost != null ? Decimal.parse(cost) : null,
        costCurrency: trip.defaultCurrency,
        latitude: lat,
        longitude: lng,
        orderIndex: orderIndex,
      );

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

    final spots = [
      _spot(
        id: 'tp-s1',
        dayId: d1,
        trip: trip,
        name: 'Din Tai Fung',
        category: 'food',
        area: 'Xinyi',
        orderIndex: 0,
        openingHours: '10:00-21:30',
        duration: '1.5h',
        cost: '800',
        lat: 25.033,
        lng: 121.5654,
      ),
      _spot(
        id: 'tp-s2',
        dayId: d1,
        trip: trip,
        name: 'Taipei 101 Observatory',
        category: 'attraction',
        area: 'Xinyi',
        orderIndex: 1,
        openingHours: '09:00-22:00',
        duration: '2h',
        cost: '600',
        lat: 25.0340,
        lng: 121.5645,
      ),
      _spot(
        id: 'tp-s3',
        dayId: d1,
        trip: trip,
        name: 'Yongkang Street',
        category: 'food',
        area: 'Da\'an',
        orderIndex: 2,
        duration: '2h',
        lat: 25.0329,
        lng: 121.5298,
      ),
      _spot(
        id: 'tp-s4',
        dayId: d1,
        trip: trip,
        name: 'CKS Memorial Hall',
        category: 'attraction',
        area: 'Zhongzheng',
        orderIndex: 3,
        openingHours: '09:00-18:00',
        duration: '1.5h',
        lat: 25.0361,
        lng: 121.5200,
      ),
      _spot(
        id: 'tp-s5',
        dayId: d1,
        trip: trip,
        name: 'Elephant Mountain',
        category: 'attraction',
        area: 'Xinyi',
        orderIndex: 4,
        duration: '1h',
        lat: 25.0275,
        lng: 121.5705,
      ),
      _spot(
        id: 'tp-s6',
        dayId: d1,
        trip: trip,
        name: 'Shilin Night Market',
        category: 'food',
        area: 'Shilin',
        orderIndex: 5,
        openingHours: '17:00-00:00',
        duration: '3h',
        lat: 25.0880,
        lng: 121.5240,
      ),
      _spot(
        id: 'tp-s7',
        dayId: d1,
        trip: trip,
        name: 'Raohe Night Market',
        category: 'food',
        area: 'Songshan',
        orderIndex: 6,
        openingHours: '17:00-00:00',
        duration: '2.5h',
        lat: 25.0505,
        lng: 121.5772,
      ),
      _spot(
        id: 'tp-s8',
        dayId: d1,
        trip: trip,
        name: 'Ximending Walk',
        category: 'shopping',
        area: 'Wanhua',
        orderIndex: 7,
        openingHours: '11:00-22:00',
        duration: '2h',
        lat: 25.0447,
        lng: 121.5070,
      ),
      _spot(
        id: 'tp-s9',
        dayId: d1,
        trip: trip,
        name: 'National Palace Museum',
        category: 'attraction',
        area: 'Shilin',
        orderIndex: 8,
        openingHours: '09:00-17:00',
        duration: '3h',
        cost: '350',
        lat: 25.1024,
        lng: 121.5485,
      ),
      _spot(
        id: 'tp-s10',
        dayId: d1,
        trip: trip,
        name: 'Beitou Hot Spring',
        category: 'activity',
        area: 'Beitou',
        orderIndex: 9,
        openingHours: '10:00-21:00',
        duration: '2h',
        cost: '1200',
        lat: 25.1365,
        lng: 121.5085,
      ),
    ];

    return TripDetailData(
      days: days,
      spots: spots,
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

    final taipeiStart = today.subtract(const Duration(days: 2));
    final taipeiEnd = today.add(const Duration(days: 3));
    final bangkokStart = today;
    final bangkokEnd = today.add(const Duration(days: 4));
    final tokyoStart = today.add(const Duration(days: 12));
    final tokyoEnd = today.add(const Duration(days: 18));
    final seoulStart = today.add(const Duration(days: 28));
    final seoulEnd = today.add(const Duration(days: 31));
    final baliStart = today.add(const Duration(days: 45));
    final baliEnd = today.add(const Duration(days: 52));
    final parisStart = today.add(const Duration(days: 90));
    final parisEnd = today.add(const Duration(days: 97));
    final osakaStart = today.subtract(const Duration(days: 21));
    final osakaEnd = today.subtract(const Duration(days: 16));
    final londonStart = today.subtract(const Duration(days: 75));
    final londonEnd = today.subtract(const Duration(days: 68));
    final hkStart = today.subtract(const Duration(days: 200));
    final hkEnd = today.subtract(const Duration(days: 195));

    return [
      Trip(
        id: 'trip-taipei',
        name: 'Taipei Food Run',
        destination: 'Taipei, Taiwan',
        startDate: taipeiStart,
        endDate: taipeiEnd,
        defaultCurrency: 'TWD',
        outboundFlight: _flightLeg(
          number: 'CX408',
          day: taipeiStart,
          hour: 8,
          minute: 15,
          from: 'HKG',
          to: 'TPE',
        ),
        returnFlight: _flightLeg(
          number: 'CX409',
          day: taipeiEnd,
          hour: 21,
          minute: 40,
          from: 'TPE',
          to: 'HKG',
        ),
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Mia'),
        ],
        shareToken: 'taipei-food',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Trip(
        id: 'trip-bangkok',
        name: 'Bangkok Sprint',
        destination: 'Bangkok, Thailand',
        startDate: bangkokStart,
        endDate: bangkokEnd,
        defaultCurrency: 'THB',
        outboundFlight: _flightLeg(
          number: 'TG601',
          day: bangkokStart,
          hour: 10,
          minute: 20,
          from: 'HKG',
          to: 'BKK',
        ),
        returnFlight: _flightLeg(
          number: 'TG602',
          day: bangkokEnd,
          hour: 14,
          minute: 55,
          from: 'BKK',
          to: 'HKG',
        ),
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
        startDate: tokyoStart,
        endDate: tokyoEnd,
        defaultCurrency: 'JPY',
        outboundFlight: _flightLeg(
          number: 'JL026',
          day: tokyoStart,
          hour: 9,
          minute: 5,
          from: 'HKG',
          to: 'HND',
        ),
        returnFlight: _flightLeg(
          number: 'NH860',
          day: tokyoEnd,
          hour: 18,
          minute: 30,
          from: 'HND',
          to: 'HKG',
        ),
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
        startDate: seoulStart,
        endDate: seoulEnd,
        defaultCurrency: 'KRW',
        outboundFlight: _flightLeg(
          number: 'KE172',
          day: seoulStart,
          hour: 11,
          minute: 30,
          from: 'HKG',
          to: 'ICN',
        ),
        returnFlight: _flightLeg(
          number: 'KE173',
          day: seoulEnd,
          hour: 16,
          minute: 45,
          from: 'ICN',
          to: 'HKG',
        ),
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
        startDate: baliStart,
        endDate: baliEnd,
        defaultCurrency: 'IDR',
        outboundFlight: _flightLeg(
          number: 'CX785',
          day: baliStart,
          hour: 14,
          minute: 10,
          from: 'HKG',
          to: 'DPS',
        ),
        returnFlight: _flightLeg(
          number: 'CX786',
          day: baliEnd,
          hour: 9,
          minute: 50,
          from: 'DPS',
          to: 'HKG',
        ),
        buddies: [Buddy.create(name: 'Wayne')],
        createdAt: now,
      ),
      Trip(
        id: 'trip-paris',
        name: 'Paris in Autumn',
        destination: 'Paris, France',
        startDate: parisStart,
        endDate: parisEnd,
        defaultCurrency: 'EUR',
        outboundFlight: _flightLeg(
          number: 'AF188',
          day: parisStart,
          hour: 23,
          minute: 15,
          from: 'HKG',
          to: 'CDG',
        ),
        returnFlight: _flightLeg(
          number: 'AF185',
          day: parisEnd,
          hour: 13,
          minute: 20,
          from: 'CDG',
          to: 'HKG',
        ),
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Sophie'),
        ],
        shareToken: 'paris-autumn',
        createdAt: now,
      ),
      Trip(
        id: 'trip-osaka',
        name: 'Osaka Ramen Tour',
        destination: 'Osaka, Japan',
        startDate: osakaStart,
        endDate: osakaEnd,
        defaultCurrency: 'JPY',
        outboundFlight: _flightLeg(
          number: 'CX502',
          day: osakaStart,
          hour: 8,
          minute: 50,
          from: 'HKG',
          to: 'KIX',
        ),
        returnFlight: _flightLeg(
          number: 'CX503',
          day: osakaEnd,
          hour: 20,
          minute: 15,
          from: 'KIX',
          to: 'HKG',
        ),
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
        startDate: londonStart,
        endDate: londonEnd,
        defaultCurrency: 'GBP',
        outboundFlight: _flightLeg(
          number: 'BA28',
          day: londonStart,
          hour: 22,
          minute: 45,
          from: 'HKG',
          to: 'LHR',
        ),
        returnFlight: _flightLeg(
          number: 'BA31',
          day: londonEnd,
          hour: 15,
          minute: 10,
          from: 'LHR',
          to: 'HKG',
        ),
        buddies: [Buddy.create(name: 'Wayne')],
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      Trip(
        id: 'trip-hk',
        name: 'Hong Kong Home',
        destination: 'Hong Kong',
        startDate: hkStart,
        endDate: hkEnd,
        defaultCurrency: 'HKD',
        outboundFlight: _flightLeg(
          number: 'UO628',
          day: hkStart,
          hour: 7,
          minute: 30,
          from: 'TPE',
          to: 'HKG',
        ),
        returnFlight: _flightLeg(
          number: 'UO629',
          day: hkEnd,
          hour: 19,
          minute: 0,
          from: 'HKG',
          to: 'TPE',
        ),
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
