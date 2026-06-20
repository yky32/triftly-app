import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                SizedBox(width: 8),
                Text('Where are you going?', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Popular destinations
          Text('POPULAR DESTINATIONS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, letterSpacing: 1)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _DestinationCard(emoji: '🗼', name: 'Tokyo'),
                const SizedBox(width: 12),
                _DestinationCard(emoji: '🏔️', name: 'Seoul'),
                const SizedBox(width: 12),
                _DestinationCard(emoji: '🌴', name: 'Bali'),
                const SizedBox(width: 12),
                _DestinationCard(emoji: '🇬🇧', name: 'London'),
                const SizedBox(width: 12),
                _DestinationCard(emoji: '🇫🇷', name: 'Paris'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Coming soon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.explore, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Text('Pro Routes Coming Soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                const Text('Clone how pros travel the same places', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final String emoji;
  final String name;

  const _DestinationCard({required this.emoji, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
