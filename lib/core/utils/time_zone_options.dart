/// Common travel time zones as fixed UTC offsets (demo; no DST).
class TimeZoneOption {
  const TimeZoneOption({
    required this.id,
    required this.label,
    required this.city,
    required this.offsetHours,
  });

  final String id;
  final String label;
  final String city;
  final double offsetHours;

  DateTime now() => DateTime.now().toUtc().add(Duration(minutes: (offsetHours * 60).round()));
}

abstract final class TimeZoneOptions {
  static const all = [
    TimeZoneOption(id: 'hkt', label: 'Hong Kong', city: 'HKT', offsetHours: 8),
    TimeZoneOption(id: 'jst', label: 'Tokyo', city: 'JST', offsetHours: 9),
    TimeZoneOption(id: 'kst', label: 'Seoul', city: 'KST', offsetHours: 9),
    TimeZoneOption(id: 'sgt', label: 'Singapore', city: 'SGT', offsetHours: 8),
    TimeZoneOption(id: 'bkk', label: 'Bangkok', city: 'ICT', offsetHours: 7),
    TimeZoneOption(id: 'tpe', label: 'Taipei', city: 'CST', offsetHours: 8),
    TimeZoneOption(id: 'lhr', label: 'London', city: 'GMT', offsetHours: 0),
    TimeZoneOption(id: 'par', label: 'Paris', city: 'CET', offsetHours: 1),
    TimeZoneOption(id: 'nyc', label: 'New York', city: 'EST', offsetHours: -5),
    TimeZoneOption(id: 'lax', label: 'Los Angeles', city: 'PST', offsetHours: -8),
  ];

  static TimeZoneOption byId(String id) =>
      all.firstWhere((z) => z.id == id, orElse: () => all.first);
}
