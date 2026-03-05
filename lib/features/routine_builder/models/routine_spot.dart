import 'package:flutter/material.dart';

/// A single spot or activity in a day's itinerary.
class RoutineSpot {
  const RoutineSpot({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    required this.location,
    required this.icon,
    required this.color,
  });

  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final String location;
  final IconData icon;
  final Color color;

  RoutineSpot copyWith({
    String? startTime,
    String? endTime,
    String? title,
    String? description,
    String? location,
    IconData? icon,
    Color? color,
  }) {
    return RoutineSpot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
