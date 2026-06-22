import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const _destinations = [
    ('🗼', 'Tokyo', 'Japan'),
    ('🏔️', 'Seoul', 'Korea'),
    ('🌴', 'Bali', 'Indonesia'),
    ('🇬🇧', 'London', 'UK'),
    ('🇫🇷', 'Paris', 'France'),
    ('🏯', 'Osaka', 'Japan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadii.card,
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text('Where to next?', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Popular'),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _destinations.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final (emoji, name, _) = _destinations[index];
                return _DestinationChip(emoji: emoji, name: name);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Pro routes'),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.route_outlined, size: 28, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text('Coming soon', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Clone itineraries from travelers who know these cities well.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(name, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
