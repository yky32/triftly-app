import 'package:flutter/material.dart';
import '../../../../core/models/spend_overview_models.dart';
import '../../../../core/navigation/spend_navigation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../spend_shared/widgets/spend_transaction_tile.dart';

class SpendRecentTransactions extends StatelessWidget {
  const SpendRecentTransactions({
    required this.transactions,
    super.key,
  });

  final List<SpendTransactionLine> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Recent · ${transactions.length}'),
        const SizedBox(height: AppSpacing.sm),
        ...transactions.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SpendTransactionTile(
              expense: line.expense,
              buddies: line.trip.buddies,
              tripCurrency: line.trip.defaultCurrency,
              tripLabel: line.trip.name,
              onTap: () => SpendNavigation.openTripSpend(context, line.trip.id),
            ),
          ),
        ),
      ],
    );
  }
}
