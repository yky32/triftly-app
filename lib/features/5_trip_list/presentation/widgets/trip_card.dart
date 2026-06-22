import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/triftly_motion.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final int index;

  const TripCard({
    required this.trip,
    this.index = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = trip.startDate.difference(DateTime.now()).inDays;
    final isSoon = trip.isUpcoming && daysUntil >= 0 && daysUntil <= 14;

    return Pressable(
      onTap: () => context.go('/plan/${trip.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: AppRadii.card,
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.tintForDestination(trip.destination),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Center(
                    child: Text(
                      _destinationEmoji(trip.destination),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.destination,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (isSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      daysUntil == 0 ? 'Today' : '${daysUntil}d',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (trip.buddies.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text('${trip.buddies.length}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
            if (trip.buddies.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _BuddyDots(buddies: trip.buddies),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _destinationEmoji(String dest) {
    final lower = dest.toLowerCase();
    if (lower.contains('tokyo')) return '🗼';
    if (lower.contains('seoul')) return '🏔️';
    if (lower.contains('bangkok')) return '🌴';
    if (lower.contains('osaka')) return '🏯';
    if (lower.contains('bali')) return '🏝️';
    if (lower.contains('london')) return '🇬🇧';
    if (lower.contains('paris')) return '🇫🇷';
    if (lower.contains('taipei')) return '🇹🇼';
    return '✈️';
  }
}

class _BuddyDots extends StatelessWidget {
  final List<Buddy> buddies;

  const _BuddyDots({required this.buddies});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...buddies.take(5).map((buddy) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: _colorFromHex(buddy.avatarColor ?? '0D9488'),
                child: Text(
                  buddy.name.isNotEmpty ? buddy.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            )),
        if (buddies.length > 5)
          Text('+${buddies.length - 5}', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Color _colorFromHex(String hex) => Color(int.parse('FF$hex', radix: 16));
}
