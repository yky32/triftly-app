/// Demo FX rates (units per 1 USD) for offline currency conversion.
abstract final class CurrencyRates {
  static const rates = <String, double>{
    'USD': 1.0,
    'HKD': 7.82,
    'JPY': 149.5,
    'TWD': 31.8,
    'KRW': 1330.0,
    'THB': 35.2,
    'SGD': 1.34,
    'CNY': 7.24,
    'EUR': 0.92,
    'GBP': 0.79,
  };

  static double convert({required double amount, required String from, required String to}) {
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    final usd = amount / fromRate;
    return usd * toRate;
  }
}
