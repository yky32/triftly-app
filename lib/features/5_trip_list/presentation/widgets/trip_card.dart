import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/plan/${trip.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _destinationEmoji(trip.destination),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}'
                    '${trip.buddies.isNotEmpty ? ' · ${trip.buddies.length} buddies' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (trip.buddies.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _BuddyDots(buddies: trip.buddies),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _destinationEmoji(String destination) {
    final lower = destination.toLowerCase();
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

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
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
                radius: 10,
                backgroundColor: _colorFromHex(buddy.avatarColor ?? '007AFF'),
                child: Text(
                  buddy.name.isNotEmpty ? buddy.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
        if (buddies.length > 5)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+${buddies.length - 5}',
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ),
      ],
    );
  }

  Color _colorFromHex(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }
}
