import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

/// Inner scroll for a trip detail tab — links to [NestedScrollView] header.
class TripDetailTabScroll extends StatelessWidget {
  const TripDetailTabScroll({
    required this.slivers,
    super.key,
  });

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: key,
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            ...slivers,
          ],
        );
      },
    );
  }

  static SliverPadding listBottomPadding(BuildContext context, {required Widget sliver}) {
    return SliverPadding(
      padding: EdgeInsets.only(bottom: AppSpacing.listBottomInset(context)),
      sliver: sliver,
    );
  }
}
