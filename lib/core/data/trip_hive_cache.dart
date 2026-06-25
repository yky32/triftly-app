import 'package:hive_flutter/hive_flutter.dart';
import '../models/settlement_record.dart';
import '../models/trip_models.dart';
import '../services/trip_store.dart';

/// Hive-backed cache for user-created trips.
class TripHiveCache {
  static const _tripsBox = 'trips_cache';
  static const _detailsBox = 'trip_details_cache';

  Box<Map>? _trips;
  Box<Map>? _details;

  Future<void> init() async {
    await Hive.initFlutter();
    _trips = await Hive.openBox<Map>(_tripsBox);
    _details = await Hive.openBox<Map>(_detailsBox);
  }

  Future<void> hydrate(TripStore store) async {
    if (_trips == null || _details == null) return;
    for (final raw in _trips!.values) {
      final trip = Trip.fromMap(Map<String, dynamic>.from(raw));
      if (trip.isActive) store.upsertCreatedTrip(trip);
    }
    for (final key in _details!.keys) {
      final raw = _details!.get(key);
      if (raw == null) continue;
      final map = Map<String, dynamic>.from(raw);
      store.restoreDetail(
        key as String,
        TripDetailData(
          days: (map['days'] as List)
              .map((d) => TripDay.fromMap(Map<String, dynamic>.from(d as Map)))
              .toList(),
          spots: (map['spots'] as List)
              .map((s) => Spot.fromMap(Map<String, dynamic>.from(s as Map)))
              .toList(),
          expenses: (map['expenses'] as List)
              .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList(),
          settlements: (map['settlements'] as List? ?? [])
              .map((r) => SettlementRecord.fromMap(Map<String, dynamic>.from(r as Map)))
              .toList(),
        ),
      );
    }
  }

  Future<void> saveTrip(Trip trip) async {
    await _trips?.put(trip.id, trip.toMap());
  }

  Future<void> saveDetail(String tripId, TripDetailData detail) async {
    await _details?.put(tripId, {
      'days': detail.days.map((d) => d.toMap()).toList(),
      'spots': detail.spots.map((s) => s.toMap()).toList(),
      'expenses': detail.expenses.map((e) => e.toMap()).toList(),
      'settlements': detail.settlements.map((r) => r.toMap()).toList(),
    });
  }

  Future<void> removeTrip(String tripId) async {
    await _trips?.delete(tripId);
    await _details?.delete(tripId);
  }
}
