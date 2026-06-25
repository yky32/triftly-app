import 'package:flutter/foundation.dart';
import '../data/trip_hive_cache.dart';
import '../models/settlement_record.dart';
import '../models/trip_models.dart';
import '../services/trip_store.dart';
import 'supabase_trip_sync.dart';
import 'trip_repository.dart';

/// Local trip repository — in-memory store + Hive cache + optional Supabase sync.
class HiveTripRepository extends ChangeNotifier implements TripRepository {
  HiveTripRepository({
    required TripStore store,
    required TripHiveCache cache,
    SupabaseTripSync? supabaseSync,
  })  : _store = store,
        _cache = cache,
        _supabaseSync = supabaseSync;

  static HiveTripRepository? _instance;
  static HiveTripRepository get instance {
    assert(_instance != null, 'HiveTripRepository.bootstrap() must be called first');
    return _instance!;
  }

  final TripStore _store;
  final TripHiveCache _cache;
  final SupabaseTripSync? _supabaseSync;

  static Future<HiveTripRepository> bootstrap({SupabaseTripSync? supabaseSync}) async {
    final cache = TripHiveCache();
    await cache.init();
    final store = TripStore.instance;
    await cache.hydrate(store);
    final repo = HiveTripRepository(
      store: store,
      cache: cache,
      supabaseSync: supabaseSync,
    );
    store.addListener(repo.notifyListeners);
    _instance = repo;
    return repo;
  }

  Future<void> _persistTrip(Trip trip) async {
    await _cache.saveTrip(trip);
    await _supabaseSync?.upsertTrip(trip);
  }

  Future<void> _persistDetail(String tripId) async {
    final detail = _store.detailSync(tripId);
    if (detail == null) return;
    await _cache.saveDetail(tripId, detail);
    await _supabaseSync?.upsertDetail(tripId, detail);
  }

  @override
  List<Trip> allTrips() => _store.allTrips();

  @override
  Trip? tripById(String id) => _store.tripById(id);

  @override
  Trip? tripByShareToken(String token) => _store.tripByShareToken(token);

  @override
  Future<TripDetailData?> loadDetail(String tripId) => _store.loadDetail(tripId);

  @override
  TripDetailData? detailSync(String tripId) => _store.detailSync(tripId);

  @override
  Future<void> upsertTrip(Trip trip) async {
    _store.upsertCreatedTrip(trip);
    await _persistTrip(trip);
    notifyListeners();
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final updated = trip.copyWith(updatedAt: DateTime.now());
    _store.updateCreatedTrip(updated);
    await _persistTrip(updated);
    await _persistDetail(trip.id);
    notifyListeners();
  }

  @override
  Future<void> deactivateTrip(String tripId) async {
    _store.deactivateCreatedTrip(tripId);
    final trip = _store.tripById(tripId);
    if (trip != null) await _persistTrip(trip);
    await _cache.removeTrip(tripId);
    await _supabaseSync?.deactivateTrip(tripId);
    notifyListeners();
  }

  @override
  void addSpot(String tripId, Spot spot) {
    _store.addSpot(tripId, spot);
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void updateSpot(String tripId, Spot spot) {
    _store.updateSpot(tripId, spot.copyWith(updatedAt: DateTime.now()));
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void removeSpot(String tripId, String spotId) {
    _store.removeSpot(tripId, spotId);
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void reorderSpotsInDay(String tripId, String dayId, int oldIndex, int newIndex) {
    _store.reorderSpotsInDay(tripId, dayId, oldIndex, newIndex);
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void addExpense(String tripId, Expense expense) {
    _store.addExpense(tripId, expense);
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void updateExpense(String tripId, Expense expense) {
    _store.updateExpense(tripId, expense.copyWith(updatedAt: DateTime.now()));
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void removeExpense(String tripId, String expenseId) {
    _store.removeExpense(tripId, expenseId);
    _persistDetail(tripId);
    notifyListeners();
  }

  @override
  void addSettlement(String tripId, SettlementRecord record) {
    _store.addSettlement(tripId, record);
    _persistDetail(tripId);
    notifyListeners();
  }

  Future<void> pullFromSupabase(String userId) async {
    await _supabaseSync?.pullTripsForUser(userId, _store, _cache);
    notifyListeners();
  }
}
