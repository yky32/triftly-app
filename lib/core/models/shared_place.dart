/// Parsed location from an inbound share (Maps, Safari, Messages, etc.).
class SharedPlace {
  const SharedPlace({
    required this.raw,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  final String raw;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  /// Best string for the Add Spot address field.
  String get addressLine {
    if (address != null && address!.trim().isNotEmpty) return address!.trim();
    return raw.trim();
  }

  /// Best string for the Add Spot name field.
  String? get nameLine {
    final value = name?.trim();
    if (value != null && value.isNotEmpty) return value;
    return null;
  }
}
