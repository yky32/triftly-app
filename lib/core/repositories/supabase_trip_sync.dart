import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../data/trip_hive_cache.dart';
import '../environment.dart';
import '../models/trip_models.dart';
import '../services/trip_store.dart';
import 'supabase_trip_mapper.dart';

/// Pushes and pulls user trips to Supabase when configured.
class SupabaseTripSync {
  SupabaseTripSync({
    supabase.SupabaseClient? client,
    TripStore? store,
  })  : _client = client,
        _store = store ?? TripStore.instance;

  final supabase.SupabaseClient? _client;
  final TripStore _store;

  supabase.SupabaseClient get client {
    final c = _client;
    if (c != null) return c;
    return supabase.Supabase.instance.client;
  }

  bool get _canSync => Environment.hasSupabase;

  bool _isCloudOwnerId(String? ownerId) =>
      ownerId != null && !ownerId.startsWith('local-');

  bool _shouldSyncTrip(Trip trip) =>
      _canSync &&
      _isCloudOwnerId(trip.ownerId) &&
      !TripStore.isMockTripId(trip.id);

  Future<void> upsertTrip(Trip trip) async {
    if (!_shouldSyncTrip(trip)) return;

    try {
      await client.from('trips').upsert(SupabaseTripMapper.tripToRow(trip));
      await client.from('trip_members').upsert(
        SupabaseTripMapper.memberToRow(trip.id, trip.ownerId!),
      );
      if (trip.buddies.isNotEmpty) {
        await client.from('buddies').upsert(
          trip.buddies
              .map((b) => SupabaseTripMapper.buddyToRow(b, trip.id))
              .toList(),
        );
      }

      final detail = _store.detailSync(trip.id);
      final days = (detail != null && detail.days.isNotEmpty)
          ? detail.days
          : SupabaseTripMapper.daysForTrip(trip);
      if (days.isNotEmpty) {
        await client.from('trip_days').upsert(
          days.map(SupabaseTripMapper.dayToRow).toList(),
        );
      }
    } catch (e, st) {
      debugPrint('SupabaseTripSync.upsertTrip failed: $e\n$st');
    }
  }

  Future<void> upsertDetail(String tripId, TripDetailData detail) async {
    final trip = _store.tripById(tripId);
    if (trip == null || !_shouldSyncTrip(trip)) return;

    try {
      if (detail.days.isNotEmpty) {
        await client.from('trip_days').upsert(
          detail.days.map(SupabaseTripMapper.dayToRow).toList(),
        );
      }

      if (detail.spots.isNotEmpty) {
        await client.from('spots').upsert(
          detail.spots.map(SupabaseTripMapper.spotToRow).toList(),
        );
      }

      for (final expense in detail.expenses) {
        await client.from('expenses').upsert(SupabaseTripMapper.expenseToRow(expense));
        await client.from('expense_splits').delete().eq('expense_id', expense.id);
        if (expense.splits.isNotEmpty) {
          await client.from('expense_splits').insert(
            expense.splits.map(SupabaseTripMapper.splitToRow).toList(),
          );
        }
      }

      if (detail.settlements.isNotEmpty) {
        await client.from('settlement_records').upsert(
          detail.settlements.map(SupabaseTripMapper.settlementToRow).toList(),
        );
      }
    } catch (e, st) {
      debugPrint('SupabaseTripSync.upsertDetail failed: $e\n$st');
    }
  }

  Future<void> deactivateTrip(String tripId) async {
    if (!_canSync || TripStore.isMockTripId(tripId)) return;

    try {
      await client.from('trips').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tripId);
    } catch (e, st) {
      debugPrint('SupabaseTripSync.deactivateTrip failed: $e\n$st');
    }
  }

  Future<void> pullTripsForUser(
    String userId,
    TripStore store,
    TripHiveCache cache,
  ) async {
    if (!_canSync) return;

    try {
      final tripRows = await client
          .from('trips')
          .select()
          .eq('owner_id', userId)
          .eq('is_active', true);

      for (final raw in tripRows as List) {
        final tripRow = Map<String, dynamic>.from(raw as Map);
        final tripId = tripRow['id'] as String;
        if (TripStore.isMockTripId(tripId)) continue;

        final buddies = await _loadBuddies(tripId);
        final trip = SupabaseTripMapper.tripFromRow(tripRow, buddies);
        final detail = await _loadDetail(tripId);

        store.upsertCreatedTrip(trip);
        store.restoreDetail(tripId, detail);
        await cache.saveTrip(trip);
        await cache.saveDetail(tripId, detail);
      }
    } catch (e, st) {
      debugPrint('SupabaseTripSync.pullTripsForUser failed: $e\n$st');
    }
  }

  Future<List<Buddy>> _loadBuddies(String tripId) async {
    final rows = await client.from('buddies').select().eq('trip_id', tripId);
    return (rows as List)
        .map((r) => SupabaseTripMapper.buddyFromRow(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<TripDetailData> _loadDetail(String tripId) async {
    final dayRows = await client.from('trip_days').select().eq('trip_id', tripId);
    final days = (dayRows as List)
        .map((r) => SupabaseTripMapper.dayFromRow(Map<String, dynamic>.from(r as Map)))
        .toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    final spotRows = await client.from('spots').select().eq('trip_id', tripId);
    final spots = (spotRows as List)
        .map((r) => SupabaseTripMapper.spotFromRow(Map<String, dynamic>.from(r as Map)))
        .where((s) => s.isActive)
        .toList();

    final expenseRows = await client.from('expenses').select().eq('trip_id', tripId);
    final expenses = <Expense>[];
    for (final raw in expenseRows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      if (row['is_active'] == false) continue;
      final expenseId = row['id'] as String;
      final splitRows =
          await client.from('expense_splits').select().eq('expense_id', expenseId);
      final splits = (splitRows as List)
          .map((r) => SupabaseTripMapper.splitFromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
      expenses.add(SupabaseTripMapper.expenseFromRow(row, splits));
    }

    final settlementRows =
        await client.from('settlement_records').select().eq('trip_id', tripId);
    final settlements = (settlementRows as List)
        .map((r) =>
            SupabaseTripMapper.settlementFromRow(Map<String, dynamic>.from(r as Map)))
        .where((s) => s.isActive)
        .toList();

    return TripDetailData(
      days: days,
      spots: spots,
      expenses: expenses,
      settlements: settlements,
    );
  }

  Future<Trip?> hydrateSharedTripByToken(
    String token,
    TripStore store,
    TripHiveCache cache,
  ) async {
    if (!_canSync) return null;

    try {
      final bundle = await client.rpc('get_shared_trip_bundle', params: {
        'p_token': token,
      });
      if (bundle == null) return null;

      final parsed = SupabaseTripMapper.sharedBundleFromMap(
        Map<String, dynamic>.from(bundle as Map),
      );
      store.upsertCreatedTrip(parsed.trip);
      store.restoreDetail(parsed.trip.id, parsed.detail);
      await cache.saveTrip(parsed.trip);
      await cache.saveDetail(parsed.trip.id, parsed.detail);
      return parsed.trip;
    } catch (e, st) {
      debugPrint('SupabaseTripSync.hydrateSharedTripByToken failed: $e\n$st');
      return null;
    }
  }
}
