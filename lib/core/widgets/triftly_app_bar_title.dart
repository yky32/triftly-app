import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Consistent AppBar titles: large single-line for tab roots, compact two-line for detail pages.
class TriftlyAppBarTitle extends StatelessWidget {
  const TriftlyAppBarTitle({
    required this.title,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;

  bool get _isDetail => subtitle != null && subtitle!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_isDetail) {
      return Text(title);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
