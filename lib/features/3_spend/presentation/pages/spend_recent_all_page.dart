import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../bloc/spend_overview_bloc.dart';
import '../widgets/spend_wallet_accent.dart';
import '../widgets/spend_wallet_activity.dart';

/// Full recent-transaction list for global Spend page.
class SpendRecentAllPage extends StatelessWidget {
  const SpendRecentAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TriftlyAppBarTitle(title: 'Recent spending'),
      ),
      body: BlocBuilder<SpendOverviewBloc, SpendOverviewState>(
        builder: (context, state) {
          final lines = state.overview?.recentTransactions ?? [];
          if (lines.isEmpty) {
            return const Center(child: Text('No recent expenses'));
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.listBottomInset(context),
            ),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return SpendListCard(
                child: SpendActivityRow(line: lines[index]),
              );
            },
          );
        },
      ),
    );
  }
}
