import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/destination_flags.dart';
import '../../../../core/widgets/confirm_bottom_sheet.dart';
import '../../../../core/widgets/glass_context_menu.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../../../../core/widgets/flight_leg_display.dart';
import '../../bloc/trip_list_bloc.dart';
import '../bottom_sheets/edit_trip_bottom_sheet.dart';

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Center(
                    child: Text(
                      DestinationFlags.forDestination(trip.destination),
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
                      if (trip.membershipBadgeLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          trip.membershipBadgeLabel!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!TripStore.isMockTripId(trip.id)) _TripMenu(trip: trip),
                const SizedBox(width: AppSpacing.xs),
                _StatusBadge(trip: trip),
              ],
            ),
            if (phase == TripPhase.inProgress) ...[
              const SizedBox(height: AppSpacing.md),
              _InProgressBar(trip: trip),
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
            if (_showUpcomingFlight(trip)) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.flight_takeoff_rounded,
                    size: 14,
                    color: FlightDirectionBadge.accentFor(true, isDark),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      flightLegCompactLabel(trip.outboundFlight!),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (trip.buddies.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _BuddyDots(buddies: trip.buddies),
            ],
          ],
        ),
      ),
    );
  }

  bool _showUpcomingFlight(Trip trip) {
    if (trip.phase != TripPhase.upcoming) return false;
    final outbound = trip.outboundFlight;
    if (outbound == null || outbound.isEmpty) return false;
    final daysUntil = trip.daysUntilStart;
    return daysUntil != null && daysUntil <= 7;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _TripMenu extends StatelessWidget {
  const _TripMenu({required this.trip});

  final Trip trip;

  Future<void> _openMenu(BuildContext context) async {
    final entries = trip.isJoinedMember
        ? [
            GlassMenuEntry(
              value: _TripMenuAction.leave,
              label: 'Leave',
              icon: Icons.logout_rounded,
            ),
          ]
        : [
            const GlassMenuEntry(
              value: _TripMenuAction.edit,
              label: 'Edit',
              icon: Icons.edit_outlined,
            ),
            const GlassMenuEntry(
              value: _TripMenuAction.delete,
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              destructive: true,
            ),
          ];

    final action = await GlassContextMenu.show<_TripMenuAction>(
      context: context,
      entries: entries,
    );
    if (action != null && context.mounted) {
      await _handleAction(context, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMenu(context),
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary, size: 20),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, _TripMenuAction action) async {
    final bloc = context.read<TripListBloc>();
    switch (action) {
      case _TripMenuAction.edit:
        await EditTripBottomSheet.show(
          context,
          trip: trip,
          onSaved: (updated) => bloc.add(TripListTripUpdated(trip: updated)),
        );
      case _TripMenuAction.delete:
        final confirmed = await ConfirmBottomSheet.show(
          context,
          title: 'Delete trip?',
          message: '“${trip.name}” will be removed from your list.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (confirmed && context.mounted) {
          bloc.add(TripListTripDeleted(tripId: trip.id));
        }
      case _TripMenuAction.leave:
        final confirmed = await ConfirmBottomSheet.show(
          context,
          title: 'Leave trip?',
          message:
              '“${trip.name}” will be removed from your Trips. You can re-join from the share link.',
          confirmLabel: 'Leave',
          icon: Icons.logout_rounded,
        );
        if (confirmed && context.mounted) {
          bloc.add(TripListTripLeft(tripId: trip.id));
        }
    }
  }
}

enum _TripMenuAction { edit, delete, leave }

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
  const _StatusBadge({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated;

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
  const _InProgressBar({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
