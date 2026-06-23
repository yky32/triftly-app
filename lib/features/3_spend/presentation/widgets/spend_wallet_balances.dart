import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/triftly_motion.dart';
import 'spend_wallet_accent.dart';

/// Cross-trip "who owes whom" for the global Spend page.
class SpendWalletBalances extends StatelessWidget {
  const SpendWalletBalances({
    required this.lines,
    this.maxLines = 5,
    super.key,
  });

  final List<BuddyOweLine> lines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    final visible = lines.take(maxLines).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpendSectionTitle(title: 'Balances', count: lines.length),
        SpendListCard(
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                _BalanceRow(line: visible[i]),
              ],
              if (lines.length > maxLines)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 12),
                  child: Text(
                    '+ ${lines.length - maxLines} more across trips',
                    style: spendItemText(
                      Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.line});

  final BuddyOweLine line;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final symbol = CurrencyUtils.symbolFor(line.currency);
    final owesMe = line.amount > Decimal.zero;
    final amount = line.amount.abs();
    final tint = owesMe ? AppColors.success : AppColors.error;

    return Pressable(
      onTap: () => SpendNavigation.openTripSpend(context, line.trip.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: tint.withValues(alpha: 0.14),
              child: Text(
                line.counterparty.name.isNotEmpty ? line.counterparty.name[0].toUpperCase() : '?',
                style: TextStyle(color: tint, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owesMe ? '${line.counterparty.name} owes you' : 'You owe ${line.counterparty.name}',
                    style: spendItemText(
                      Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    line.trip.name,
                    style: spendItemText(
                      Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${owesMe ? '+' : '−'}$symbol${CurrencyUtils.formatDecimal(amount)}',
              style: spendItemText(
                Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
