import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_wallet_chrome.dart';

/// Trip wallet tile — floating card per trip.
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

    final (netLabel, tone) = switch (true) {
      _ when net > Decimal.zero => (
          '+$symbol${CurrencyUtils.formatDecimal(net)}',
          SpendWalletStatusTone.positive,
        ),
      _ when net < Decimal.zero => (
          '-$symbol${CurrencyUtils.formatDecimal(net.abs())}',
          SpendWalletStatusTone.negative,
        ),
      _ => ('Settled', SpendWalletStatusTone.neutral),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Pressable(
        onTap: () => SpendNavigation.openTripSpend(context, trip.id),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: SpendWalletChrome.surfaceCard(context),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  _destinationEmoji(trip.destination),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$symbol${CurrencyUtils.formatDecimal(snapshot.tripTotal)} total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (net == Decimal.zero)
                    SpendWalletStatusPill(label: netLabel, tone: tone)
                  else
                    Text(
                      netLabel,
                      style: SpendWalletChrome.moneyBody(
                        context,
                        size: 16,
                        color: tone == SpendWalletStatusTone.positive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Icon(Icons.north_east_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _destinationEmoji(String destination) {
    final lower = destination.toLowerCase();
    if (lower.contains('tokyo') || lower.contains('japan')) return '🇯🇵';
    if (lower.contains('taipei') || lower.contains('taiwan')) return '🇹🇼';
    if (lower.contains('bangkok') || lower.contains('thailand')) return '🇹🇭';
    if (lower.contains('osaka')) return '🇯🇵';
    if (lower.contains('seoul') || lower.contains('korea')) return '🇰🇷';
    if (lower.contains('paris') || lower.contains('france')) return '🇫🇷';
    return '✈️';
  }
}
