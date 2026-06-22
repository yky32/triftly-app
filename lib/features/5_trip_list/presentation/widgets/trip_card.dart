import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../../../core/theme/segment_style.dart';

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
    final phase = trip.phase;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = SegmentStyle.of(phase);

    return Pressable(
      onTap: () => context.go('/plan/${trip.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: style.pill(isDark),
          borderRadius: AppRadii.card,
          boxShadow: [
            BoxShadow(
              color: style.foreground(isDark).withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
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
                    color: style.badge(isDark),
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
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
                _StatusBadge(trip: trip, style: style),
              ],
            ),
            if (phase == TripPhase.inProgress) ...[
              const SizedBox(height: AppSpacing.md),
              _InProgressBar(trip: trip, style: style),
            ],
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
    if (lower.contains('hong kong')) return '🇭🇰';
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.trip, required this.style});

  final Trip trip;
  final SegmentStyle style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = style.foreground(isDark);
    final bg = style.badge(isDark);

    switch (trip.phase) {
      case TripPhase.inProgress:
        final day = trip.currentDayNumber!;
        return _Badge(label: 'Day $day', background: bg, foreground: fg);
      case TripPhase.upcoming:
        final days = trip.daysUntilStart!;
        if (days > 14) return const SizedBox.shrink();
        return _Badge(
          label: days == 0 ? 'Today' : '${days}d',
          background: bg,
          foreground: fg,
        );
      case TripPhase.completed:
        return _Badge(label: 'Done', background: bg, foreground: fg);
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground),
      ),
    );
  }
}

class _InProgressBar extends StatelessWidget {
  const _InProgressBar({required this.trip, required this.style});

  final Trip trip;
  final SegmentStyle style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = style.foreground(isDark);
    final day = trip.currentDayNumber!;
    final total = trip.numberOfDays;
    final progress = (day / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Day $day of $total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (trip.daysRemaining != null && trip.daysRemaining! > 0)
              Text(
                '${trip.daysRemaining}d left',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: style.badge(isDark),
            color: accent,
          ),
        ),
      ],
    );
  }
}
