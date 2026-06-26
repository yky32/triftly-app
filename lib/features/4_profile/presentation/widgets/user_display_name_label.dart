import 'package:flutter/material.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/google_logo_icon.dart';

/// Display name with optional Google provider badge when signed in via Google.
class UserDisplayNameLabel extends StatelessWidget {
  const UserDisplayNameLabel({
    required this.user,
    required this.style,
    this.textAlign = TextAlign.start,
    this.iconSize = 18,
    super.key,
  });

  final User user;
  final TextStyle? style;
  final TextAlign textAlign;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final name = Text(
      user.displayName,
      textAlign: textAlign,
      style: style,
      overflow: TextOverflow.ellipsis,
    );

    if (!user.signedInWithGoogle) {
      return name;
    }

    final children = <Widget>[
      Flexible(child: name),
      SizedBox(width: iconSize * 0.35),
      GoogleLogoIcon(size: iconSize),
    ];

    if (textAlign == TextAlign.center) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    return Row(
      children: children,
    );
  }
}
