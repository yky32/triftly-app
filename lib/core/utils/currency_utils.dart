import 'package:decimal/decimal.dart';
import '../constants/currency_options.dart';

/// Static display rates for approximate conversion (HKD base).
abstract final class CurrencyUtils {
  static const _ratesToHkd = {
    'JPY': 0.052,
    'HKD': 1.0,
    'TWD': 0.24,
    'KRW': 0.0058,
    'THB': 0.22,
    'SGD': 5.8,
    'CNY': 1.08,
    'USD': 7.8,
    'EUR': 8.5,
    'GBP': 9.9,
    'IDR': 0.00048,
  };

  static String formatDecimal(Decimal d) {
    final str = d.toStringAsFixed(2);
    if (str.contains('.')) {
      final parts = str.split('.');
      if (parts[1] == '00') return parts[0];
      if (parts[1].endsWith('0')) return '${parts[0]}.${parts[1].substring(0, 1)}';
    }
    return str;
  }

  static String? approximateHkd({required Decimal amount, required String currency}) {
    if (currency == 'HKD') return null;
    final rate = _ratesToHkd[currency];
    if (rate == null) return null;
    final hkd = amount * Decimal.parse(rate.toString());
    final symbol = CurrencyOptions.find('HKD')?.symbol ?? 'HK\$';
    return '≈ $symbol${formatDecimal(hkd)}';
  }
}
