import 'package:decimal/decimal.dart';
import 'currency_rates.dart';
import 'currency_utils.dart';

/// Decimal-safe currency conversion using offline demo rates.
abstract final class CurrencyConversion {
  static Decimal convert({
    required Decimal amount,
    required String from,
    required String to,
  }) {
    if (from == to) return amount;
    final converted = CurrencyRates.convert(
      amount: amount.toDouble(),
      from: from,
      to: to,
    );
    return Decimal.parse(converted.toStringAsFixed(2));
  }

  static String? tripEquivalentLabel({
    required Decimal amount,
    required String currency,
    required String tripCurrency,
  }) {
    if (currency == tripCurrency) return null;
    final converted = convert(amount: amount, from: currency, to: tripCurrency);
    final symbol = CurrencyUtils.symbolFor(tripCurrency);
    return '≈ $symbol${CurrencyUtils.formatDecimal(converted)} $tripCurrency';
  }

  static Decimal toTripCurrency({
    required Decimal amount,
    required String currency,
    required String tripCurrency,
  }) =>
      convert(amount: amount, from: currency, to: tripCurrency);
}
