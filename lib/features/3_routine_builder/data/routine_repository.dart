import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triftly/features/3_routine_builder/models/routine_spot.dart';
import 'package:triftly/features/3_routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

const String _keyRoutine = 'triftly_saved_routine';
const String _keySavedTrips = 'triftly_saved_trips';

/// Persists and restores the current routine (trip + spots + day labels) using SharedPreferences.
/// Used by [RoutineBuilderBloc] for the Save action.
class RoutineRepository {
  RoutineRepository(this._prefs);

  final SharedPreferences _prefs;
  final StreamController<List<SavedTripSummary>> _savedTripsController =
      StreamController<List<SavedTripSummary>>.broadcast();

  /// Saves the current trip, spots per day, and day labels.
  /// No-op if [trip] is null.
  Future<void> save({
    required RoutineTripResult? trip,
    required Map<int, List<RoutineSpot>> spotsByDay,
    required Map<int, String> dayLabels,
  }) async {
    if (trip == null) return;
    final payload = _toJson(trip, spotsByDay, dayLabels);
    await _prefs.setString(_keyRoutine, jsonEncode(payload));

    final savedTrips = loadSavedTrips();
    final next = SavedTripSummary.fromTrip(trip, savedAt: DateTime.now());
    final existingIndex = savedTrips.indexWhere((item) =>
        item.name == next.name &&
        item.startDate == next.startDate &&
        item.endDate == next.endDate);
    if (existingIndex != -1) {
      savedTrips.removeAt(existingIndex);
    }
    savedTrips.insert(0, next);
    await _prefs.setString(
      _keySavedTrips,
      jsonEncode(savedTrips.map((item) => item.toJson()).toList()),
    );
    _savedTripsController.add(List<SavedTripSummary>.unmodifiable(savedTrips));
  }

  /// Restores the last saved routine, or null if none.
  SavedRoutine? load() {
    final raw = _prefs.getString(_keyRoutine);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Returns the saved routine whose date range includes today, or null.
  /// This is the "active trip" shown on the Today page.
  SavedRoutine? getActiveTrip() {
    final routine = load();
    if (routine == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      routine.trip.startDate.year,
      routine.trip.startDate.month,
      routine.trip.startDate.day,
    );
    final end = DateTime(
      routine.trip.endDate.year,
      routine.trip.endDate.month,
      routine.trip.endDate.day,
    );
    if (today.isBefore(start) || today.isAfter(end)) return null;
    return routine;
  }

  /// Toggles the completion status of a spot and persists.
  /// Returns the updated [SavedRoutine] after the toggle.
  Future<SavedRoutine> toggleSpotCompletion({
    required int dayIndex,
    required int spotIndex,
  }) async {
    final routine = load();
    if (routine == null) {
      throw StateError('No saved routine to update');
    }

    final spots = List<RoutineSpot>.from(
      routine.spotsByDay[dayIndex] ?? const [],
    );
    if (spotIndex < 0 || spotIndex >= spots.length) {
      throw RangeError('spotIndex $spotIndex out of range for day $dayIndex');
    }

    final spot = spots[spotIndex];
    spots[spotIndex] = spot.copyWith(isCompleted: !spot.isCompleted);

    final updatedSpotsByDay =
        Map<int, List<RoutineSpot>>.from(routine.spotsByDay)
          ..[dayIndex] = spots;

    // Persist the updated routine
    final payload = _toJson(routine.trip, updatedSpotsByDay, routine.dayLabels);
    await _prefs.setString(_keyRoutine, jsonEncode(payload));

    return SavedRoutine(
      trip: routine.trip,
      spotsByDay: updatedSpotsByDay,
      dayLabels: routine.dayLabels,
    );
  }

  List<SavedTripSummary> loadSavedTrips() {
    final raw = _prefs.getString(_keySavedTrips);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        return list
            .map((item) =>
                SavedTripSummary.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    final legacy = load();
    if (legacy == null) return const [];
    return [
      SavedTripSummary.fromTrip(legacy.trip, savedAt: legacy.trip.endDate)
    ];
  }

  Stream<List<SavedTripSummary>> watchSavedTrips() async* {
    yield List<SavedTripSummary>.unmodifiable(loadSavedTrips());
    yield* _savedTripsController.stream;
  }

  Map<String, dynamic> _toJson(
    RoutineTripResult trip,
    Map<int, List<RoutineSpot>> spotsByDay,
    Map<int, String> dayLabels,
  ) {
    return {
      'trip': {
        'name': trip.name,
        'startDate': trip.startDate.toIso8601String(),
        'endDate': trip.endDate.toIso8601String(),
        'countries': trip.countries,
      },
      'spotsByDay': spotsByDay.map(
        (k, v) => MapEntry(k.toString(), v.map(_spotToJson).toList()),
      ),
      'dayLabels': dayLabels.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  Map<String, dynamic> _spotToJson(RoutineSpot s) {
    return {
      'startTime': s.startTime,
      'endTime': s.endTime,
      'title': s.title,
      'description': s.description,
      'location': s.location,
      'iconCodePoint': s.icon.codePoint,
      'colorValue': s.color.toARGB32(),
      'isCompleted': s.isCompleted,
    };
  }

  SavedRoutine? _fromJson(Map<String, dynamic> map) {
    final tripMap = map['trip'] as Map<String, dynamic>?;
    if (tripMap == null) return null;
    final trip = RoutineTripResult(
      name: tripMap['name'] as String? ?? '',
      startDate: DateTime.parse(tripMap['startDate'] as String),
      endDate: DateTime.parse(tripMap['endDate'] as String),
      countries:
          (tripMap['countries'] as List<dynamic>?)?.cast<String>() ?? const [],
    );

    final spotsMap = map['spotsByDay'] as Map<String, dynamic>? ?? {};
    final spotsByDay = <int, List<RoutineSpot>>{};
    for (final e in spotsMap.entries) {
      final dayIndex = int.tryParse(e.key);
      if (dayIndex == null) continue;
      final list = (e.value as List<dynamic>)
          .map((item) => _spotFromJson(item as Map<String, dynamic>))
          .toList();
      spotsByDay[dayIndex] = list;
    }

    final labelsMap = map['dayLabels'] as Map<String, dynamic>? ?? {};
    final dayLabels = <int, String>{};
    for (final e in labelsMap.entries) {
      final dayIndex = int.tryParse(e.key);
      if (dayIndex != null && e.value is String) {
        dayLabels[dayIndex] = e.value as String;
      }
    }

    return SavedRoutine(
      trip: trip,
      spotsByDay: spotsByDay,
      dayLabels: dayLabels,
    );
  }

  RoutineSpot _spotFromJson(Map<String, dynamic> map) {
    final iconCodePoint = map['iconCodePoint'] as int?;
    return RoutineSpot(
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      icon: _iconFromCodePoint(iconCodePoint),
      color: Color(map['colorValue'] as int? ?? 0xFF0277BD),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  IconData _iconFromCodePoint(int? codePoint) {
    if (codePoint == null) return Icons.place_outlined;
    if (codePoint == Icons.coffee.codePoint) return Icons.coffee;
    if (codePoint == Icons.train.codePoint) return Icons.train;
    if (codePoint == Icons.museum_outlined.codePoint) {
      return Icons.museum_outlined;
    }
    if (codePoint == Icons.restaurant_outlined.codePoint) {
      return Icons.restaurant_outlined;
    }
    if (codePoint == Icons.directions_car_outlined.codePoint) {
      return Icons.directions_car_outlined;
    }
    if (codePoint == Icons.flight_takeoff_rounded.codePoint) {
      return Icons.flight_takeoff_rounded;
    }
    if (codePoint == Icons.shopping_bag_outlined.codePoint) {
      return Icons.shopping_bag_outlined;
    }
    return Icons.place_outlined;
  }
}

/// Result of loading a saved routine.
class SavedRoutine {
  const SavedRoutine({
    required this.trip,
    required this.spotsByDay,
    required this.dayLabels,
  });

  final RoutineTripResult trip;
  final Map<int, List<RoutineSpot>> spotsByDay;
  final Map<int, String> dayLabels;

  /// Calculates the day index for today relative to the trip start date.
  /// Returns null if today is outside the trip date range.
  int? get todayDayIndex {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      trip.startDate.year,
      trip.startDate.month,
      trip.startDate.day,
    );
    final end = DateTime(
      trip.endDate.year,
      trip.endDate.month,
      trip.endDate.day,
    );
    if (today.isBefore(start) || today.isAfter(end)) return null;
    return today.difference(start).inDays;
  }

  /// Returns the spots for today, or empty list if today is not in range.
  List<RoutineSpot> get todaySpots {
    final idx = todayDayIndex;
    if (idx == null) return const [];
    return spotsByDay[idx] ?? const [];
  }

  /// Total completed spots across all days.
  int get completedSpotCount {
    int count = 0;
    for (final spots in spotsByDay.values) {
      count += spots.where((s) => s.isCompleted).length;
    }
    return count;
  }

  /// Total spots across all days.
  int get totalSpotCount {
    int count = 0;
    for (final spots in spotsByDay.values) {
      count += spots.length;
    }
    return count;
  }

  /// Days remaining in the trip (including today).
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(
      trip.endDate.year,
      trip.endDate.month,
      trip.endDate.day,
    );
    final diff = end.difference(today).inDays;
    return diff >= 0 ? diff + 1 : 0;
  }
}

class SavedTripSummary {
  const SavedTripSummary({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.countries,
    required this.savedAt,
  });

  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> countries;
  final DateTime savedAt;

  factory SavedTripSummary.fromTrip(
    RoutineTripResult trip, {
    required DateTime savedAt,
  }) {
    return SavedTripSummary(
      name: trip.name,
      startDate: trip.startDate,
      endDate: trip.endDate,
      countries: List<String>.from(trip.countries),
      savedAt: savedAt,
    );
  }

  factory SavedTripSummary.fromJson(Map<String, dynamic> map) {
    return SavedTripSummary(
      name: map['name'] as String? ?? '',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      countries:
          (map['countries'] as List<dynamic>?)?.cast<String>() ?? const [],
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'countries': countries,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
