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
    final showCountdown = trip.isUpcoming && daysUntil >= 0 && daysUntil <= 30;

    return Pressable(
      onTap: () => context.go('/plan/${trip.id}'),
      child: Hero(
        tag: 'trip-${trip.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
            child: Row(
              children: [
                _DestinationBadge(destination: trip.destination, showCountdown: showCountdown, daysUntil: daysUntil),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.destination,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}'
                        '${trip.buddies.isNotEmpty ? ' · ${trip.buddies.length} ${trip.buddies.length == 1 ? 'buddy' : 'buddies'}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (trip.buddies.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _BuddyDots(buddies: trip.buddies),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    ).staggerIn(index);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _DestinationBadge extends StatelessWidget {
  const _DestinationBadge({
    required this.destination,
    required this.showCountdown,
    required this.daysUntil,
  });

  final String destination;
  final bool showCountdown;
  final int daysUntil;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: showCountdown
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$daysUntil',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  daysUntil == 0 ? 'today' : 'days',
                  style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            )
          : Center(
              child: Text(
                _destinationEmoji(destination),
                style: const TextStyle(fontSize: 26),
              ),
            ),
    );
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
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 11,
                backgroundColor: _colorFromHex(buddy.avatarColor ?? '007AFF'),
                child: Text(
                  buddy.name.isNotEmpty ? buddy.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            )),
        if (buddies.length > 5)
          Text(
            '+${buddies.length - 5}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  Color _colorFromHex(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }
}
