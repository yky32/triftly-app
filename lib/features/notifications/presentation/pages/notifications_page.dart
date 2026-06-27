import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/models/in_app_notification.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../../core/widgets/triftly_segment_control.dart';
import '../widgets/notification_tile.dart';

enum _NotificationFilter { all, trips, activity }

/// Notifications inbox — full page (replaces alert dialog).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  _NotificationFilter _filter = _NotificationFilter.all;

  List<NotificationItem> _itemsForFilter(_NotificationFilter filter) {
    final source = AppBootstrap.notificationStore.items
        .map(NotificationItem.from)
        .toList(growable: false);

    return switch (filter) {
      _NotificationFilter.all => source,
      _NotificationFilter.trips =>
        source.where((n) => n.category == InAppNotificationCategory.trip).toList(),
      _NotificationFilter.activity =>
        source.where((n) => n.category == InAppNotificationCategory.activity).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppBootstrap.notificationStore,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final items = _itemsForFilter(_filter);
        final hasItems = items.isNotEmpty;

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const TriftlyAppBarTitle(title: 'Notifications'),
            actions: [
              TextButton(
                onPressed: hasItems
                    ? () => AppBootstrap.notificationStore.markAllRead()
                    : null,
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: hasItems
                        ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: TriftlySegmentControl(
                  items: const [
                    SegmentItem(
                      label: 'All',
                      iconFilled: Icons.notifications_rounded,
                      iconOutlined: Icons.notifications_outlined,
                      toneIndex: 1,
                    ),
                    SegmentItem(
                      label: 'Trips',
                      iconFilled: Icons.flight_rounded,
                      iconOutlined: Icons.flight_outlined,
                      toneIndex: 0,
                    ),
                    SegmentItem(
                      label: 'Activity',
                      iconFilled: Icons.receipt_long_rounded,
                      iconOutlined: Icons.receipt_long_outlined,
                      toneIndex: 2,
                    ),
                  ],
                  selectedIndex: _filter.index,
                  onChanged: (index) =>
                      setState(() => _filter = _NotificationFilter.values[index]),
                ),
              ),
              Expanded(
                child: hasItems ? _buildList(context, items) : _buildEmpty(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<NotificationItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.listBottomInset(context),
      ),
      children: [
        SheetSoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: dividerColor),
                NotificationTile(
                  item: items[i],
                  onTap: items[i].tripId == null
                      ? null
                      : () => context.push('/plan/${items[i].tripId}'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.listBottomInset(context),
      ),
      children: [
        const EmptyState(
          expand: false,
          icon: Icons.notifications_none_outlined,
          title: 'You\'re all caught up',
          subtitle: 'Trip invites, buddy joins, and updates will appear here.',
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Preview',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Opacity(
          opacity: 0.45,
          child: IgnorePointer(
            child: Skeletonizer(
              enabled: true,
              child: SheetSoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: _previewItems
                      .map((item) => NotificationTile(item: item))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder rows — shows future notification layout when inbox is empty.
final _previewItems = [
  NotificationItem(
    id: 'preview-1',
    title: 'Buddy joined your trip',
    body: 'Alex accepted your invite to Tokyo 2026.',
    timestamp: DateTime(2026, 6, 1, 10, 0),
    icon: Icons.group_add_outlined,
    category: InAppNotificationCategory.trip,
    unread: true,
  ),
  NotificationItem(
    id: 'preview-2',
    title: 'Trip starts tomorrow',
    body: 'Tokyo 2026 · Jun 27 – Jun 28',
    timestamp: DateTime(2026, 6, 1, 7, 0),
    icon: Icons.flight_outlined,
    category: InAppNotificationCategory.trip,
    accent: AppColors.primaryDark,
  ),
  NotificationItem(
    id: 'preview-3',
    title: 'New expense added',
    body: 'Dinner · ¥4,200 split with the group',
    timestamp: DateTime(2026, 5, 31, 12, 0),
    icon: Icons.receipt_long_outlined,
    category: InAppNotificationCategory.activity,
    accent: AppColors.warning,
  ),
];
