import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/spend_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

/// Trip-scope banner on Spend tab — links back to global Spend page.
class SpendGlobalLinkBanner extends StatelessWidget {
  const SpendGlobalLinkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go(SpendNavigation.globalSpendPath),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All my spending',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'View balances across every trip',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
