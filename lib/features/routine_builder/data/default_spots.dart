import 'package:flutter/material.dart';
import 'package:triftly/features/routine_builder/models/routine_spot.dart';

/// Placeholder spots shown for each day when a trip is created.
/// Stored in bloc state so any spot (including these) can be edited.
const List<RoutineSpot> kDefaultRoutineSpots = [
  RoutineSpot(
    startTime: '8:30 AM',
    endTime: '9:30 AM',
    title: 'Morning Coffee at Ikigai Arabica',
    description: 'Start the day with a specialty pour-over and light pastry.',
    location: '1-1-3 Jinnan, Shibuya-ku, Tokyo',
    icon: Icons.coffee,
    color: Color(0xFFE65100),
  ),
  RoutineSpot(
    startTime: '10:00 AM',
    endTime: '11:45 AM',
    title: 'Tokyo Station → Odawara Station',
    description:
        'JR Tokaido Line. Reserved seat recommended for Hakone direction.',
    location: '1-9-1 Marunouchi, Chiyoda-ku, Tokyo',
    icon: Icons.train,
    color: Color(0xFF2E7D32),
  ),
  RoutineSpot(
    startTime: '12:00 PM',
    endTime: '3:00 PM',
    title: 'Hakone Open-Air Museum',
    description: 'Art and nature. Allow 2–3 hours. Café on site.',
    location: '1121 Ninotaira, Hakone-machi',
    icon: Icons.museum_outlined,
    color: Color(0xFF0277BD),
  ),
  RoutineSpot(
    startTime: '3:30 PM',
    endTime: '4:30 PM',
    title: 'Hakone Kowakien Yunessun',
    description: 'Hot spring theme park. Various baths and pools.',
    location: '1297 Ninotaira, Hakone-machi',
    icon: Icons.spa_outlined,
    color: Color(0xFF6A1B9A),
  ),
  RoutineSpot(
    startTime: '5:00 PM',
    endTime: '6:30 PM',
    title: 'Odawara Station → Shibuya Station',
    description: 'Return leg. Direct trains available.',
    location: '1-1-1 Odawara, Kanagawa',
    icon: Icons.train,
    color: Color(0xFF2E7D32),
  ),
  RoutineSpot(
    startTime: '7:00 PM',
    endTime: '8:30 PM',
    title: 'Dinner at Shibuya Sky',
    description: 'Rooftop dining with city views. Reserve in advance.',
    location: '2-24-12 Dogenzaka, Shibuya-ku, Tokyo',
    icon: Icons.restaurant,
    color: Color(0xFFC62828),
  ),
];
