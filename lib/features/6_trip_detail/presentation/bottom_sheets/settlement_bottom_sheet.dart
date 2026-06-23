import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/split_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_conversion.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

class SettlementBottomSheet extends StatelessWidget {
  const SettlementBottomSheet({
    required this.trip,
    required this.expenses,
    super.key,
  });

  final Trip trip;
  final List<Expense> expenses;

  static Future<void> show(
    BuildContext context, {
    required Trip trip,
    required List<Expense> expenses,
  }) {
    return TriftlyBottomSheet.show(
      context,
      child: SettlementBottomSheet(trip: trip, expenses: expenses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = trip.defaultCurrency;
    final symbol = CurrencyUtils.symbolFor(currency);
    final total = expenses.fold<Decimal>(
      Decimal.zero,
      (sum, e) =>
          sum +
          CurrencyConversion.toTripCurrency(
            amount: e.amount,
            currency: e.currency,
            tripCurrency: currency,
          ),
    );
    final transactions = SplitCalculator.calculateSettlement(
      expenses: expenses,
      buddies: trip.buddies,
      settleCurrency: currency,
    );
    final balances = _buddyBalances(expenses);
    final allSettled = transactions.isEmpty;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(
            title: 'Settlement',
            caption: 'Who owes whom',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetGradientHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Trip total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$symbol${CurrencyUtils.formatDecimal(total)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
                if (CurrencyUtils.approximateHkd(amount: total, currency: currency)
                    case final converted?) ...[
                  const SizedBox(height: 4),
                  Text(converted, style: Theme.of(context).textTheme.bodySmall),
                ],
                if (allSettled) ...[
                  const SizedBox(height: AppSpacing.md),
                  SheetResultBanner(
                    caption: 'All clear',
                    text: 'Everyone is even',
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.md),
                  SheetResultBanner(
                    caption: 'Minimized payments',
                    text: '${transactions.length} ${transactions.length == 1 ? 'transaction' : 'transactions'} needed',
                  ),
                ],
              ],
            ),
          ),
          if (!allSettled) ...[
            const SizedBox(height: AppSpacing.xl),
            const SheetSectionHeader(title: 'Pay back'),
            const SizedBox(height: AppSpacing.md),
            SheetSoftCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: transactions.map((t) {
                  final from = _buddyName(t.fromId);
                  final to = _buddyName(t.toId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        _BuddyDot(name: from),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                from,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                'pays $to',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$symbol${CurrencyUtils.formatDecimal(t.amount)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (balances.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const SheetSectionHeader(title: 'Balances', caption: 'Net position'),
            const SizedBox(height: AppSpacing.md),
            SheetSoftCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: balances.entries.map((entry) {
                  final buddy = trip.buddies.firstWhere(
                    (b) => b.id == entry.key,
                    orElse: () => Buddy(id: entry.key, name: '?'),
                  );
                  final balance = entry.value;
                  if (balance == Decimal.zero) return const SizedBox.shrink();
                  final isPositive = balance > Decimal.zero;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        _BuddyDot(name: buddy.name, colorHex: buddy.avatarColor),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            buddy.name,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          '${isPositive ? '+' : '−'}$symbol${CurrencyUtils.formatDecimal(balance.abs())}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: isPositive ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buddyName(String id) {
    return trip.buddies
        .firstWhere((b) => b.id == id, orElse: () => Buddy(id: id, name: '?'))
        .name;
  }

  Map<String, Decimal> _buddyBalances(List<Expense> expenses) {
    final balances = <String, Decimal>{};
    for (final buddy in trip.buddies) {
      balances[buddy.id] = Decimal.zero;
    }
    for (final raw in expenses) {
      final expense = SplitCalculator.normalizeExpense(raw, trip.defaultCurrency);
      balances[expense.paidById] =
          (balances[expense.paidById] ?? Decimal.zero) + expense.amount;
      for (final split in expense.splits) {
        balances[split.buddyId] =
            (balances[split.buddyId] ?? Decimal.zero) - split.shareAmount;
      }
    }
    return balances;
  }
}

class _BuddyDot extends StatelessWidget {
  const _BuddyDot({required this.name, this.colorHex});

  final String name;
  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (colorHex != null) {
      color = Color(int.parse('FF$colorHex', radix: 16));
    } else {
      color = AppColors.categoryColor(SpotCategory.values[name.hashCode % SpotCategory.values.length]);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
