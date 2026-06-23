/// Demo lookup data for Japan Mapcode (short codes for car nav).
abstract final class MapcodeLookup {
  static const entries = [
    MapcodeResult(
      label: 'Tokyo Tower',
      address: '4-2-8 Shibakoen, Minato, Tokyo',
      mapcode: '349 246 831*52',
    ),
    MapcodeResult(
      label: 'Shibuya Station',
      address: '2-1 Dogenzaka, Shibuya, Tokyo',
      mapcode: '349 386 194*82',
    ),
    MapcodeResult(
      label: 'Kyoto Station',
      address: 'Higashishiokoji Kamadonocho, Shimogyo, Kyoto',
      mapcode: '349 390 324*55',
    ),
    MapcodeResult(
      label: 'Fukuoka Airport',
      address: '739 Aoki, Hakata, Fukuoka',
      mapcode: '206 572 537*24',
    ),
    MapcodeResult(
      label: 'Osaka Castle',
      address: '1-1 Osakajo, Chuo, Osaka',
      mapcode: '349 628 483*15',
    ),
  ];

  static MapcodeResult? byAddress(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;
    for (final entry in entries) {
      if (entry.label.toLowerCase().contains(q) || entry.address.toLowerCase().contains(q)) {
        return entry;
      }
    }
    return null;
  }

  static MapcodeResult? byMapcode(String query) {
    final normalized = query.replaceAll(RegExp(r'[\s*]'), '').toLowerCase();
    if (normalized.isEmpty) return null;
    for (final entry in entries) {
      final code = entry.mapcode.replaceAll(RegExp(r'[\s*]'), '').toLowerCase();
      if (code == normalized || code.startsWith(normalized) || normalized.startsWith(code)) {
        return entry;
      }
    }
    return null;
  }
}

class MapcodeResult {
  const MapcodeResult({
    required this.label,
    required this.address,
    required this.mapcode,
  });

  final String label;
  final String address;
  final String mapcode;
}
