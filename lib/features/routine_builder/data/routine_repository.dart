import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/bottom_sheets/routine_builder_bottom_sheet.dart';

const String _keyRoutine = 'triftly_saved_routine';

/// Persists and restores the current routine (trip + spots + day labels) using SharedPreferences.
/// Used by [RoutineBuilderBloc] for the Save action.
class RoutineRepository {
  RoutineRepository(this._prefs);

  final SharedPreferences _prefs;

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
    };
  }

  SavedRoutine? _fromJson(Map<String, dynamic> map) {
    final tripMap = map['trip'] as Map<String, dynamic>?;
    if (tripMap == null) return null;
    final trip = RoutineTripResult(
      name: tripMap['name'] as String? ?? '',
      startDate: DateTime.parse(tripMap['startDate'] as String),
      endDate: DateTime.parse(tripMap['endDate'] as String),
      countries: (tripMap['countries'] as List<dynamic>?)?.cast<String>() ?? const [],
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
    return RoutineSpot(
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      icon: IconData(map['iconCodePoint'] as int? ?? Icons.place_outlined.codePoint),
      color: Color(map['colorValue'] as int? ?? 0xFF0277BD),
    );
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
}
