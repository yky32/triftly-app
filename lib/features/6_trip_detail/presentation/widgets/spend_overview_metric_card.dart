import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/triftly_motion.dart';

/// Shared compact hero metric used in the Spend tab overview row.
class SpendOverviewMetricCard extends StatelessWidget {
  const SpendOverviewMetricCard({
    required this.label,
    required this.amount,
    this.amountSuffix,
    this.meta,
    this.badgeLabel,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String label;
  final String amount;
  final String? amountSuffix;
  final String? meta;
  final String? badgeLabel;
  final Widget? trailing;
  final VoidCallback? onTap;

  static const _minHeight = 108.0;

  static TextStyle _labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Colors.white.withValues(alpha: 0.72),
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.45,
          height: 1.2,
        );
  }

  static TextStyle _amountStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.8,
      height: 1.05,
      fontFeatures: [FontFeature.tabularFigures()],
    );
  }

  static TextStyle _suffixStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
          color: Colors.white.withValues(alpha: 0.78),
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.2,
        );
  }

  static TextStyle _metaStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 12,
          height: 1.25,
        );
  }

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + 2,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: _labelStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeLabel != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _Badge(label: badgeLabel!),
                ],
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  trailing!,
                ],
              ],
            ),
            const Spacer(),
            _AmountLine(
              amount: amount,
              suffix: amountSuffix,
              amountStyle: _amountStyle(context),
              suffixStyle: _suffixStyle(context),
            ),
            if (meta != null) ...[
              const SizedBox(height: 4),
              Text(
                meta!,
                style: _metaStyle(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return Pressable(onTap: onTap, child: card);
  }
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.amount,
    required this.amountStyle,
    required this.suffixStyle,
    this.suffix,
  });

  final String amount;
  final String? suffix;
  final TextStyle amountStyle;
  final TextStyle suffixStyle;

  @override
  Widget build(BuildContext context) {
    if (suffix == null) {
      return Text(
        amount,
        style: amountStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: amount, style: amountStyle),
          TextSpan(text: ' $suffix', style: suffixStyle),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.1,
            ),
      ),
    );
  }
}
