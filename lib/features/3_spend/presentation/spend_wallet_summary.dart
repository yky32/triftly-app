import 'package:decimal/decimal.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/utils/currency_conversion.dart';
import '../../../../core/utils/currency_utils.dart';

/// Per-currency wallet bucket for global Spend page.
class CurrencyWalletBucket {
  const CurrencyWalletBucket({
    required this.currency,
    required this.myPaid,
    required this.myShare,
    required this.owedToMe,
    required this.iOwe,
  });

  final String currency;
  final Decimal myPaid;
  final Decimal myShare;
  final Decimal owedToMe;
  final Decimal iOwe;

  Decimal get net => myPaid - myShare;

  bool get isSettled => net == Decimal.zero;

  String get symbol => CurrencyUtils.symbolFor(currency);
}

/// Wallet-facing totals for the global Spend page.
class SpendWalletSummary {
  const SpendWalletSummary({
    required this.primary,
    required this.otherCurrencies,
    required this.activeTripCount,
    required this.expenseCount,
    required this.meDisplayName,
    this.consolidatedNet,
  });

  final CurrencyWalletBucket primary;
  final List<CurrencyWalletBucket> otherCurrencies;
  final int activeTripCount;
  final int expenseCount;
  final String meDisplayName;
  final String? consolidatedNet;

  String get currency => primary.currency;
  String get symbol => primary.symbol;
  Decimal get myPaid => primary.myPaid;
  Decimal get myShare => primary.myShare;
  Decimal get net => primary.net;
  Decimal get owedToMe => primary.owedToMe;
  Decimal get iOwe => primary.iOwe;

  bool get isMultiCurrency => otherCurrencies.isNotEmpty;

  bool get isSettled =>
      primary.isSettled && otherCurrencies.every((bucket) => bucket.isSettled);

  factory SpendWalletSummary.from(
    GlobalSpendOverview overview, {
    String preferredCurrency = 'HKD',
  }) {
    final trips = overview.tripsWithSpending;
    final buckets = <String, CurrencyWalletBucket>{};

    for (final snap in trips) {
      final code = snap.currency;
      final existing = buckets[code];
      final owed = snap.myNet > Decimal.zero ? snap.myNet : Decimal.zero;
      final owe = snap.myNet < Decimal.zero ? snap.myNet.abs() : Decimal.zero;

      if (existing == null) {
        buckets[code] = CurrencyWalletBucket(
          currency: code,
          myPaid: snap.myPaid,
          myShare: snap.myShare,
          owedToMe: owed,
          iOwe: owe,
        );
      } else {
        buckets[code] = CurrencyWalletBucket(
          currency: code,
          myPaid: existing.myPaid + snap.myPaid,
          myShare: existing.myShare + snap.myShare,
          owedToMe: existing.owedToMe + owed,
          iOwe: existing.iOwe + owe,
        );
      }
    }

    final allBuckets = buckets.values.toList()
      ..sort((a, b) {
        final activeA = overview.activeTripsWithSpending.any((s) => s.currency == a.currency);
        final activeB = overview.activeTripsWithSpending.any((s) => s.currency == b.currency);
        if (activeA != activeB) return activeA ? -1 : 1;
        return b.net.abs().compareTo(a.net.abs());
      });

    final CurrencyWalletBucket primary;
    final List<CurrencyWalletBucket> others;

    if (allBuckets.isEmpty) {
      primary = CurrencyWalletBucket(
        currency: preferredCurrency,
        myPaid: Decimal.zero,
        myShare: Decimal.zero,
        owedToMe: Decimal.zero,
        iOwe: Decimal.zero,
      );
      others = const [];
    } else {
      final preferredIndex =
          allBuckets.indexWhere((bucket) => bucket.currency == preferredCurrency);
      if (preferredIndex >= 0) {
        primary = allBuckets[preferredIndex];
        others = [
          for (var i = 0; i < allBuckets.length; i++)
            if (i != preferredIndex) allBuckets[i],
        ];
      } else {
        primary = allBuckets.first;
        others = allBuckets.length <= 1 ? <CurrencyWalletBucket>[] : allBuckets.sublist(1);
      }
    }

    String? consolidated;
    if (allBuckets.length > 1) {
      var total = Decimal.zero;
      for (final bucket in allBuckets) {
        if (bucket.net == Decimal.zero) continue;
        final converted = CurrencyConversion.convert(
          amount: bucket.net.abs(),
          from: bucket.currency,
          to: preferredCurrency,
        );
        total += bucket.net > Decimal.zero ? converted : -converted;
      }
      if (total != Decimal.zero) {
        final prefix = total > Decimal.zero ? '+' : '−';
        consolidated =
            '$prefix${CurrencyUtils.symbolFor(preferredCurrency)}${CurrencyUtils.formatDecimal(total.abs())} $preferredCurrency total';
      }
    }

    return SpendWalletSummary(
      primary: primary,
      otherCurrencies: others,
      activeTripCount: overview.activeTripsWithSpending.length,
      expenseCount: overview.totalExpenseCount,
      meDisplayName: overview.meDisplayName,
      consolidatedNet: consolidated,
    );
  }
}
