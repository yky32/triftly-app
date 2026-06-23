import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';

/// Compact trip wallet row — name + net amount only.
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => SpendNavigation.openTripSpend(context, trip.id),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  trip.destination.isNotEmpty ? trip.destination.characters.first.toUpperCase() : 'T',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$symbol${CurrencyUtils.formatDecimal(snapshot.tripTotal)} trip total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                netLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: netColor,
                      letterSpacing: -0.2,
                    ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
