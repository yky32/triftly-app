import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/session/session_bloc.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buddy_avatar.dart';
import '../../../../core/widgets/confirm_bottom_sheet.dart';
import '../../../../core/widgets/glass_context_menu.dart';
import '../../../../core/widgets/glass_icon_button.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/spend_glass_shell.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../bloc/trip_detail_bloc.dart';
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
  bool _loadScheduled = false;
  late Trip _trip;

  Trip get trip => _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  void didUpdateWidget(covariant TripMembersBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.updatedAt != widget.trip.updatedAt) {
      _trip = widget.trip;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadScheduled) return;
    _loadScheduled = true;
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

  Future<void> _persistTrip(Trip updated) async {
    await AppScope.of(context).tripRepository.updateTrip(updated);
    if (!mounted) return;
    try {
      context.read<TripDetailBloc>().add(TripDetailTripUpdated(trip: updated));
    } catch (_) {}
    setState(() => _trip = updated);
  }

  bool _buddyReferencedInExpenses(String buddyId) {
    final detail = AppScope.of(context).tripRepository.detailSync(trip.id);
    if (detail == null) return false;
    return detail.expenses.any(
      (expense) =>
          expense.isActive &&
          (expense.paidById == buddyId || expense.splits.any((split) => split.buddyId == buddyId)),
    );
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

  void _shareTrip() => ShareTripBottomSheet.show(context, trip);

  Future<void> _addPlanBuddy() async {
    final result = await _PlanBuddyFormSheet.show(context);
    if (result == null || !mounted) return;

    await _persistTrip(
      trip.copyWith(
        buddies: [...trip.buddies, Buddy.create(name: result.name, userId: result.userId).copyWith(avatarColor: result.avatarColor)],
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _editPlanBuddy(Buddy buddy) async {
    final result = await _PlanBuddyFormSheet.show(context, buddy: buddy);
    if (result == null || !mounted) return;

    final updatedBuddies = trip.buddies
        .map((b) => b.id == buddy.id ? b.copyWith(name: result.name, avatarColor: result.avatarColor) : b)
        .toList();
    await _persistTrip(trip.copyWith(buddies: updatedBuddies, updatedAt: DateTime.now()));
  }

  Future<void> _removePlanBuddy(Buddy buddy) async {
    if (buddy.isMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot remove yourself from the plan group')),
      );
      return;
    }

    if (_buddyReferencedInExpenses(buddy.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${buddy.name} is in expenses — remove them from splits first')),
      );
      return;
    }

    final confirmed = await ConfirmBottomSheet.show(
      context,
      title: 'Remove ${buddy.name}?',
      message: 'They will be removed from splits and itinerary.',
      confirmLabel: 'Remove',
      destructive: true,
      icon: Icons.person_remove_outlined,
    );
    if (!confirmed || !mounted) return;

    final updatedBuddies = trip.buddies.where((b) => b.id != buddy.id).toList();
    await _persistTrip(trip.copyWith(buddies: updatedBuddies, updatedAt: DateTime.now()));
  }

  Future<void> _linkPlanBuddy(Buddy buddy) async {
    final available = _joined
        .where((member) => !trip.buddies.any((b) => b.userId == member.userId && b.id != buddy.id))
        .toList();
    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No joined accounts available to link')),
      );
      return;
    }

    final picked = await _LinkBuddySheet.show(context, members: available);
    if (picked == null || !mounted) return;

    final updatedBuddies = trip.buddies
        .map(
          (b) => b.id == buddy.id
              ? b.copyWith(userId: picked.userId, name: picked.displayLabel)
              : b,
        )
        .toList();
    await _persistTrip(trip.copyWith(buddies: updatedBuddies, updatedAt: DateTime.now()));
  }

  Future<void> _handlePlanBuddyAction(Buddy buddy, _PlanBuddyAction action) async {
    switch (action) {
      case _PlanBuddyAction.edit:
        await _editPlanBuddy(buddy);
      case _PlanBuddyAction.remove:
        await _removePlanBuddy(buddy);
      case _PlanBuddyAction.link:
        await _linkPlanBuddy(buddy);
    }
  }

  Future<void> _addJoinedToPlan(TripMemberSummary member) async {
    if (trip.buddies.any((b) => b.userId == member.userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.displayLabel} is already on the plan')),
      );
      return;
    }

    await _persistTrip(
      trip.copyWith(
        buddies: [
          ...trip.buddies,
          Buddy.create(name: member.displayLabel, userId: member.userId),
        ],
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _removeJoinedMember(TripMemberSummary member) async {
    final confirmed = await ConfirmBottomSheet.show(
      context,
      title: 'Remove ${member.displayLabel}?',
      message: 'They will lose access to this trip.',
      confirmLabel: 'Remove',
      destructive: true,
      icon: Icons.person_remove_outlined,
    );
    if (!confirmed || !mounted) return;

    setState(() => _updatingUserId = member.userId);
    final ok = await AppScope.of(context).tripRepository.removeTripMember(
          tripId: trip.id,
          memberUserId: member.userId,
        );
    if (!mounted) return;
    setState(() => _updatingUserId = null);

    if (ok) {
      await _loadJoined();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove member')),
      );
    }
  }

  Future<void> _handleJoinedMemberAction(TripMemberSummary member, _JoinedMemberAction action) async {
    switch (action) {
      case _JoinedMemberAction.addToPlan:
        await _addJoinedToPlan(member);
      case _JoinedMemberAction.remove:
        await _removeJoinedMember(member);
    }
  }

  List<GlassMenuEntry<_PlanBuddyAction>> _planBuddyMenuEntries(Buddy buddy) {
    return [
      const GlassMenuEntry(
        value: _PlanBuddyAction.edit,
        label: 'Edit',
        icon: Icons.edit_outlined,
      ),
      if (trip.canManageTripSettings && buddy.userId == null && _joined.isNotEmpty)
        const GlassMenuEntry(
          value: _PlanBuddyAction.link,
          label: 'Link account',
          icon: Icons.link_rounded,
        ),
      if (!buddy.isMe)
        const GlassMenuEntry(
          value: _PlanBuddyAction.remove,
          label: 'Remove',
          icon: Icons.person_remove_outlined,
          destructive: true,
        ),
    ];
  }

  List<GlassMenuEntry<_JoinedMemberAction>> _joinedMemberMenuEntries(TripMemberSummary member) {
    final onPlan = trip.buddies.any((b) => b.userId == member.userId);
    return [
      if (!onPlan)
        const GlassMenuEntry(
          value: _JoinedMemberAction.addToPlan,
          label: 'Add to plan',
          icon: Icons.group_add_outlined,
        ),
      const GlassMenuEntry(
        value: _JoinedMemberAction.remove,
        label: 'Remove access',
        icon: Icons.person_remove_outlined,
        destructive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = context.watch<SessionBloc>().state;
    final ownerName = _ownerDisplayName(session, trip);
    final planCount = trip.buddies.length;
    final joinedCount = _joined.length;
    final effectivePlanCount = planCount > 0 ? planCount : (trip.canManageTripSettings ? 1 : 0);
    final headlineCount = effectivePlanCount + joinedCount;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetSectionHeader(
            title: 'Trip buddies',
            caption: _headerCaption(effectivePlanCount, joinedCount),
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
                if (trip.canEditTripContent || trip.canManageTripSettings) ...[
                  const SizedBox(width: AppSpacing.sm),
                  GlassToolbarCluster(
                    children: [
                      if (trip.canEditTripContent)
                        GlassIconButton(
                          icon: Icons.person_add_outlined,
                          tooltip: 'Add',
                          bare: true,
                          size: 30,
                          onPressed: _addPlanBuddy,
                        ),
                      if (trip.canManageTripSettings)
                        GlassIconButton(
                          icon: Icons.ios_share_rounded,
                          tooltip: 'Share trip',
                          bare: true,
                          size: 30,
                          onPressed: _shareTrip,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (trip.buddies.isNotEmpty || trip.canManageTripSettings) ...[
            SheetSectionHeader(
              icon: Icons.people_outline_rounded,
              title: 'Plan group',
              caption: '$effectivePlanCount ${effectivePlanCount == 1 ? 'name' : 'names'} for splits & itinerary',
            ),
            const SizedBox(height: AppSpacing.sm),
            SheetSoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (trip.buddies.isEmpty && trip.canManageTripSettings)
                    _PlanBuddyRow(
                      avatar: BuddyAvatar(name: ownerName, size: 40),
                      name: ownerName,
                      subtitle: session.user?.email,
                      badges: _planBuddyBadges(isMe: true, isOwner: true),
                      canShowMenu: false,
                    )
                  else
                    for (var i = 0; i < trip.buddies.length; i++) ...[
                      if (i > 0) const SheetSoftListDivider(),
                      Builder(
                        builder: (menuContext) {
                          final buddy = trip.buddies[i];
                          final linked = buddy.userId != null;
                          return _PlanBuddyRow(
                            avatar: BuddyAvatar(
                              name: buddy.name,
                              colorHex: buddy.avatarColor,
                              size: 40,
                            ),
                            name: buddy.name,
                            subtitle: _planBuddySubtitle(session, buddy, linked),
                            badges: _planBuddyBadges(
                              isMe: buddy.isMe,
                              isOwner: trip.canManageTripSettings && buddy.isMe,
                              linked: linked,
                            ),
                            canShowMenu: trip.canEditTripContent,
                            onMenu: trip.canEditTripContent
                                ? () async {
                                    final action = await GlassContextMenu.show<_PlanBuddyAction>(
                                      context: menuContext,
                                      entries: _planBuddyMenuEntries(buddy),
                                    );
                                    if (action != null && mounted) {
                                      await _handlePlanBuddyAction(buddy, action);
                                    }
                                  }
                                : null,
                          );
                        },
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
                    Builder(
                      builder: (menuContext) {
                        final member = _joined[i];
                        return _JoinedMemberTile(
                          member: member,
                          canManage: trip.canManageTripSettings,
                          busy: _updatingUserId == member.userId,
                          onRoleChanged: (role) => _setRole(member, role),
                          onMenu: trip.canManageTripSettings
                              ? () async {
                                  final action = await GlassContextMenu.show<_JoinedMemberAction>(
                                    context: menuContext,
                                    entries: _joinedMemberMenuEntries(member),
                                  );
                                  if (action != null && mounted) {
                                    await _handleJoinedMemberAction(member, action);
                                  }
                                }
                              : null,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  String? _planBuddySubtitle(SessionState session, Buddy buddy, bool linked) {
    if (trip.canManageTripSettings && buddy.isMe) {
      return session.user?.email ?? 'You on this trip';
    }
    if (buddy.isMe) return 'You on this trip';
    if (linked) return 'Linked Triftly account';
    return null;
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

  static Widget? _planBuddyBadges({
    required bool isMe,
    required bool isOwner,
    bool linked = false,
  }) {
    if (!isMe && !linked) return null;

    final badges = <Widget>[
      if (isOwner) _RoleBadge(label: 'Owner', accent: AppColors.primary),
      if (isMe) _RoleBadge(label: 'You', accent: AppColors.textTertiary),
      if (linked && !isMe) _RoleBadge(label: 'Linked', accent: AppColors.primary),
    ];

    if (badges.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < badges.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          badges[i],
        ],
      ],
    );
  }
}

enum _PlanBuddyAction { edit, remove, link }

enum _JoinedMemberAction { addToPlan, remove }

class _PlanBuddyRow extends StatelessWidget {
  const _PlanBuddyRow({
    required this.avatar,
    required this.name,
    this.subtitle,
    this.badges,
    this.canShowMenu = false,
    this.onMenu,
  });

  final Widget avatar;
  final String name;
  final String? subtitle;
  final Widget? badges;
  final bool canShowMenu;
  final VoidCallback? onMenu;

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
          if (badges != null) ...[
            badges!,
            if (canShowMenu && onMenu != null) const SizedBox(width: 4),
          ],
          if (canShowMenu && onMenu != null) _RowMenuButton(onPressed: onMenu!),
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
    this.onMenu,
  });

  final TripMemberSummary member;
  final bool canManage;
  final bool busy;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback? onMenu;

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
          else if (canManage) ...[
            SizedBox(
              width: 132,
              child: SheetChoiceChipRow(
                options: const ['View', 'Edit'],
                selectedIndex: member.isEditor ? 1 : 0,
                onSelected: (index) => onRoleChanged(index == 1 ? 'editor' : 'viewer'),
              ),
            ),
            if (onMenu != null) ...[
              const SizedBox(width: 2),
              _RowMenuButton(onPressed: onMenu!),
            ],
          ] else
            _RoleBadge(
              label: member.isEditor ? 'Can edit' : 'View only',
              accent: member.isEditor ? AppColors.primary : AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}

class _RowMenuButton extends StatelessWidget {
  const _RowMenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary, size: 20),
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

class _PlanBuddyFormResult {
  const _PlanBuddyFormResult({required this.name, required this.avatarColor, this.userId});

  final String name;
  final String avatarColor;
  final String? userId;
}

class _PlanBuddyFormSheet extends StatefulWidget {
  const _PlanBuddyFormSheet({this.buddy});

  final Buddy? buddy;

  static Future<_PlanBuddyFormResult?> show(BuildContext context, {Buddy? buddy}) {
    return TriftlyBottomSheet.show<_PlanBuddyFormResult>(
      context,
      child: _PlanBuddyFormSheet(buddy: buddy),
    );
  }

  @override
  State<_PlanBuddyFormSheet> createState() => _PlanBuddyFormSheetState();
}

class _PlanBuddyFormSheetState extends State<_PlanBuddyFormSheet> {
  static const _palette = [
    'FF6B6B', '4ECDC4', '45B7D1', '96CEB4',
    'FFEAA7', 'DDA0DD', '74B9FF', 'A29BFE',
  ];

  late final TextEditingController _nameController;
  late String _selectedColor;

  bool get _isEdit => widget.buddy != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.buddy?.name ?? '');
    _selectedColor = widget.buddy?.avatarColor ?? _palette.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(
      _PlanBuddyFormResult(
        name: name,
        avatarColor: _selectedColor,
        userId: widget.buddy?.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold.swipeForm(
      compact: true,
      swipeLabel: _isEdit ? 'Slide to save changes' : 'Slide to add buddy',
      swipeEnabled: _canSave,
      onSwipeConfirmed: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetSectionHeader(
            title: _isEdit ? 'Edit buddy' : 'Add buddy',
            caption: 'For splits & itinerary',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Row(
              children: [
                SheetIconTile(
                  icon: _isEdit ? Icons.edit_outlined : Icons.person_add_outlined,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SheetInlineField(
                    controller: _nameController,
                    hint: 'Name',
                    textInputAction: TextInputAction.done,
                    onChanged: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SheetSectionHeader(title: 'Avatar color'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _palette.map((hex) {
              final selected = hex == _selectedColor;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedColor = hex);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(int.parse('FF$hex', radix: 16)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LinkBuddySheet extends StatelessWidget {
  const _LinkBuddySheet({required this.members});

  final List<TripMemberSummary> members;

  static Future<TripMemberSummary?> show(
    BuildContext context, {
    required List<TripMemberSummary> members,
  }) {
    return TriftlyBottomSheet.show<TripMemberSummary>(
      context,
      child: _LinkBuddySheet(members: members),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(
            title: 'Link account',
            caption: 'Match a plan name to a joined Triftly account',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < members.length; i++) ...[
                  if (i > 0) const SheetSoftListDivider(),
                  ListTile(
                    leading: BuddyAvatar(name: members[i].displayLabel, size: 40),
                    title: Text(
                      members[i].displayLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: members[i].subtitle != null ? Text(members[i].subtitle!) : null,
                    onTap: () => Navigator.of(context).pop(members[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
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
