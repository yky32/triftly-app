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
      'Join my trip "${trip.name}" on Triftly\n$_link',
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
          const SheetSectionHeader(title: 'Share trip', caption: 'View-only link'),
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
            'Anyone with this link can view your itinerary and expenses.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
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
