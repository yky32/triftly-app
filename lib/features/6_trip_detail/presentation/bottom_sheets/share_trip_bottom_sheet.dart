import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/share_link.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/triftly_motion.dart';

class ShareTripBottomSheet extends StatelessWidget {
  const ShareTripBottomSheet({required this.trip, super.key});

  final Trip trip;

  static Future<void> show(BuildContext context, Trip trip) {
    return TriftlyBottomSheet.show(
      context,
      child: ShareTripBottomSheet(trip: trip),
    );
  }

  String get _link => ShareLink.forTrip(trip);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Share trip', caption: 'View-only link'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _link,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _ShareActionChip(
                        icon: Icons.copy_rounded,
                        label: 'Copy link',
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _link));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ShareActionChip(
                        icon: Icons.ios_share_outlined,
                        label: 'Share',
                        onTap: () => Share.share(
                          'Join my trip "${trip.name}" on Triftly\n$_link',
                          subject: trip.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Anyone with this link can view your itinerary and expenses.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'QR code'),
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

class _ShareActionChip extends StatelessWidget {
  const _ShareActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
