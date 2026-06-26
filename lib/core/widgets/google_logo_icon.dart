import 'package:flutter/material.dart';

/// Google "G" mark for social sign-in (from Flaticon).
///
/// Attribution: https://www.flaticon.com/free-icon/google_2702602
class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({this.size = 22, super.key});

  static const _asset = 'assets/icons/google_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
