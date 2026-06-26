import 'package:flutter/material.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.user,
    required this.isCloudSignedIn,
    this.radius = 28,
    super.key,
  });

  final User? user;
  final bool isCloudSignedIn;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl;
    final iconSize = radius;

    if (isCloudSignedIn && avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryMuted,
        foregroundImage: NetworkImage(avatarUrl),
        onForegroundImageError: (_, __) {},
        child: _fallbackIcon(iconSize: iconSize, isCloudSignedIn: true),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryMuted,
      child: _fallbackIcon(iconSize: iconSize, isCloudSignedIn: isCloudSignedIn),
    );
  }

  Widget _fallbackIcon({required double iconSize, required bool isCloudSignedIn}) {
    return Icon(
      isCloudSignedIn ? Icons.verified_user_outlined : Icons.person_rounded,
      size: iconSize,
      color: AppColors.primaryDark,
    );
  }
}
