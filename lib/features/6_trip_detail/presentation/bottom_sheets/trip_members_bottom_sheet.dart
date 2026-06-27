import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/session/session_bloc.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buddy_avatar.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/spend_glass_shell.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import 'share_trip_bottom_sheet.dart';

/// Trip buddies & joined-member access — avatar, name, role management.
class TripMembersBottomSheet extends StatefulWidget {
  const TripMembersBottomSheet({required this.trip, super.key});

  final Trip trip;

  static Future<void> show(BuildContext context, Trip trip) {
    return TriftlyBottomSheet.show(
      context,
      child: TripMembersBottomSheet(trip: trip),
    );
  }

  @override
  State<TripMembersBottomSheet> createState() => _TripMembersBottomSheetState();
}

class _TripMembersBottomSheetState extends State<TripMembersBottomSheet> {
  List<TripMemberSummary> _joined = const [];
  bool _loading = false;
  String? _updatingUserId;

  Trip get trip => widget.trip;

  @override
  void initState() {
    super.initState();
    _loadJoined();
  }

  Future<void> _loadJoined() async {
    setState(() => _loading = true);
    final members = await AppScope.of(context).tripRepository.tripMembers(trip.id);
    if (!mounted) return;
    setState(() {
      _joined = members;
      _loading = false;
    });
  }

  Future<void> _setRole(TripMemberSummary member, String role) async {
    setState(() => _updatingUserId = member.userId);
    final ok = await AppScope.of(context).tripRepository.setTripMemberRole(
          tripId: trip.id,
          memberUserId: member.userId,
          role: role,
        );
    if (!mounted) return;
    setState(() => _updatingUserId = null);
    if (ok) {
      await _loadJoined();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update role')),
      );
    }
  }

  void _inviteMore() {
    Navigator.of(context).pop();
    ShareTripBottomSheet.show(context, trip);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = context.watch<SessionBloc>().state;
    final ownerName = _ownerDisplayName(session, trip);
    final planCount = trip.buddies.length;
    final joinedCount = _joined.length;
    final headlineCount = (trip.canManageTripSettings ? 1 : 0) + planCount + joinedCount;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetSectionHeader(
            title: 'Trip buddies',
            caption: _headerCaption(planCount, joinedCount),
          ),
          const SizedBox(height: AppSpacing.md),
          SpendGlassShell(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$headlineCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        headlineCount == 1 ? 'person on this trip' : 'people on this trip',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (trip.canManageTripSettings) ...[
            const SheetSectionHeader(title: 'Owner', caption: 'Trip settings'),
            const SizedBox(height: AppSpacing.sm),
            _PersonTile(
              avatar: BuddyAvatar(name: ownerName, size: 40),
              name: ownerName,
              subtitle: session.user?.email,
              trailing: _RoleBadge(label: 'Owner', accent: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (trip.buddies.isNotEmpty) ...[
            SheetSectionHeader(
              title: 'Plan group',
              caption: '$planCount ${planCount == 1 ? 'name' : 'names'} for splits & itinerary',
            ),
            const SizedBox(height: AppSpacing.sm),
            SheetSoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < trip.buddies.length; i++) ...[
                    if (i > 0) const SheetSoftListDivider(),
                    _PersonTile(
                      avatar: BuddyAvatar(
                        name: trip.buddies[i].name,
                        colorHex: trip.buddies[i].avatarColor,
                        size: 40,
                      ),
                      name: trip.buddies[i].name,
                      subtitle: trip.buddies[i].isMe ? 'You on this trip' : null,
                      trailing: trip.buddies[i].isMe
                          ? _RoleBadge(label: 'You', accent: AppColors.textTertiary)
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          SheetSectionHeader(
            title: 'Joined on Triftly',
            caption: trip.canManageTripSettings
                ? 'Promote buddies to edit plan & spend'
                : 'Accounts linked via share link',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_joined.isEmpty)
            SheetSoftCard(
              child: Text(
                trip.canManageTripSettings
                    ? 'No one has joined yet — invite buddies with your share link.'
                    : 'No joined accounts yet.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            )
          else
            SheetSoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _joined.length; i++) ...[
                    if (i > 0) const SheetSoftListDivider(),
                    _JoinedMemberTile(
                      member: _joined[i],
                      canManage: trip.canManageTripSettings,
                      busy: _updatingUserId == _joined[i].userId,
                      onRoleChanged: (role) => _setRole(_joined[i], role),
                    ),
                  ],
                ],
              ),
            ),
          if (trip.canManageTripSettings) ...[
            const SizedBox(height: AppSpacing.lg),
            SheetPrimaryButton(label: 'Invite more buddies', onPressed: _inviteMore),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  static String _headerCaption(int planCount, int joinedCount) {
    final parts = <String>[];
    if (planCount > 0) parts.add('$planCount on plan');
    if (joinedCount > 0) parts.add('$joinedCount joined');
    if (parts.isEmpty) return 'People on this trip';
    return parts.join(' · ');
  }

  static String _ownerDisplayName(SessionState session, Trip trip) {
    final meBuddy = trip.buddies.where((b) => b.isMe).firstOrNull;
    if (meBuddy != null && meBuddy.name.trim().isNotEmpty) return meBuddy.name;
    final user = session.user;
    if (user != null && user.displayName.trim().isNotEmpty) return user.displayName;
    return 'You';
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.avatar,
    required this.name,
    this.subtitle,
    this.trailing,
  });

  final Widget avatar;
  final String name;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _JoinedMemberTile extends StatelessWidget {
  const _JoinedMemberTile({
    required this.member,
    required this.canManage,
    required this.busy,
    required this.onRoleChanged,
  });

  final TripMemberSummary member;
  final bool canManage;
  final bool busy;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BuddyAvatar(name: member.displayLabel, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (member.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (busy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (canManage)
            SizedBox(
              width: 132,
              child: SheetChoiceChipRow(
                options: const ['View', 'Edit'],
                selectedIndex: member.isEditor ? 1 : 0,
                onSelected: (index) => onRoleChanged(index == 1 ? 'editor' : 'viewer'),
              ),
            )
          else
            _RoleBadge(
              label: member.isEditor ? 'Can edit' : 'View only',
              accent: member.isEditor ? AppColors.primary : AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
          color: accent,
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
