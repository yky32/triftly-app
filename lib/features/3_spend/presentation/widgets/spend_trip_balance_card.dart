import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../spend_shared/widgets/spend_settlement_preview.dart';
import '../../../spend_shared/widgets/spend_transaction_tile.dart';

class SpendTripBalanceCard extends StatelessWidget {
  const SpendTripBalanceCard({
    required this.snapshot,
    super.key,
  });

  final TripSpendSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final trip = snapshot.trip;
    final symbol = CurrencyUtils.symbolFor(snapshot.currency);
    final phaseLabel = switch (true) {
      _ when trip.isInProgress => 'Active',
      _ when trip.isUpcoming => 'Upcoming',
      _ => 'Done',
    };
    final phaseColor = switch (true) {
      _ when trip.isInProgress => AppColors.primary,
      _ when trip.isUpcoming => AppColors.textSecondary,
      _ => AppColors.success,
    };

    return AppCard(
      onTap: () => SpendNavigation.openTripSpend(context, trip.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      trip.destination,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  phaseLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip total', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '$symbol${CurrencyUtils.formatDecimal(snapshot.tripTotal)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SpendNetLabel(net: snapshot.myNet, currency: snapshot.currency),
            ],
          ),
          if (snapshot.settlements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SpendSettlementPreview(
              trip: trip,
              transactions: snapshot.settlements,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}
