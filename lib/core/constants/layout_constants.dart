import 'package:flutter/material.dart';

/// Global layout constants and helpers so content is not blocked by the bottom nav bar,
/// safe areas, or other chrome. Use for scroll views, lists, and bottom-anchored content.
class LayoutConstants {
  LayoutConstants._();

  /// Approximate height of the floating bottom nav bar (tab bar).
  /// Used with [scrollPaddingBelowNavBar] so scrollable content can extend above the nav.
  static const double bottomNavBarHeight = 72;

  /// Returns bottom padding so scrollable content is not hidden behind the nav bar.
  /// Use as the bottom value of [EdgeInsets] for [SingleChildScrollView], [ListView], etc.
  ///
  /// Example:
  /// ```dart
  /// SingleChildScrollView(
  ///   padding: EdgeInsets.fromLTRB(24, 6, 24, LayoutConstants.scrollPaddingBelowNavBar(context)),
  ///   child: ...,
  /// )
  /// ```
  static double scrollPaddingBelowNavBar(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + bottomNavBarHeight;
  }

  /// Returns [EdgeInsets] with only bottom set to clear the nav bar.
  /// Useful when you need just the bottom inset (e.g. for [Padding] or [SliverPadding]).
  static EdgeInsets scrollPaddingBelowNavBarInsets(BuildContext context) {
    return EdgeInsets.only(bottom: scrollPaddingBelowNavBar(context));
  }
}
