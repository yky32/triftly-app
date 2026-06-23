import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (netLabel, netColor) = switch (true) {
      _ when net > Decimal.zero => ('+$symbol${CurrencyUtils.formatDecimal(net)}', AppColors.success),
      _ when net < Decimal.zero => ('-$symbol${CurrencyUtils.formatDecimal(net.abs())}', AppColors.error),
      _ => ('Settled', isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
    };

    return InkWell(
      onTap: () => SpendNavigation.openTripSpend(context, trip.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                trip.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              netLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: netColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
