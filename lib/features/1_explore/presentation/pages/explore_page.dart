import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/triftly_motion.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Explore'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar().fadeSlideIn(),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'POPULAR DESTINATIONS'),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _destinations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final (emoji, name, country) = _destinations[index];
                        return _DestinationCard(
                          emoji: emoji,
                          name: name,
                          country: country,
                          index: index,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'PRO ROUTES'),
                  _ComingSoonCard().fadeSlideIn(delay: 200.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: AppRadii.card,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Where are you going?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.emoji,
    required this.name,
    required this.country,
    required this.index,
  });

  final String emoji;
  final String name;
  final String country;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {},
      child: Container(
        width: 108,
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: AppRadii.card,
          boxShadow: AppShadows.soft(context),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
            ),
            Text(
              country,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ).staggerIn(index, delayStep: 0.06);
  }
}

class _ComingSoonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.exploreGradient,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: const Icon(Icons.route_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Pro Routes Coming Soon',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Clone how pros travel the same places',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
