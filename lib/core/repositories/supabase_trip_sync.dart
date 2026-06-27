import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../data/trip_hive_cache.dart';
import '../environment.dart';
import '../models/trip_models.dart';
import '../sync/cloud_sync_reporter.dart';
import '../services/trip_store.dart';
import 'supabase_trip_mapper.dart';

/// Pushes and pulls user trips to Supabase when configured.
class SupabaseTripSync {
  SupabaseTripSync({
    supabase.SupabaseClient? client,
    TripStore? store,
    CloudSyncReporter? syncReporter,
  })  : _client = client,
        _store = store ?? TripStore.instance,
        _syncReporter = syncReporter;

  final supabase.SupabaseClient? _client;
  final TripStore _store;
  final CloudSyncReporter? _syncReporter;

  supabase.SupabaseClient get client {
    final c = _client;
    if (c != null) return c;
    return supabase.Supabase.instance.client;
  }

  bool get _canSync => Environment.hasSupabase;

  bool _isCloudOwnerId(String? ownerId) =>
      ownerId != null && !ownerId.startsWith('local-');

  bool _shouldSyncTrip(Trip trip) {
    if (!_canSync || TripStore.isMockTripId(trip.id) || trip.isPreviewShare) {
      return false;
    }
    if (trip.isJoinedMember) return trip.isEditor;
    return _isCloudOwnerId(trip.ownerId);
  }

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
      _syncReporter?.recordPushFailure(e);
      debugPrint('SupabaseTripSync.upsertTrip failed: $e\n$st');
      rethrow;
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
      _syncReporter?.recordPushFailure(e);
      debugPrint('SupabaseTripSync.upsertDetail failed: $e\n$st');
      rethrow;
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
      _syncReporter?.recordPushFailure(e);
      debugPrint('SupabaseTripSync.deactivateTrip failed: $e\n$st');
      rethrow;
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
        await _ingestTripRow(
          Map<String, dynamic>.from(raw as Map),
          store,
          cache,
        );
      }

      final memberRows = await client
          .from('trip_members')
          .select('trip_id, role')
          .eq('user_id', userId);

      final memberRoles = <String, String>{};
      for (final raw in memberRows as List) {
        final row = Map<String, dynamic>.from(raw as Map);
        final role = row['role'] as String;
        if (role == 'owner') continue;
        memberRoles[row['trip_id'] as String] = role;
      }

      if (memberRoles.isEmpty) return;

      final joinedRows = await client
          .from('trips')
          .select()
          .inFilter('id', memberRoles.keys.toList())
          .eq('is_active', true);

      for (final raw in joinedRows as List) {
        final tripRow = Map<String, dynamic>.from(raw as Map);
        final tripId = tripRow['id'] as String;
        await _ingestTripRow(
          tripRow,
          store,
          cache,
          membershipRole: memberRoles[tripId],
        );
      }
    } catch (e, st) {
      debugPrint('SupabaseTripSync.pullTripsForUser failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> _ingestTripRow(
    Map<String, dynamic> tripRow,
    TripStore store,
    TripHiveCache cache, {
    String? membershipRole,
  }) async {
    final tripId = tripRow['id'] as String;
    if (TripStore.isMockTripId(tripId)) return;

    final buddies = await _loadBuddies(tripId);
    final trip = SupabaseTripMapper.tripFromRow(
      tripRow,
      buddies,
      membershipRole: membershipRole,
    );
    final detail = await _loadDetail(tripId);

    store.upsertCreatedTrip(trip);
    store.restoreDetail(tripId, detail);
    await cache.saveTrip(trip);
    await cache.saveDetail(tripId, detail);
  }

  /// Adds the signed-in user as a viewer and returns the trip id.
  Future<String?> acceptTripShare(String shareToken) async {
    if (!_canSync) return null;

    try {
      final result = await client.rpc('accept_trip_share', params: {
        'p_token': shareToken,
      });
      if (result == null) return null;
      return result.toString();
    } catch (e, st) {
      debugPrint('SupabaseTripSync.acceptTripShare failed: $e\n$st');
      rethrow;
    }
  }

  Future<bool> leaveTripShare(String tripId) async {
    if (!_canSync) return false;

    try {
      final result = await client.rpc('leave_trip_share', params: {
        'p_trip_id': tripId,
      });
      return result == true;
    } catch (e, st) {
      debugPrint('SupabaseTripSync.leaveTripShare failed: $e\n$st');
      rethrow;
    }
  }

  Future<bool> setTripMemberRole({
    required String tripId,
    required String memberUserId,
    required String role,
  }) async {
    if (!_canSync) return false;

    try {
      final result = await client.rpc('set_trip_member_role', params: {
        'p_trip_id': tripId,
        'p_member_user_id': memberUserId,
        'p_role': role,
      });
      return result == true;
    } catch (e, st) {
      debugPrint('SupabaseTripSync.setTripMemberRole failed: $e\n$st');
      rethrow;
    }
  }

  Future<bool> removeTripMember({
    required String tripId,
    required String memberUserId,
  }) async {
    if (!_canSync) return false;

    try {
      await client
          .from('trip_members')
          .delete()
          .eq('trip_id', tripId)
          .eq('user_id', memberUserId);
      return true;
    } catch (e, st) {
      debugPrint('SupabaseTripSync.removeTripMember failed: $e\n$st');
      return false;
    }
  }

  Future<List<TripMemberSummary>> fetchTripMembers(String tripId) async {
    if (!_canSync) return const [];

    try {
      final profiles = await client.rpc('get_trip_member_profiles', params: {
        'p_trip_id': tripId,
      });

      if (profiles is List) {
        return profiles
            .map((raw) => _memberFromMap(Map<String, dynamic>.from(raw as Map)))
            .toList();
      }
    } catch (e, st) {
      debugPrint('SupabaseTripSync.fetchTripMembers profiles RPC failed: $e\n$st');
    }

    try {
      final rows = await client
          .from('trip_members')
          .select('user_id, role')
          .eq('trip_id', tripId)
          .neq('role', 'owner');

      return (rows as List)
          .map((raw) {
            final row = Map<String, dynamic>.from(raw as Map);
            return TripMemberSummary(
              userId: row['user_id'] as String,
              role: row['role'] as String,
            );
          })
          .toList();
    } catch (e, st) {
      debugPrint('SupabaseTripSync.fetchTripMembers failed: $e\n$st');
      return const [];
    }
  }

  TripMemberSummary _memberFromMap(Map<String, dynamic> row) => TripMemberSummary(
        userId: row['user_id'] as String,
        role: row['role'] as String,
        displayName: row['display_name'] as String?,
        email: row['email'] as String?,
      );

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
      final previewTrip = parsed.trip.copyWith(membershipRole: 'preview');
      store.upsertCreatedTrip(previewTrip);
      store.restoreDetail(previewTrip.id, parsed.detail);
      await cache.saveTrip(previewTrip);
      await cache.saveDetail(previewTrip.id, parsed.detail);
      return previewTrip;
    } catch (e, st) {
      debugPrint('SupabaseTripSync.hydrateSharedTripByToken failed: $e\n$st');
      return null;
    }
  }
}
