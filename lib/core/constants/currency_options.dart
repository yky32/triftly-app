/// Supported trip currencies with display flags and symbols.
class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.flag,
    required this.symbol,
    required this.label,
  });

  final String code;
  final String flag;
  final String symbol;
  final String label;
}

abstract final class CurrencyOptions {
  static const List<CurrencyOption> all = [
    CurrencyOption(code: 'JPY', flag: '🇯🇵', symbol: '¥', label: 'Japan'),
    CurrencyOption(code: 'HKD', flag: '🇭🇰', symbol: 'HK\$', label: 'Hong Kong'),
    CurrencyOption(code: 'TWD', flag: '🇹🇼', symbol: 'NT\$', label: 'Taiwan'),
    CurrencyOption(code: 'KRW', flag: '🇰🇷', symbol: '₩', label: 'Korea'),
    CurrencyOption(code: 'THB', flag: '🇹🇭', symbol: '฿', label: 'Thailand'),
    CurrencyOption(code: 'SGD', flag: '🇸🇬', symbol: 'S\$', label: 'Singapore'),
    CurrencyOption(code: 'CNY', flag: '🇨🇳', symbol: '¥', label: 'China'),
    CurrencyOption(code: 'USD', flag: '🇺🇸', symbol: '\$', label: 'United States'),
    CurrencyOption(code: 'EUR', flag: '🇪🇺', symbol: '€', label: 'Eurozone'),
    CurrencyOption(code: 'GBP', flag: '🇬🇧', symbol: '£', label: 'United Kingdom'),
  ];

  static CurrencyOption? find(String code) {
    for (final option in all) {
      if (option.code == code) return option;
    }
    return null;
  }
}
