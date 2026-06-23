import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/currency_options.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/destination_flags.dart';
import '../../../../core/widgets/triftly_motion.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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

    return Pressable(
      onTap: () => SpendNavigation.openTripSpend(context, trip.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpendCountryFlag(destination: trip.destination),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          trip.name,
                          style: spendItemText(
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trip.isInProgress) ...[
                        const SizedBox(width: 8),
                        const SpendInlineChip(label: 'Active'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.destination,
                    style: spendItemText(
                      Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      SpendCurrencyIcon(currency: snapshot.currency),
                      const SizedBox(width: 6),
                      Text(
                        '$symbol${CurrencyUtils.formatDecimal(snapshot.tripTotal)} spent',
                        style: spendItemText(
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SpendSignedBadge(label: netLabel, sign: sign, compact: true),
          ],
        ),
      ),
    );
  }
}

/// Country flag for a trip row.
class SpendCountryFlag extends StatelessWidget {
  const SpendCountryFlag({required this.destination, super.key});

  final String destination;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: border.withValues(alpha: 0.6)),
      ),
      child: Center(
        child: Text(
          DestinationFlags.forDestination(destination),
          style: const TextStyle(fontSize: 18, height: 1),
        ),
      ),
    );
  }
}

/// Small boxed currency flag shown before spent amount.
class SpendCurrencyIcon extends StatelessWidget {
  const SpendCurrencyIcon({required this.currency, super.key});

  final String currency;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Center(
        child: Text(
          CurrencyOptions.flagFor(currency),
          style: const TextStyle(fontSize: 13, height: 1),
        ),
      ),
    );
  }
}

/// Trips section — grouped list card.
class SpendWalletTrips extends StatelessWidget {
  const SpendWalletTrips({
    required this.snapshots,
    super.key,
  });

  final List<TripSpendSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpendSectionTitle(title: 'Trips', count: snapshots.length),
        SpendListCard(
          child: Column(
            children: [
              for (var i = 0; i < snapshots.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                SpendWalletTripRow(snapshot: snapshots[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
