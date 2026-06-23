import 'package:flutter/material.dart';
import '../../../core/models/trip_models.dart';
import '../../../core/services/split_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/app_card.dart';

/// Settlement preview — who owes whom (up to [maxLines]).
class SpendSettlementPreview extends StatelessWidget {
  const SpendSettlementPreview({
    required this.trip,
    required this.transactions,
    this.maxLines = 3,
    this.onTap,
    super.key,
  });

  final Trip trip;
  final List<SettlementTransaction> transactions;
  final int maxLines;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(trip.defaultCurrency);

    if (transactions.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'All settled up',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Who owes whom', style: Theme.of(context).textTheme.titleSmall),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...transactions.take(maxLines).map((t) {
            final from = trip.buddies.firstWhere(
              (b) => b.id == t.fromId,
              orElse: () => Buddy(id: '', name: '?'),
            );
            final to = trip.buddies.firstWhere(
              (b) => b.id == t.toId,
              orElse: () => Buddy(id: '', name: '?'),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text('${from.name} → ${to.name}')),
                  Text(
                    '$symbol${CurrencyUtils.formatDecimal(t.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          if (transactions.length > maxLines)
            Text(
              '+ ${transactions.length - maxLines} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
