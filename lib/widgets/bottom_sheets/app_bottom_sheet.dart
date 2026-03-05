import 'package:flutter/material.dart';

/// Wraps [child] so that tapping outside focusable areas unfocuses and dismisses the keyboard.
/// Use as the outer wrapper of bottom sheet content when the sheet has text fields.
class TapToUnfocus extends StatelessWidget {
  const TapToUnfocus({super.key, required this.child});

  final Widget child;

  /// Unfocuses the current focus and dismisses the keyboard. Call from onTap or elsewhere.
  static void unfocus(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocus(context),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Drag-handle pill at the top of a bottom sheet (indicates draggable / dismissible).
/// Use theme color; no need for red — aligns with common mobile bottom sheet UX.
class BottomSheetDragHandle extends StatelessWidget {
  const BottomSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    return Center(
      child: Container(
        width: 64,
        height: 3,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Bottom sheet on the root navigator so it stays on top of all UI.
/// Use for every feature sheet.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    builder: builder,
  );
}
  