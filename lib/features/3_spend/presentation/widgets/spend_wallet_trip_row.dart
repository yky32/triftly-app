import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import 'spend_wallet_accent.dart';

class SpendWalletTripRow extends StatelessWidget {
  const SpendWalletTripRow({
    required this.snapshot,
    super.key,
  });

  final TripSpendSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final trip = snapshot.trip;
    final symbol = CurrencyUtils.symbolFor(snapshot.currency);
    final net = snapshot.myNet;

    final (sign, netLabel) = switch (true) {
      _ when net > Decimal.zero => (
          SpendSign.positive,
          '+$symbol${CurrencyUtils.formatDecimal(net)}',
        ),
      _ when net < Decimal.zero => (
          SpendSign.negative,
          '−$symbol${CurrencyUtils.formatDecimal(net.abs())}',
        ),
      _ => (SpendSign.neutral, 'Settled'),
    };

    return InkWell(
      onTap: () => SpendNavigation.openTripSpend(context, trip.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: spendListText(
                      Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trip.isInProgress)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'Active',
                        style: spendListText(
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SpendSignedBadge(label: netLabel, sign: sign, compact: true),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
