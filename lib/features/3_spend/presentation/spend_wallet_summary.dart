import 'package:decimal/decimal.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/utils/currency_utils.dart';

/// Wallet-facing totals for the global Spend page.
class SpendWalletSummary {
  const SpendWalletSummary({
    required this.currency,
    required this.myPaid,
    required this.myShare,
    required this.net,
    required this.owedToMe,
    required this.iOwe,
    required this.activeTripCount,
    required this.expenseCount,
  });

  final String currency;
  final Decimal myPaid;
  final Decimal myShare;
  final Decimal net;
  final Decimal owedToMe;
  final Decimal iOwe;
  final int activeTripCount;
  final int expenseCount;

  String get symbol => CurrencyUtils.symbolFor(currency);

  bool get isSettled => net == Decimal.zero;

  factory SpendWalletSummary.from(GlobalSpendOverview overview) {
    final trips = overview.tripsWithSpending;
    final currency = overview.activeTripsWithSpending.isNotEmpty
        ? overview.activeTripsWithSpending.first.currency
        : trips.isNotEmpty
            ? trips.first.currency
            : 'HKD';

    var paid = Decimal.zero;
    var share = Decimal.zero;
    var owed = Decimal.zero;
    var owe = Decimal.zero;

    for (final snap in trips) {
      if (snap.currency != currency) continue;
      paid += snap.myPaid;
      share += snap.myShare;
      if (snap.myNet > Decimal.zero) {
        owed += snap.myNet;
      } else if (snap.myNet < Decimal.zero) {
        owe += snap.myNet.abs();
      }
    }

    return SpendWalletSummary(
      currency: currency,
      myPaid: paid,
      myShare: share,
      net: paid - share,
      owedToMe: owed,
      iOwe: owe,
      activeTripCount: overview.activeTripsWithSpending.length,
      expenseCount: overview.totalExpenseCount,
    );
  }
}
