/// Country-flag emoji for a trip destination string.
abstract final class DestinationFlags {
  static String forDestination(String destination) {
    final lower = destination.toLowerCase();

    if (lower.contains('japan') ||
        lower.contains('tokyo') ||
        lower.contains('osaka') ||
        lower.contains('kyoto')) {
      return '🇯🇵';
    }
    if (lower.contains('korea') || lower.contains('seoul')) return '🇰🇷';
    if (lower.contains('thailand') || lower.contains('bangkok')) return '🇹🇭';
    if (lower.contains('taiwan') || lower.contains('taipei')) return '🇹🇼';
    if (lower.contains('hong kong')) return '🇭🇰';
    if (lower.contains('singapore')) return '🇸🇬';
    if (lower.contains('china') || lower.contains('beijing') || lower.contains('shanghai')) {
      return '🇨🇳';
    }
    if (lower.contains('indonesia') || lower.contains('bali')) return '🇮🇩';
    if (lower.contains('united kingdom') || lower.contains('london') || lower.contains('uk')) {
      return '🇬🇧';
    }
    if (lower.contains('france') || lower.contains('paris')) return '🇫🇷';
    if (lower.contains('united states') || lower.contains('usa') || lower.contains('new york')) {
      return '🇺🇸';
    }
    if (lower.contains('euro') || lower.contains('germany') || lower.contains('berlin')) {
      return '🇪🇺';
    }

    return '✈️';
  }
}
