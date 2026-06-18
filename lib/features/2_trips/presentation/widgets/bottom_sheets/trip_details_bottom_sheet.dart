import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:triftly/core/navigation/app_navigation.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/_standalone/login/bloc/login_bloc.dart';
import 'package:triftly/features/3_routine_builder/data/routine_repository.dart';
import 'package:triftly/router/app_page.dart';
import 'package:triftly/services/trip_share_service.dart';
import 'package:triftly/widgets/bottom_sheets/app_bottom_sheet.dart';

/// Bottom sheet for a saved trip: view details, edit plan, or share (placeholder).
class TripDetailsBottomSheet extends StatelessWidget {
  const TripDetailsBottomSheet({super.key, required this.trip});

  final SavedTripSummary trip;

  static Future<void> show(BuildContext context, SavedTripSummary trip) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripDetailsBottomSheet(trip: trip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final localizations = MaterialLocalizations.of(context);
    final startLabel = localizations.formatShortDate(trip.startDate);
    final endLabel = localizations.formatShortDate(trip.endDate);
    final dateLabel =
        trip.startDate == trip.endDate ? startLabel : '$startLabel – $endLabel';
    final daysCount = trip.endDate.difference(trip.startDate).inDays + 1;
    final dayLabel = daysCount == 1 ? '1 day' : '$daysCount days';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BottomSheetDragHandle(),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.deepTeal, AppColors.driftTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -28,
                    top: -28,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -18,
                    bottom: -28,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.terrain_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        dayLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            trip.name.trim().isEmpty ? 'Untitled trip' : trip.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.place_rounded,
            iconColor: AppColors.driftTeal,
            label: trip.countries.isEmpty
                ? 'No country'
                : trip.countries.join(', '),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.date_range_rounded,
            iconColor: AppColors.softAmber,
            label: dateLabel,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.calmGreen,
            label: dayLabel,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepTeal, AppColors.driftTeal],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton.icon(
                onPressed: () => _editPlan(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_calendar_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Edit days & spots',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _shareWithBuddies(context),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Invite travel buddies'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppColors.driftTeal,
              side: BorderSide(color: AppColors.driftTeal.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: Text(
              'Close',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editPlan(BuildContext context) {
    Navigator.of(context).pop();
    AppNavigation.openTripPlanner(context);
  }

  Future<void> _shareWithBuddies(BuildContext context) async {
    final isSignedIn = context.read<LoginBloc>().state is LoginSuccess;
    final message = TripShareService.shareMessage(trip);
    final link = TripShareService.placeholderInviteLink(trip);

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Invite travel buddies'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSignedIn) ...[
                Text(
                  'Sign in will be required to share trips and sync with your group. This is a preview link only.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.push(AppPage.login.path);
                  },
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: 8),
              ] else
                Text(
                  'Deep link sharing is coming soon. Copy the placeholder invite link below.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              SelectableText(
                link,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message));
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Copy invite'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
