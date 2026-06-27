import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/share_link.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

class ShareTripBottomSheet extends StatefulWidget {
  const ShareTripBottomSheet({required this.trip, super.key});

  final Trip trip;

  static Future<void> show(BuildContext context, Trip trip) {
    return TriftlyBottomSheet.show(
      context,
      child: ShareTripBottomSheet(trip: trip),
    );
  }

  @override
  State<ShareTripBottomSheet> createState() => _ShareTripBottomSheetState();
}

class _ShareTripBottomSheetState extends State<ShareTripBottomSheet> {
  List<TripMemberSummary> _members = const [];
  bool _loadingMembers = false;

  Trip get trip => widget.trip;

  String get _link => ShareLink.forTrip(trip);

  @override
  void initState() {
    super.initState();
    if (trip.canManageTripSettings) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadMembers());
    }
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    final members = await AppScope.of(context).tripRepository.tripMembers(trip.id);
    if (!mounted) return;
    setState(() {
      _members = members;
      _loadingMembers = false;
    });
  }

  Future<void> _setMemberRole(TripMemberSummary member, String role) async {
    final ok = await AppScope.of(context).tripRepository.setTripMemberRole(
          tripId: trip.id,
          memberUserId: member.userId,
          role: role,
        );
    if (!mounted) return;
    if (ok) {
      await _loadMembers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update role')),
      );
    }
  }

  void _copyLink(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareLink() {
    HapticFeedback.lightImpact();
    Share.share(
      'Join our trip "${trip.name}" on Triftly — tap to preview, then join:\n$_link',
      subject: trip.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(
            title: 'Share trip',
            caption: 'Invite travel buddies',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetGradientHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const SheetIconTile(icon: Icons.link_rounded),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Share link',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy link',
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      onPressed: () => _copyLink(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SheetResultBanner(text: _link, caption: trip.name),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SheetPrimaryButton(label: 'Share link', onPressed: _shareLink),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Buddies open the link for a preview, then join. Default role is view-only; you can promote editors below.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          if (trip.canManageTripSettings) ...[
            const SizedBox(height: AppSpacing.xl),
            const SheetSectionHeader(
              title: 'Who joined',
              caption: 'Viewer or editor',
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_loadingMembers)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_members.isEmpty)
              Text(
                'No one has joined yet — send the link via WhatsApp or Messages.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              )
            else
              ..._members.map((member) => _MemberRoleTile(
                    member: member,
                    onRoleChanged: (role) => _setMemberRole(member, role),
                  )),
          ],
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'QR code', caption: 'Scan to open'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: QrImageView(
                data: _link,
                size: 160,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.textPrimary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRoleTile extends StatelessWidget {
  const _MemberRoleTile({
    required this.member,
    required this.onRoleChanged,
  });

  final TripMemberSummary member;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SheetSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                member.userId.length > 8
                    ? '${member.userId.substring(0, 8)}…'
                    : member.userId,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'viewer', label: Text('View')),
                ButtonSegment(value: 'editor', label: Text('Edit')),
              ],
              selected: {member.role},
              onSelectionChanged: (selection) => onRoleChanged(selection.first),
            ),
          ],
        ),
      ),
    );
  }
}
