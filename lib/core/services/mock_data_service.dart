import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/trip_models.dart';

class MockDataService {
  static const String _mockDataPath = 'assets/mock/mock_trips.json';

  /// Load mock trips from JSON file
  static Future<List<Trip>> loadMockTrips() async {
    try {
      final jsonString = await rootBundle.loadString(_mockDataPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final tripsJson = jsonData['trips'] as List<dynamic>;

      return tripsJson
          .map((json) => Trip.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load mock trips: $e');
    }
  }

  /// Load mock trips with nested days, spots, and expenses
  /// Returns a map with trips, days, spots, expenses
  static Future<MockData> loadFullMockData() async {
    try {
      final jsonString = await rootBundle.loadString(_mockDataPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final tripsJson = jsonData['trips'] as List<dynamic>;
      final trips = tripsJson
          .map((json) => Trip.fromMap(json as Map<String, dynamic>))
          .toList();

      final days = <TripDay>[];
      final spots = <Spot>[];
      final expenses = <Expense>[];

      for (final tripJson in tripsJson) {
        final tripMap = tripJson as Map<String, dynamic>;
        final daysJson = tripMap['days'] as List<dynamic>? ?? [];

        for (final dayJson in daysJson) {
          final dayMap = dayJson as Map<String, dynamic>;
          final day = TripDay.fromMap(dayMap);
          days.add(day);

          // Load spots
          final spotsJson = dayMap['spots'] as List<dynamic>? ?? [];
          for (final spotJson in spotsJson) {
            spots.add(Spot.fromMap(spotJson as Map<String, dynamic>));
          }

          // Load expenses
          final expensesJson = dayMap['expenses'] as List<dynamic>? ?? [];
          for (final expenseJson in expensesJson) {
            expenses.add(Expense.fromMap(expenseJson as Map<String, dynamic>));
          }
        }
      }

      return MockData(
        trips: trips,
        days: days,
        spots: spots,
        expenses: expenses,
      );
    } catch (e) {
      throw Exception('Failed to load full mock data: $e');
    }
  }
}

class MockData {
  final List<Trip> trips;
  final List<TripDay> days;
  final List<Spot> spots;
  final List<Expense> expenses;

  const MockData({
    required this.trips,
    required this.days,
    required this.spots,
    required this.expenses,
  });

  /// Get days for a specific trip
  List<TripDay> getDaysForTrip(String tripId) {
    return days.where((day) => day.tripId == tripId).toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  /// Get spots for a specific day
  List<Spot> getSpotsForDay(String dayId) {
    return spots.where((spot) => spot.dayId == dayId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Get expenses for a specific trip
  List<Expense> getExpensesForTrip(String tripId) {
    return expenses.where((expense) => expense.tripId == tripId).toList();
  }

  /// Get expenses for a specific day
  List<Expense> getExpensesForDay(String dayId) {
    return expenses.where((expense) => expense.dayId == dayId).toList();
  }
}
