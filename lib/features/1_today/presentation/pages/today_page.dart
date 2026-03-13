import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/router/app_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(now),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.page_today,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$greeting, Traveller ✈️',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined,
                        color: colorScheme.onSurfaceVariant),
                    onPressed: () => context.push(AppPage.settings.path),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Active Trip Banner ────────────────────────────────────
              _ActiveTripBanner(onTap: () => context.goNamed(AppPage.routine.name)),

              const SizedBox(height: 24),

              // ── Today's Schedule ─────────────────────────────────────
              _SectionHeader(title: "Today's Schedule"),
              const SizedBox(height: 12),
              const _TodaySchedule(),

              const SizedBox(height: 24),

              // ── Upcoming Trips ────────────────────────────────────────
              _SectionHeader(
                title: 'Upcoming Trips',
                action: TextButton(
                  onPressed: () => context.goNamed(AppPage.trips.name),
                  child: Text(
                    'View all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _UpcomingTripsRow(),

              const SizedBox(height: 24),

              // ── Quick Actions ─────────────────────────────────────────
              _SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),
              _QuickActionsGrid(
                actions: [
                  _QuickAction(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'New Trip',
                    color: AppColors.driftTeal,
                    onTap: () => context.goNamed(AppPage.routine.name),
                  ),
                  _QuickAction(
                    icon: Icons.luggage_rounded,
                    label: 'My Trips',
                    color: AppColors.calmGreen,
                    onTap: () => context.goNamed(AppPage.trips.name),
                  ),
                  _QuickAction(
                    icon: Icons.map_outlined,
                    label: 'Map',
                    color: AppColors.softAmber,
                    onTap: () => context.goNamed(AppPage.map.name),
                  ),
                  _QuickAction(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Spend',
                    color: AppColors.sunsetCoral,
                    onTap: () => context.goNamed(AppPage.spend.name),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$weekday, $month ${dt.day}';
  }
}

// ── Active Trip Banner ──────────────────────────────────────────────────────

class _ActiveTripBanner extends StatelessWidget {
  const _ActiveTripBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.deepTeal, AppColors.driftTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTIVE TRIP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '5 days left',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Japan Spring Tour',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Tokyo · Kyoto · Osaka',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Mar 10 – Mar 20, 2026',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Open Routine',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (action != null) ...[const Spacer(), action!],
      ],
    );
  }
}

// ── Today's Schedule ─────────────────────────────────────────────────────────

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule();

  static const _items = [
    _ScheduleItem('9:00 AM', 'Check in — Shinjuku Hotel', AppColors.driftTeal, Icons.hotel_rounded),
    _ScheduleItem('11:30 AM', 'Meiji Shrine visit', AppColors.calmGreen, Icons.temple_buddhist_rounded),
    _ScheduleItem('1:00 PM', 'Lunch at Ichiran Ramen', AppColors.softAmber, Icons.restaurant_rounded),
    _ScheduleItem('3:00 PM', 'Shibuya Crossing & shopping', AppColors.sunsetCoral, Icons.shopping_bag_rounded),
    _ScheduleItem('7:30 PM', 'Dinner reservation — Izakaya', AppColors.deepTeal, Icons.dinner_dining_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fogGray.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 56,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) => _ScheduleTile(item: _items[index]),
      ),
    );
  }
}

class _ScheduleItem {
  const _ScheduleItem(this.time, this.title, this.color, this.icon);
  final String time;
  final String title;
  final Color color;
  final IconData icon;
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.item});
  final _ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Trips row ────────────────────────────────────────────────────────

class _UpcomingTripsRow extends StatelessWidget {
  const _UpcomingTripsRow();

  static const _trips = [
    _UpcomingTrip('Seoul', 'Apr 5', AppColors.calmGreen),
    _UpcomingTrip('Bali', 'May 12', AppColors.softAmber),
    _UpcomingTrip('Paris', 'Jun 1', AppColors.sunsetCoral),
    _UpcomingTrip('NYC', 'Jul 20', AppColors.driftTeal),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _trips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _UpcomingTripChip(trip: _trips[i]),
      ),
    );
  }
}

class _UpcomingTrip {
  const _UpcomingTrip(this.name, this.date, this.color);
  final String name;
  final String date;
  final Color color;
}

class _UpcomingTripChip extends StatelessWidget {
  const _UpcomingTripChip({required this.trip});
  final _UpcomingTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: trip.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff_rounded, size: 18, color: trip.color),
          const SizedBox(height: 6),
          Text(
            trip.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            trip.date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});
  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: actions.map((a) => _QuickActionTile(action: a)).toList(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: action.color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 24),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
